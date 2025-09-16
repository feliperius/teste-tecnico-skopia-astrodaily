import Foundation
import Observation

@Observable final class FavoritesManager {
    // MARK: - Properties
    private let store: FavoritesStoring
    var favoriteIds: Set<String> = []
    var favoriteItems: [ApodItem] = []
    var error: AppError?
    
    // MARK: - Initialization
    init(store: FavoritesStoring = CoreDataFavoritesStore()) {
        self.store = store
        loadFavorites()
    }
    
    // MARK: - Public Methods
    func isFavorite(_ id: String) -> Bool {
        favoriteIds.contains(id)
    }
    
    func isFavorite(_ item: ApodItem) -> Bool {
        isFavorite(item.id)
    }
    
    @MainActor
    func toggleFavorite(_ item: ApodItem) async {
        error = nil
        
        do {
            if isFavorite(item) {
                try await removeFavorite(item)
            } else {
                try await addFavorite(item)
            }
        } catch {
            self.error = AppError.from(error)
        }
    }
    
    @MainActor
    func addFavorite(_ item: ApodItem) async throws {
        try await performFavoriteOperation {
            try self.store.addFavorite(item)
        }
    }
    
    @MainActor
    func removeFavorite(_ item: ApodItem) async throws {
        try await performFavoriteOperation {
            try self.store.removeFavorite(item)
        }
    }
    
    func reload() {
        loadFavorites()
    }
    
    var favoriteCount: Int {
        favoriteIds.count
    }
    
    // MARK: - Private Methods
    private func loadFavorites() {
        favoriteItems = store.all()
        favoriteIds = Set(favoriteItems.map(\.id))
    }
    
    @MainActor
    private func performFavoriteOperation(_ operation: @escaping () throws -> Void) async throws {
        try await Task.detached { [weak self] in
            try operation()
            
            await MainActor.run { [weak self] in
                self?.loadFavorites()
            }
        }.value
    }
}
