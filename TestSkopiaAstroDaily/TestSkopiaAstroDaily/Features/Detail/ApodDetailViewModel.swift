import Foundation
import Observation

@Observable final class ApodDetailViewModel {
    let item: ApodItem
    private let favoritesManager: FavoritesManagerProtocol

    init(item: ApodItem, favoritesManager: FavoritesManagerProtocol = FavoritesManager()) {
        self.item = item
        self.favoritesManager = favoritesManager
    }

    var isFavorite: Bool { favoritesManager.isFavorite(item) }
    
    func toggleFavorite() async { await favoritesManager.toggleFavorite(item) }
    
    func formattedDate() -> String {
        DateFormatter.localizedLong(fromAPIDateString: item.date)
    }
}

