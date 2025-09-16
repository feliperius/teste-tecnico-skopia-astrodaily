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
                .tabItem { Label(Strings.tabToday, systemImage: "sparkles") }

            NavigationStack { ApodListView() }
                .tabItem { Label(Strings.tabList, systemImage: "photo.on.rectangle") }

            NavigationStack { FavoritesView() }
                .tabItem { Label(Strings.tabFavorites, systemImage: "star.fill") }
        }
        .background(Color.black)
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

