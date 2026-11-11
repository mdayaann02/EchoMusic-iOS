import SwiftUI

public struct ContentView: View {
    @StateObject private var player = AudioPlayerManager.shared
    @State private var isFullPlayerPresented = false

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "music.note.list")
                    }
            }

            // Floating Mini-Player
            MiniPlayerView(isFullPlayerPresented: $isFullPlayerPresented)
        }
        .environmentObject(player)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isFullPlayerPresented) {
            FullPlayerView()
                .environmentObject(player)
        }
    }
}
