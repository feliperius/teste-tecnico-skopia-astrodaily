import SwiftUI

@main
struct SkopiaAstroDailyApp: App {
    var body: some Scene {
        WindowGroup { RootTabs() }
    }
}

struct RootTabs: View {
    var body: some View {
        TabView {
            NavigationStack { FeedView() }
                .tabItem { Label("Hoje", systemImage: "sparkles") }

            NavigationStack { ApodListView() }
                .tabItem { Label("Lista", systemImage: "photo.on.rectangle") }

            NavigationStack { FavoritesView() }
                .tabItem { Label("Favoritos", systemImage: "star.fill") }
        }
    }
}

