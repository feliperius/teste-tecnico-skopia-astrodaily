import SwiftUI
import CoreData

@main
struct HomeApp: App {
    let coreDataStack = CoreDataStack.shared
    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.managedObjectContext, coreDataStack.viewContext)
                .preferredColorScheme(.dark)
                .environment(\.locale, Locale(identifier: "pt_BR"))
        }
    }
}

struct AppRootView: View {
    @State private var showSplash = true
    
    var body: some View {
        if showSplash {
            SplashView {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        } else {
            RootTabs()
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

