import SwiftUI

public struct SearchView: View {
    @EnvironmentObject private var player: AudioPlayerManager
    @State private var searchText = ""
    @State private var searchResults: [Song] = []
    @State private var isSearching = false

    private let genres = [
        ("Pop", "music.note"),
        ("Hip-Hop", "headphones"),
        ("Electronic", "bolt.fill"),
        ("Lo-Fi", "moon.stars.fill"),
        ("Rock", "guitars.fill"),
        ("Indie", "sparkles"),
        ("Classical", "pianokeys"),
        ("Jazz", "flame.fill")
    ]

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Songs, artists, or albums", text: $searchText)
                        .autocorrectionDisabled()
                        .onSubmit {
                            performSearch()
                        }

                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                if isSearching {
                    Spacer()
                    ProgressView("Searching music...")
                    Spacer()
                } else if !searchResults.isEmpty {
                    // Search Results
                    List {
                        Section("Search Results (\(searchResults.count))") {
                            ForEach(searchResults) { song in
                                SongRowView(
                                    song: song,
                                    isPlayingCurrent: player.currentSong?.id == song.id
                                ) {
                                    player.play(song: song, from: searchResults)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                } else {
                    // Discover / Browse Genres
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Browse Genres")
                                .font(.system(size: 20, weight: .bold))
                                .padding(.horizontal, 16)
                                .padding(.top, 10)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                                ForEach(genres, id: \.0) { genre, icon in
                                    GenreCard(title: genre, icon: icon) {
                                        searchText = genre
                                        performSearch()
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.bottom, 70)
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isSearching = true
        Task {
            searchResults = await MusicService.shared.search(query: searchText)
            isSearching = false
        }
    }
}

private struct GenreCard: View {
    let title: String
    let icon: String
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(14)
            .frame(height: 80)
            .background(
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.8), Color.purple.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
