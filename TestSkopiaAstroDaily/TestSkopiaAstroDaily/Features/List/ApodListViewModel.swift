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
        
        // Load initial favorite state
        loadFavoriteIds()
    }

    // MARK: - Public Methods
    @MainActor func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: today)
        
        let endDate: Date
        if let hour = components.hour, hour < Constants.noonHour {
            endDate = calendar.date(byAdding: .day, value: Constants.previousDayOffset, to: today) ?? today
        } else {
            endDate = today
        }
        
        let startDate = endDate.adding(days: -(days - Constants.minimumDaysToLoad))
        
        do { 
            items = try await repository.getApodRange(start: startDate, end: endDate)
            loadFavoriteIds() // Refresh favorite state after loading items
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
