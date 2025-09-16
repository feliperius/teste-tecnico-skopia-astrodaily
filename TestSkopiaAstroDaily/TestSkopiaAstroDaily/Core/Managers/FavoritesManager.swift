import Foundation
import Observation

/// Manager centralizado para favoritos, compartilhado entre ViewModels
@Observable final class FavoritesManager {
    private let store: FavoritesStoring
    
    /// IDs dos favoritos para binding reativo
    var favoriteIds: Set<String> = []
    
    /// Itens favoritos completos
    var favoriteItems: [ApodItem] = []
    
    init(store: FavoritesStoring = UserDefaultsFavoritesStore()) {
        self.store = store
        loadFavorites()
    }
    
    /// Verifica se um item é favorito
    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    /// Verifica se um item é favorito
    func isFavorite(_ item: ApodItem) -> Bool {
        isFavorite(item.id)
    }
    
    /// Adiciona/remove favorito
    func toggleFavorite(_ item: ApodItem) {
        store.toggleFavorite(item)
        loadFavorites() // Recarrega para manter sincronizado
        print("⭐ FavoritesManager: Favorito toggleado para \(item.title)")
    }
    
    /// Adiciona favorito
    func addFavorite(_ item: ApodItem) {
        guard !isFavorite(item) else { return }
        toggleFavorite(item)
    }
    
    /// Remove favorito
    func removeFavorite(_ item: ApodItem) {
        guard isFavorite(item) else { return }
        toggleFavorite(item)
    }
    
    /// Recarrega favoritos do store
    func reload() {
        loadFavorites()
    }
    
    /// Conta total de favoritos
    var favoriteCount: Int {
        favoriteIds.count
    }
    
    // MARK: - Private
    
    private func loadFavorites() {
        favoriteItems = store.all()
        favoriteIds = Set(favoriteItems.map(\.id))
        print("💾 FavoritesManager: \(favoriteIds.count) favoritos carregados")
    }
}