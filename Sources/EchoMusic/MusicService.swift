import Foundation

public actor MusicService {
    public static let shared = MusicService()

    private init() {}

    private struct ITunesSearchResponse: Decodable {
        let resultCount: Int
        let results: [ITunesTrack]
    }

    private struct ITunesTrack: Decodable {
        let trackId: Int?
        let trackName: String?
        let artistName: String?
        let collectionName: String?
        let artworkUrl100: String?
        let previewUrl: String?
        let trackTimeMillis: Double?
    }

    public func search(query: String) async -> [Song] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        guard let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?term=\(encoded)&media=music&entity=song&limit=30") else {
            return fallbackSearch(query: trimmed)
        }

        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return fallbackSearch(query: trimmed)
            }

            let decoded = try JSONDecoder().decode(ITunesSearchResponse.self, from: data)
            let songs: [Song] = decoded.results.compactMap { track in
                guard let preview = track.previewUrl,
                      let title = track.trackName,
                      let artist = track.artistName else {
                    return nil
                }
                // Upgrade artwork to high resolution (600x600)
                let highResArtwork = track.artworkUrl100?
                    .replacingOccurrences(of: "100x100bb.jpg", with: "600x600bb.jpg")
                    ?? ""

                let duration = (track.trackTimeMillis ?? 30000) / 1000.0

                return Song(
                    id: track.trackId.map(String.init) ?? UUID().uuidString,
                    title: title,
                    artist: artist,
                    album: track.collectionName ?? "",
                    artworkURL: highResArtwork,
                    streamURL: preview,
                    duration: duration
                )
            }

            return songs.isEmpty ? fallbackSearch(query: trimmed) : songs
        } catch {
            return fallbackSearch(query: trimmed)
        }
    }

    public func fetchTrending() async -> [Song] {
        let results = await search(query: "Top Hits 2026")
        return results.isEmpty ? Song.samples : results
    }

    private func fallbackSearch(query: String) -> [Song] {
        let lower = query.lowercased()
        let filtered = Song.samples.filter {
            $0.title.lowercased().contains(lower) ||
            $0.artist.lowercased().contains(lower) ||
            $0.album.lowercased().contains(lower)
        }
        return filtered.isEmpty ? Song.samples : filtered
    }
}
