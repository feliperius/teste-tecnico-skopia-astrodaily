import SwiftUI

@main
struct HomeApp: App {
    var body: some Scene {
        WindowGroup { 
            RootTabs()
                .preferredColorScheme(.dark)
        }
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
        .background(Color.black)
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

