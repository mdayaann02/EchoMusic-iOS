import SwiftUI

public struct HomeView: View {
    @EnvironmentObject private var player: AudioPlayerManager
    @State private var trendingSongs: [Song] = []
    @State private var isLoading = false
    @State private var selectedMood = "Chill"

    private let moods = ["Chill", "Workout", "Focus", "Party", "Sleep", "Romance"]

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Echo Music")
                            .font(.system(size: 32, weight: .bold))
                        Text("Stream ad-free music")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)

                    // Mood selector chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                    Task {
                                        isLoading = true
                                        trendingSongs = await MusicService.shared.search(query: mood)
                                        isLoading = false
                                    }
                                }) {
                                    Text(mood)
                                        .font(.system(size: 14, weight: .medium))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 18)
                                        .background(
                                            Capsule()
                                                .fill(selectedMood == mood ? Color.accentColor : Color.gray.opacity(0.18))
                                        )
                                        .foregroundColor(selectedMood == mood ? .white : .primary)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Quick Picks (Horizontal Cards)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Picks")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.horizontal, 16)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Song.samples) { song in
                                    QuickPickCard(song: song) {
                                        player.play(song: song, from: Song.samples)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }

                    // Trending Songs List
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Trending Now")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            if isLoading {
                                ProgressView()
                            }
                        }
                        .padding(.horizontal, 16)

                        LazyVStack(spacing: 4) {
                            ForEach(trendingSongs.isEmpty ? Song.samples : trendingSongs) { song in
                                SongRowView(
                                    song: song,
                                    isPlayingCurrent: player.currentSong?.id == song.id
                                ) {
                                    player.play(song: song, from: trendingSongs.isEmpty ? Song.samples : trendingSongs)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.bottom, 70) // mini-player margin
            }
            .navigationBarHidden(true)
            .task {
                isLoading = true
                trendingSongs = await MusicService.shared.fetchTrending()
                isLoading = false
            }
        }
    }
}

private struct QuickPickCard: View {
    let song: Song
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .bottomTrailing) {
                    ArtworkImageView(urlString: song.artworkURL, size: 140, cornerRadius: 12)

                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 34, height: 34)
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.white)
                        )
                        .padding(8)
                }

                Text(song.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)
                    .frame(width: 140, alignment: .leading)

                Text(song.artist)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(width: 140, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}
