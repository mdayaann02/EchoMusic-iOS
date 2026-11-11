import SwiftUI

public struct ArtworkImageView: View {
    public let urlString: String
    public let size: CGFloat
    public let cornerRadius: CGFloat

    public init(urlString: String, size: CGFloat = 50, cornerRadius: CGFloat = 8) {
        self.urlString = urlString
        self.size = size
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        Group {
            if let url = URL(string: urlString), !urlString.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        fallbackView
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }

    private var fallbackView: some View {
        LinearGradient(
            colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Image(systemName: "music.note")
                .font(.system(size: size * 0.4))
                .foregroundColor(.white.opacity(0.8))
        )
    }
}

public struct SongRowView: View {
    public let song: Song
    public let isPlayingCurrent: Bool
    public let onSelect: () -> Void

    @EnvironmentObject private var player: AudioPlayerManager

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ArtworkImageView(urlString: song.artworkURL, size: 54, cornerRadius: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isPlayingCurrent ? .accentColor : .primary)
                        .lineLimit(1)

                    Text(song.artist + (song.album.isEmpty ? "" : " • \(song.album)"))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                if isPlayingCurrent {
                    Image(systemName: player.isPlaying ? "waveform" : "pause.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 14, weight: .bold))
                }

                Button(action: {
                    player.toggleFavorite(song: song)
                }) {
                    Image(systemName: player.favorites.contains(song.id) ? "heart.fill" : "heart")
                        .foregroundColor(player.favorites.contains(song.id) ? .red : .gray.opacity(0.6))
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
