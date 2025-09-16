import Foundation
import Observation

@Observable final class ApodRepository {
    private let service: NasaApodServicing
    private var cache: [String: ApodItem] = [:]
    
    init(service: NasaApodServicing = NasaApodService()) {
        self.service = service
    }
    
    func getApod(for date: Date) async throws -> ApodItem {
        let dateKey = date.apodString
        
        if let cached = cache[dateKey] {
            return cached
        }
    
        let item = try await service.fetchApod(date: date)
        cache[dateKey] = item
        return item
    }
    
    func getCurrentApod() async throws -> (item: ApodItem, actualDate: Date) {
        var dateToTry = Date()
        var attempts = 0
        let maxAttempts = 5
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: dateToTry)
        if let hour = components.hour, hour < 12 {
            dateToTry = calendar.date(byAdding: .day, value: -1, to: dateToTry) ?? dateToTry
        }
        
        while attempts < maxAttempts {
            do {
                let item = try await getApod(for: dateToTry)
                return (item, dateToTry)
            } catch let error as NetworkError {
                if case .http(404) = error {
                    dateToTry = dateToTry.adding(days: -1)
                    attempts += 1
                    print("🔄 ApodRepository: Tentando data anterior: \(dateToTry.apodString)")
                } else {
                    throw error
                }
            }
        }
        
        throw NetworkError.noDataForDate("últimos \(maxAttempts) dias")
    }

    func getApodRange(start: Date, end: Date) async throws -> [ApodItem] {
        let dateRange = start.daysUntil(end)
        let cachedItems = dateRange.compactMap { cache[$0.apodString] }
        
        if cachedItems.count == dateRange.count {
            return cachedItems.sorted { $0.date > $1.date }
        }
        
        let items = try await service.fetchRange(start: start, end: end)
        
        for item in items {
            cache[item.date] = item
        }
    
        return items
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

private extension Date {
    func daysUntil(_ endDate: Date) -> [Date] {
        var dates: [Date] = []
        var current = self
        while current <= endDate {
            dates.append(current)
            current = current.adding(days: 1)
        }
        return dates
    }
}
