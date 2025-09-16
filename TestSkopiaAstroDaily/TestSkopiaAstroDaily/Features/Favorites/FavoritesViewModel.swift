import Foundation
import Observation

@Observable final class FavoritesViewModel {
    private let store: FavoritesStoring
    var items: [ApodItem] = []

    init(store: FavoritesStoring = UserDefaultsFavoritesStore()) {
        self.store = store
        reload()
    }

    func reload() { items = store.all() }
}
