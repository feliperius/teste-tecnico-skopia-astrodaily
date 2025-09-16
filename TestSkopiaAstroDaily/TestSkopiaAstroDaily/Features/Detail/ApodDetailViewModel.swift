import Foundation
import Observation

@Observable final class ApodDetailViewModel {
    let item: ApodItem
    private let favoritesManager: FavoritesManager

    init(item: ApodItem, favoritesManager: FavoritesManager = FavoritesManager()) {
        self.item = item
        self.favoritesManager = favoritesManager
    }

    var isFavorite: Bool { favoritesManager.isFavorite(item) }
    
    func toggleFavorite() { favoritesManager.toggleFavorite(item) }
    
    func formattedDate() -> String {
        DateFormatter.localizedLong(fromAPIDateString: item.date)
    }
}

