import Foundation
import Observation

@Observable final class FeedViewModel {
    private let repository: ApodRepositoryProtocol
    private let favoritesManager: FavoritesManagerProtocol

    var currentDate: Date = Date()
    var item: ApodItem?
    var isLoading = false
    var error: AppError?
    
    var isToday: Bool {
        return currentDate.isNasaToday() || currentDate > Date.nasaTodayDate
    }

    init(repository: ApodRepositoryProtocol = ApodRepository(),
         favoritesManager: FavoritesManagerProtocol = FavoritesManager()) {
        self.repository = repository
        self.favoritesManager = favoritesManager
        self.currentDate = Date.nasaTodayDate
        print("📅 FeedViewModel: Data inicial definida como hoje (NASA timezone): \(currentDate.apodString)")
    }

    @MainActor func loadTodayApod() async {
        print("🔄 FeedViewModel: Carregando foto do dia atual")
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            let result = try await repository.getCurrentApod()
            item = result.item
            currentDate = result.actualDate
            print("✅ FeedViewModel: Foto do dia carregada - \(item?.title ?? "nil")")
        } catch {
            print("❌ FeedViewModel: Erro ao carregar foto do dia - \(error)")
            self.error = AppError.from(error)
        }
    }

    @MainActor func load() async {
        print("🔄 FeedViewModel: Iniciando carregamento para \(currentDate.apodString)")
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            item = try await repository.getApod(for: currentDate)
            print("✅ FeedViewModel: Item carregado - \(item?.title ?? "nil")")
        } catch {
            print("❌ FeedViewModel: Erro ao carregar - \(error)")
            self.error = AppError.from(error)
        }
    }

    func prevDay() async { 
        currentDate = currentDate.adding(days: -1)
        await load()
    }
    
    func nextDay() async {
        guard !isToday else { return }
        currentDate = currentDate.adding(days: 1)
        await load()
    }

    func isFavorite() -> Bool { 
        guard let item = item else { return false }
        return favoritesManager.isFavorite(item)
    }
    
    func toggleFavorite() async { 
        guard let item = item else { return }
        await favoritesManager.toggleFavorite(item)
    }
    
    func formattedDate() -> String {
        guard let item = item else { return "" }
        return DateFormatter.localizedLong(fromAPIDateString: item.date)
    }
}

