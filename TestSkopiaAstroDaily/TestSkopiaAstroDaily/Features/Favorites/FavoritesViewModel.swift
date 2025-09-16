import Foundation
import Observation

@Observable final class FavoritesViewModel {
    private let favoritesManager: FavoritesManager
    
    var items: [ApodItem] { favoritesManager.favoriteItems }
    var favoriteCount: Int { favoritesManager.favoriteCount }

    init(favoritesManager: FavoritesManager = FavoritesManager()) {
        self.favoritesManager = favoritesManager
    }

    func reload() { favoritesManager.reload() }
}
