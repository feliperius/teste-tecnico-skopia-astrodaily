import Foundation
import Observation

@Observable final class ApodListViewModel {
    private let repository: ApodRepository
    private let days: Int

    var items: [ApodItem] = []
    var isLoading = false
    var error: AppError?

    init(repository: ApodRepository = ApodRepository(), lastNDays: Int = 20) {
        self.repository = repository
        self.days = max(lastNDays, 1)
    }

    @MainActor func load() async {
        isLoading = true
        error = nil
        defer { isLoading = false }
        
        let today = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: today)
        
        let endDate: Date
        if let hour = components.hour, hour < 12 {
            endDate = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        } else {
            endDate = today
        }
        
        let startDate = endDate.adding(days: -(days - 1))
        
        do { 
            items = try await repository.getApodRange(start: startDate, end: endDate)
        } catch { 
            self.error = AppError.from(error)
        }
    }
}
