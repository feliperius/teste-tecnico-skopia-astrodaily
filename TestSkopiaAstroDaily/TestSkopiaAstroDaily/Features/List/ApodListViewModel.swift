import Foundation
import Observation

@Observable final class ApodListViewModel {
    private let service: NasaApodServicing
    private let days: Int

    var items: [ApodItem] = []
    var isLoading = false
    var error: String?

    init(service: NasaApodServicing = NasaApodService(), lastNDays: Int = 20) {
        self.service = service
        self.days = max(lastNDays, 1)
    }

    @MainActor func load() async {
        isLoading = true; error = nil
        defer { isLoading = false }
        let end = Date()
        let start = end.adding(days: -(days - 1))
        do { items = try await service.fetchRange(start: start, end: end) }
        catch { self.error = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription }
    }
}
