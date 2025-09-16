import Foundation
import Observation

@Observable final class ApodDetailViewModel {
    let item: ApodItem
    private let favorites: FavoritesStoring

    init(item: ApodItem, favorites: FavoritesStoring = UserDefaultsFavoritesStore()) {
        self.item = item; self.favorites = favorites
    }

    var isFavorite: Bool { favorites.isFavorite(item.id) }
    func toggleFavorite() { favorites.toggleFavorite(item) }
}

