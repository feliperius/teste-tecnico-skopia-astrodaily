import Foundation
import CoreData

extension FavoriteAPOD {
    // MARK: - Initialization
    convenience init(from apodItem: ApodItem, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = apodItem.id
        self.title = apodItem.title
        self.explanation = apodItem.explanation
        self.date = apodItem.date
        self.mediaType = apodItem.mediaType
        self.url = apodItem.url ?? ""
        self.hdurl = apodItem.hdurl
        self.copyright = apodItem.copyright
        self.savedAt = Date()
    }
    
    func toApodItem() -> ApodItem {
        return ApodItem(
            date: date ?? "",
            explanation: explanation ?? "",
            hdurl: hdurl,
            copyright: copyright,
            thumbnail_url: nil,
            mediaType: mediaType ?? "image",
            serviceVersion: nil,
            title: title ?? "",
            url: url?.isEmpty == true ? nil : url // Converte string vazia de volta para nil
        )
    }

    static func fetchByID(_ id: String, context: NSManagedObjectContext) -> FavoriteAPOD? {
        let request = NSFetchRequest<FavoriteAPOD>(entityName: "FavoriteAPOD")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            return try context.fetch(request).first
        } catch {
            print("Error fetching favorite by ID: \(error)")
            return nil
        }
    }
    
    static func fetchAll(context: NSManagedObjectContext) -> [FavoriteAPOD] {
        let request = NSFetchRequest<FavoriteAPOD>(entityName: "FavoriteAPOD")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteAPOD.savedAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching all favorites: \(error)")
            return []
        }
    }
    
    static func count(context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<FavoriteAPOD>(entityName: "FavoriteAPOD")
        
        do {
            return try context.count(for: request)
        } catch {
            print("Error counting favorites: \(error)")
            return 0
        }
    }
}
