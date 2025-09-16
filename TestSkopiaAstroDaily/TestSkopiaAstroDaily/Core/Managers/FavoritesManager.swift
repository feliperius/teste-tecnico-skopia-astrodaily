import Foundation
import Observation

@Observable final class FavoritesManager {
    private let store: FavoritesStoring
    var favoriteIds: Set<String> = []
    var favoriteItems: [ApodItem] = []
    
    init(store: FavoritesStoring = UserDefaultsFavoritesStore()) {
        self.store = store
        loadFavorites()
    }
    
    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    func isFavorite(_ item: ApodItem) -> Bool {
        isFavorite(item.id)
    }
    
    func toggleFavorite(_ item: ApodItem) {
        store.toggleFavorite(item)
        loadFavorites()
    }
    
    func addFavorite(_ item: ApodItem) {
        guard !isFavorite(item) else { return }
        toggleFavorite(item)
    }
    
    func removeFavorite(_ item: ApodItem) {
        guard isFavorite(item) else { return }
        toggleFavorite(item)
    }
    
    func reload() {
        loadFavorites()
    }
    
    var favoriteCount: Int {
        favoriteIds.count
    }
    
    // MARK: - Private
    private func loadFavorites() {
        favoriteItems = store.all()
        favoriteIds = Set(favoriteItems.map(\.id))
    }
}
