import SwiftUI

public struct LibraryView: View {
    @EnvironmentObject private var player: AudioPlayerManager
    @State private var selectedTab = 0

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Library Section", selection: $selectedTab) {
                    Text("Favorites (\(player.favorites.count))").tag(0)
                    Text("History").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if selectedTab == 0 {
                    let favSongs = (player.recentlyPlayed + Song.samples).filter { player.favorites.contains($0.id) }
                    if favSongs.isEmpty {
                        emptyState(
                            title: "No Favorites Yet",
                            message: "Tap the heart icon on any song while listening to save it here.",
                            icon: "heart.slash"
                        )
                    } else {
                        List {
                            ForEach(favSongs) { song in
                                SongRowView(
                                    song: song,
                                    isPlayingCurrent: player.currentSong?.id == song.id
                                ) {
                                    player.play(song: song, from: favSongs)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                } else {
                    if player.recentlyPlayed.isEmpty {
                        emptyState(
                            title: "No History",
                            message: "Songs you stream will automatically appear here.",
                            icon: "clock"
                        )
                    } else {
                        List {
                            ForEach(player.recentlyPlayed) { song in
                                SongRowView(
                                    song: song,
                                    isPlayingCurrent: player.currentSong?.id == song.id
                                ) {
                                    player.play(song: song, from: player.recentlyPlayed)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Your Library")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func emptyState(title: String, message: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text(title)
                .font(.system(size: 18, weight: .bold))
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer()
        }
    }
}
