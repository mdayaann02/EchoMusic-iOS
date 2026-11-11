import SwiftUI

public struct MiniPlayerView: View {
    @EnvironmentObject private var player: AudioPlayerManager
    @Binding var isFullPlayerPresented: Bool

    public var body: some View {
        if let current = player.currentSong {
            VStack(spacing: 0) {
                // Progress line
                GeometryReader { geo in
                    let progress = player.duration > 0 ? CGFloat(player.currentTime / player.duration) : 0
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 2)
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: geo.size.width * max(0, min(progress, 1)), height: 2)
                    }
                }
                .frame(height: 2)

                HStack(spacing: 12) {
                    ArtworkImageView(urlString: current.artworkURL, size: 44, cornerRadius: 6)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(current.title)
                            .font(.system(size: 14, weight: .semibold))
                            .lineLimit(1)
                        Text(current.artist)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: {
                        player.togglePlayPause()
                    }) {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                    }

                    Button(action: {
                        player.next()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.35), radius: 10, x: 0, y: 4)
                )
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 50) // float above TabBar
            .onTapGesture {
                isFullPlayerPresented = true
            }
        }
    }
}

public struct FullPlayerView: View {
    @EnvironmentObject private var player: AudioPlayerManager
    @Environment(\.dismiss) private var dismiss
    @State private var isScrubbing = false
    @State private var scrubTime: Double = 0
    @State private var showQueue = false

    public var body: some View {
        ZStack {
            // Background ambient blur
            if let song = player.currentSong {
                ArtworkImageView(urlString: song.artworkURL, size: 600, cornerRadius: 0)
                    .blur(radius: 60)
                    .opacity(0.35)
                    .ignoresSafeArea()
            }

            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header dismiss handle
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                    }

                    Spacer()

                    Text("PLAYING FROM ECHO")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1.5)

                    Spacer()

                    Button(action: { showQueue.toggle() }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                // Big Album Artwork
                if let song = player.currentSong {
                    ArtworkImageView(urlString: song.artworkURL, size: 280, cornerRadius: 20)
                        .shadow(color: Color.black.opacity(0.5), radius: 24, x: 0, y: 12)
                }

                Spacer()

                // Song Title & Artist + Favorite
                if let song = player.currentSong {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(song.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .lineLimit(1)

                            Text(song.artist + (song.album.isEmpty ? "" : " — \(song.album)"))
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .lineLimit(1)
                        }

                        Spacer()

                        Button(action: {
                            player.toggleFavorite(song: song)
                        }) {
                            Image(systemName: player.favorites.contains(song.id) ? "heart.fill" : "heart")
                                .font(.system(size: 24))
                                .foregroundColor(player.favorites.contains(song.id) ? .red : .white.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Progress Bar & Scrubbing
                VStack(spacing: 8) {
                    Slider(
                        value: Binding(
                            get: { isScrubbing ? scrubTime : player.currentTime },
                            set: { scrubTime = $0 }
                        ),
                        in: 0...max(player.duration, 1),
                        onEditingChanged: { editing in
                            isScrubbing = editing
                            if !editing {
                                player.seek(to: scrubTime)
                            }
                        }
                    )
                    .tint(.white)

                    HStack {
                        Text(formatTime(isScrubbing ? scrubTime : player.currentTime))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text(formatTime(player.duration))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 24)

                // Controls: Shuffle, Previous, Play/Pause, Next, Repeat
                HStack(spacing: 30) {
                    Button(action: { player.toggleShuffle() }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 20))
                            .foregroundColor(player.isShuffled ? .accentColor : .white.opacity(0.5))
                    }

                    Button(action: { player.previous() }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }

                    Button(action: { player.togglePlayPause() }) {
                        Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 68))
                            .foregroundColor(.white)
                    }

                    Button(action: { player.next() }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white)
                    }

                    Button(action: { player.toggleRepeat() }) {
                        Image(systemName: player.repeatMode.rawValue)
                            .font(.system(size: 20))
                            .foregroundColor(player.repeatMode != .off ? .accentColor : .white.opacity(0.5))
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.vertical, 16)
        }
        .sheet(isPresented: $showQueue) {
            QueueSheetView()
                .environmentObject(player)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && seconds >= 0 else { return "0:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

public struct QueueSheetView: View {
    @EnvironmentObject private var player: AudioPlayerManager
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            List {
                Section("Now Playing") {
                    if let current = player.currentSong {
                        SongRowView(song: current, isPlayingCurrent: true) {}
                    }
                }

                Section("Up Next (\(player.queue.count) songs)") {
                    ForEach(player.queue) { song in
                        SongRowView(
                            song: song,
                            isPlayingCurrent: player.currentSong?.id == song.id
                        ) {
                            player.play(song: song, from: player.queue)
                        }
                    }
                }
            }
            .navigationTitle("Up Next")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
