import Foundation

public struct Song: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let artist: String
    public let album: String
    public let artworkURL: String
    public let streamURL: String
    public let duration: Double // in seconds

    public init(
        id: String = UUID().uuidString,
        title: String,
        artist: String,
        album: String = "",
        artworkURL: String = "",
        streamURL: String,
        duration: Double = 0
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkURL = artworkURL
        self.streamURL = streamURL
        self.duration = duration
    }

    public var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

public enum RepeatMode: String, CaseIterable, Sendable {
    case off = "repeat"
    case all = "repeat.circle"
    case one = "repeat.1.circle"
}

public extension Song {
    static let samples: [Song] = [
        Song(
            id: "echo-1",
            title: "Midnight City Lights",
            artist: "Echo Lo-Fi",
            album: "Chill Beats Vol. 1",
            artworkURL: "https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=500&q=80",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
            duration: 372
        ),
        Song(
            id: "echo-2",
            title: "Neon Horizon",
            artist: "Synthwave Collective",
            album: "Cyber Retro",
            artworkURL: "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500&q=80",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
            duration: 423
        ),
        Song(
            id: "echo-3",
            title: "Autumn Breeze",
            artist: "Acoustic Reverie",
            album: "Morning Coffee",
            artworkURL: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=500&q=80",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
            duration: 345
        ),
        Song(
            id: "echo-4",
            title: "Solar Flare",
            artist: "Cosmic Odyssey",
            album: "Starlight Voyage",
            artworkURL: "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=500&q=80",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
            duration: 502
        ),
        Song(
            id: "echo-5",
            title: "Velvet Nights",
            artist: "Luna Groove",
            album: "Late Night Jazz",
            artworkURL: "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&q=80",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3",
            duration: 384
        ),
        Song(
            id: "echo-6",
            title: "Electric Dreams",
            artist: "Pulse & Wave",
            album: "Digital Utopia",
            artworkURL: "https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=500&q=80",
            streamURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3",
            duration: 410
        )
    ]
}
