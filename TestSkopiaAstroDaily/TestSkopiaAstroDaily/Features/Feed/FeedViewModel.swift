import Foundation
import Observation

@Observable final class FeedViewModel {
    private let service: NasaApodServicing
    private let favorites: FavoritesStoring

    var currentDate: Date = Date()
    var item: ApodItem?
    var isLoading = false
    var error: String?
    
    var isToday: Bool {
        let calendar = Calendar.current
        let today = Date()
        return calendar.isDate(currentDate, inSameDayAs: today) || currentDate > today
    }

    init(service: NasaApodServicing = NasaApodService(),
         favorites: FavoritesStoring = UserDefaultsFavoritesStore()) {
        self.service = service; self.favorites = favorites
        self.currentDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        print("📅 FeedViewModel: Data inicial definida como hoje: \(currentDate.apodString)")
    }

    @MainActor func loadTodayApod() async {
        print("🔄 FeedViewModel: Carregando foto do dia atual")
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        do {
            item = try await service.fetchApod(date: currentDate)
            print("✅ FeedViewModel: Foto do dia carregada - \(item?.title ?? "nil")")
            // Atualiza a data atual baseada na resposta
            if let itemDate = item?.date, let date = Date.from(apodString: itemDate) {
                currentDate = date
                print("📅 FeedViewModel: Data atual atualizada para: \(currentDate.apodString)")
            }
        } catch let err as NetworkError {
            print("❌ FeedViewModel: Erro ao carregar foto do dia - \(err)")
            self.error = err.errorDescription
            // Se falhar, tenta carregar uma data específica
            await load()
        } catch {
            print("❌ FeedViewModel: Erro inesperado ao carregar foto do dia: \(error)")
            self.error = error.localizedDescription
        }
    }

    @MainActor func load() async {
        print("🔄 FeedViewModel: Iniciando carregamento para \(currentDate.apodString)")
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        var dateToTry = currentDate
        var attempts = 0
        let maxAttempts = 5
        
        while attempts < maxAttempts {
            print("🔄 FeedViewModel: Tentativa \(attempts + 1) para data \(dateToTry.apodString)")
            do { 
                item = try await service.fetchApod(date: dateToTry)
                print("✅ FeedViewModel: Item carregado - \(item?.title ?? "nil")")
                // Se chegou aqui, foi bem-sucedido
                if dateToTry != currentDate {
                    // Atualiza a data atual para a data que funcionou
                    print("📅 FeedViewModel: Atualizando data atual para \(dateToTry.apodString)")
                    currentDate = dateToTry
                }
                return
            }
            catch let err as NetworkError {
                print("❌ FeedViewModel: Erro NetworkError - \(err)")
                if case .http(404) = err {
                    // Data não tem dados, tenta dia anterior
                    dateToTry = dateToTry.adding(days: -1)
                    attempts += 1
                    print("🔄 FeedViewModel: Tentando data anterior: \(dateToTry.apodString)")
                } else {
                    // Outro erro de rede
                    self.error = err.errorDescription
                    print("❌ FeedViewModel: Erro de rede: \(err.errorDescription ?? "unknown")")
                    return
                }
            }
            catch {
                // Erro inesperado
                print("❌ FeedViewModel: Erro inesperado: \(error)")
                self.error = error.localizedDescription
                return
            }
        }
        
        // Se chegou aqui, não conseguiu carregar nenhuma data
        print("❌ FeedViewModel: Falhou em carregar após \(maxAttempts) tentativas")
        self.error = "Não foi possível carregar dados para as datas recentes"
    }

    func prevDay() { 
        currentDate = currentDate.adding(days: -1)
        Task { await load() } 
    }
    
    func nextDay() {
        guard !isToday else { return }
        currentDate = currentDate.adding(days: 1)
        Task { await load() }
    }

    func isFavorite() -> Bool { favorites.isFavorite(item?.id ?? "") }
    func toggleFavorite() { if let it = item { favorites.toggleFavorite(it) } }
}

