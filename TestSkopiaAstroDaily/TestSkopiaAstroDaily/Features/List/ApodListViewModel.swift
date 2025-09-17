import Foundation
import Observation

@Observable final class ApodListViewModel {
    // MARK: - Constants
    private enum Constants {
        static let defaultDaysToLoad = 20
        static let minimumDaysToLoad = 1
        static let noonHour = 12
        static let previousDayOffset = -1
    }
    
    // MARK: - Properties
    private let repository: ApodRepository
    private let favoritesManager: FavoritesManager
    private let days: Int
    
    var items: [ApodItem] = []
    var isLoading = false
    var error: AppError?
    var favoriteIds: Set<String> = []

    // MARK: - Initialization
    init(repository: ApodRepository = ApodRepository(), 
         favoritesManager: FavoritesManager = FavoritesManager(),
         lastNDays: Int = Constants.defaultDaysToLoad) {
        self.repository = repository
        self.favoritesManager = favoritesManager
        self.days = max(lastNDays, Constants.minimumDaysToLoad)
        loadFavoriteIds()
    }

    // MARK: - Public Methods
    @MainActor func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let endDate = Date.nasaTodayDate
        let startDate = endDate.adding(days: -(days - Constants.minimumDaysToLoad))
        do { 
            items = try await repository.getApodRange(start: startDate, end: endDate)
            loadFavoriteIds()
        } catch { 
            self.error = AppError.from(error)
        }
    }
    
    @MainActor
    func toggleFavorite(_ item: ApodItem) async {
        await favoritesManager.toggleFavorite(item)
        
        if favoritesManager.isFavorite(item) {
            favoriteIds.insert(item.id)
        } else {
            favoriteIds.remove(item.id)
        }
        
        if let favoritesError = favoritesManager.error {
            self.error = favoritesError
        }
    }
    
    func isFavorite(_ item: ApodItem) -> Bool {
        favoriteIds.contains(item.id)
    }
    
    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    // MARK: - Private Methods
    private func loadFavoriteIds() {
        favoriteIds = favoritesManager.favoriteIds
    }
}
