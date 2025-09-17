import Foundation
import CoreData

protocol FavoritesStoring {
    func isFavorite(_ id: String) -> Bool
    func toggleFavorite(_ item: ApodItem)
    func all() -> [ApodItem]
    func count() -> Int
    func addFavorite(_ item: ApodItem) throws
    func removeFavorite(_ item: ApodItem) throws
}

final class CoreDataFavoritesStore: FavoritesStoring {
    // MARK: - Constants
    private enum Constants {
        static let maxFavorites = 1000
    }
    
    // MARK: - Properties
    private let coreDataStack: CoreDataStack
    
    // MARK: - Initialization
    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Public Methods
    func isFavorite(_ id: String) -> Bool {
        let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            let count = try coreDataStack.viewContext.count(for: request)
            return count > 0
        } catch {
            print("Error checking if favorite exists: \(error)")
            return false
        }
    }
    
    func toggleFavorite(_ item: ApodItem) {
        if isFavorite(item.id) {
            try? removeFavorite(item)
        } else {
            try? addFavorite(item)
        }
    }
    
    func addFavorite(_ item: ApodItem) throws {
        guard !isFavorite(item.id) else {
            return 
        }
        
        guard !item.id.isEmpty,
              !item.title.isEmpty,
              !item.explanation.isEmpty,
              !item.date.isEmpty,
              !item.mediaType.isEmpty else {
            throw FavoritesError.invalidData("ApodItem has invalid required fields")
        }
        
        let currentCount = count()
        guard currentCount < Constants.maxFavorites else {
            throw FavoritesError.limitExceeded
        }
        
        let context = coreDataStack.viewContext
        
        do {
            _ = try FavoriteAPOD(from: item, context: context)
            
            // Salvar diretamente - Core Data já fará validação automática
            try coreDataStack.save()
        } catch {
            context.rollback()
            throw FavoritesError.saveFailed(error)
        }
    }
    
    func removeFavorite(_ item: ApodItem) throws {
        let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", item.id)
        
        do {
            let favorites = try coreDataStack.viewContext.fetch(request)
            guard let favorite = favorites.first else {
                return
            }
            
            coreDataStack.viewContext.delete(favorite)
            try coreDataStack.save()
        } catch {
            coreDataStack.viewContext.rollback()
            throw FavoritesError.deleteFailed(error)
        }
    }
    
    func all() -> [ApodItem] {
        let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "savedAt", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            let favorites = try coreDataStack.viewContext.fetch(request)
            return favorites.map { $0.toApodItem() }
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    
    func count() -> Int {
        let request: NSFetchRequest<FavoriteAPOD> = FavoriteAPOD.fetchRequest()
        
        do {
            return try coreDataStack.viewContext.count(for: request)
        } catch {
            print("Error counting favorites: \(error)")
            return 0
        }
    }
}

enum FavoritesError: LocalizedError {
    case limitExceeded
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case invalidData(String)
    
    var errorDescription: String? {
        switch self {
        case .limitExceeded:
            return "Maximum number of favorites reached"
        case .saveFailed(let error):
            return "Failed to save favorite: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete favorite: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch favorites: \(error.localizedDescription)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }
}

