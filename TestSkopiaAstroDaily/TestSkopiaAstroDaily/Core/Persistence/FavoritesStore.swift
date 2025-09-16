import Foundation

protocol FavoritesStoring {
    func isFavorite(_ id: String) -> Bool
    func toggleFavorite(_ item: ApodItem)
    func all() -> [ApodItem]
}

final class UserDefaultsFavoritesStore: FavoritesStoring {
    private let idsKey = "fav_ids"
    private let itemsKey = "fav_items"
    private let ud: UserDefaults

    init(ud: UserDefaults = .standard) { self.ud = ud }

    func isFavorite(_ id: String) -> Bool { ids().contains(id) }

    func toggleFavorite(_ item: ApodItem) {
        var set = ids()
        var dict = items()
        if set.contains(item.id) {
            set.remove(item.id); dict[item.id] = nil
        } else {
            set.insert(item.id)
            dict[item.id] = try? JSONEncoder().encode(item)
        }
        ud.set(Array(set), forKey: idsKey)
        ud.set(dict, forKey: itemsKey)
    }

    func all() -> [ApodItem] {
        items()
            .compactMap { try? JSONDecoder().decode(ApodItem.self, from: $0.value) }
            .sorted { $0.date > $1.date }
    }

    private func ids() -> Set<String> { Set((ud.array(forKey: idsKey) as? [String]) ?? []) }
    private func items() -> [String: Data] { ud.dictionary(forKey: itemsKey) as? [String: Data] ?? [:] }
}

