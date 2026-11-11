import Foundation
import AVFoundation
import MediaPlayer
import Combine

@MainActor
public final class AudioPlayerManager: ObservableObject {
    public static let shared = AudioPlayerManager()

    @Published public var currentSong: Song?
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: Double = 0
    @Published public var duration: Double = 0
    @Published public var isBuffering: Bool = false
    @Published public var queue: [Song] = []
    @Published public var currentIndex: Int = 0
    @Published public var repeatMode: RepeatMode = .off
    @Published public var isShuffled: Bool = false
    @Published public var favorites: Set<String> = []
    @Published public var recentlyPlayed: [Song] = []

    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        configureAudioSession()
        setupRemoteCommandCenter()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    public func play(song: Song, from queueList: [Song] = []) {
        if !queueList.isEmpty {
            self.queue = queueList
            if let index = queueList.firstIndex(where: { $0.id == song.id }) {
                self.currentIndex = index
            }
        } else if !queue.contains(where: { $0.id == song.id }) {
            queue.append(song)
            currentIndex = queue.count - 1
        }

        self.currentSong = song
        self.duration = song.duration

        if !recentlyPlayed.contains(where: { $0.id == song.id }) {
            recentlyPlayed.insert(song, at: 0)
            if recentlyPlayed.count > 25 {
                recentlyPlayed.removeLast()
            }
        }

        guard let url = URL(string: song.streamURL) else { return }

        cleanupCurrentItem()

        let playerItem = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: playerItem)

        // Observe player item status & completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )

        addPeriodicTimeObserver()

        player?.play()
        self.isPlaying = true
        updateNowPlayingInfo()
    }

    public func togglePlayPause() {
        guard let player = player else {
            if let first = queue.first ?? Song.samples.first {
                play(song: first, from: Song.samples)
            }
            return
        }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        updateNowPlayingInfo()
    }

    public func seek(to seconds: Double) {
        guard let player = player else { return }
        let cmTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: cmTime) { [weak self] _ in
            Task { @MainActor in
                self?.currentTime = seconds
                self?.updateNowPlayingInfo()
            }
        }
    }

    public func next() {
        guard !queue.isEmpty else { return }

        if repeatMode == .one, currentSong != nil {
            seek(to: 0)
            player?.play()
            isPlaying = true
            return
        }

        if isShuffled {
            currentIndex = Int.random(in: 0..<queue.count)
        } else if currentIndex + 1 < queue.count {
            currentIndex += 1
        } else if repeatMode == .all {
            currentIndex = 0
        } else {
            player?.pause()
            isPlaying = false
            return
        }

        let nextSong = queue[currentIndex]
        play(song: nextSong, from: queue)
    }

    public func previous() {
        guard !queue.isEmpty else { return }

        if currentTime > 3.0 {
            seek(to: 0)
            return
        }

        if currentIndex > 0 {
            currentIndex -= 1
        } else if repeatMode == .all {
            currentIndex = queue.count - 1
        } else {
            seek(to: 0)
            return
        }

        let prevSong = queue[currentIndex]
        play(song: prevSong, from: queue)
    }

    public func toggleFavorite(song: Song) {
        if favorites.contains(song.id) {
            favorites.remove(song.id)
        } else {
            favorites.insert(song.id)
        }
    }

    public func toggleRepeat() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }

    public func toggleShuffle() {
        isShuffled.toggle()
    }

    @objc private func playerItemDidReachEnd() {
        Task { @MainActor in
            self.next()
        }
    }

    private func addPeriodicTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                let seconds = CMTimeGetSeconds(time)
                if !seconds.isNaN {
                    self.currentTime = seconds
                }

                if let item = self.player?.currentItem {
                    let dur = CMTimeGetSeconds(item.duration)
                    if !dur.isNaN && dur > 0 {
                        self.duration = dur
                    }
                }
            }
        }
    }

    private func cleanupCurrentItem() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.player?.play()
                self?.isPlaying = true
                self?.updateNowPlayingInfo()
            }
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.player?.pause()
                self?.isPlaying = false
                self?.updateNowPlayingInfo()
            }
            return .success
        }

        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.togglePlayPause()
            }
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.next()
            }
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.previous()
            }
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let posEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            Task { @MainActor in
                self?.seek(to: posEvent.positionTime)
            }
            return .success
        }
    }

    private func updateNowPlayingInfo() {
        guard let song = currentSong else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }

        let info: [String: Any] = [
            MPMediaItemPropertyTitle: song.title,
            MPMediaItemPropertyArtist: song.artist,
            MPMediaItemPropertyAlbumTitle: song.album,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPMediaItemPropertyPlaybackDuration: duration > 0 ? duration : song.duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
}
