import Foundation
import Observation

@Observable final class FeedViewModel {
    private let service: NasaApodServicing
    private let favorites: FavoritesStoring

    var currentDate: Date = Date()
    var item: ApodItem?
    var isLoading = false
    var error: String?

    init(service: NasaApodServicing = NasaApodService(),
         favorites: FavoritesStoring = UserDefaultsFavoritesStore()) {
        self.service = service; self.favorites = favorites
    }

    @MainActor func load() async {
        isLoading = true; error = nil
        defer { isLoading = false }
        do { item = try await service.fetchApod(date: currentDate) }
        catch { self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription }
    }

    func prevDay() { currentDate = currentDate.adding(days: -1); Task { await load() } }
    func nextDay() {
        let tomorrow = Date().adding(days: 1)
        guard currentDate.adding(days: 1) < tomorrow else { return }
        currentDate = currentDate.adding(days: 1); Task { await load() }
    }

    func isFavorite() -> Bool { favorites.isFavorite(item?.id ?? "") }
    func toggleFavorite() { if let it = item { favorites.toggleFavorite(it) } }
}

