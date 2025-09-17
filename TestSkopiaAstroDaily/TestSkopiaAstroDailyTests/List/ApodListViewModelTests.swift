import Testing
import Foundation
@testable import TestSkopiaAstroDaily

@MainActor
struct ApodListViewModelTests {
    
    @Test("ViewModel should initialize with correct default values")
    func testInitialization() {
        let repositorySpy = ApodRepositorySpy()
        let favoritesManagerSpy = FavoritesManagerSpy()
        let viewModel = ApodListViewModel(repository: repositorySpy, favoritesManager: favoritesManagerSpy)
        
        #expect(viewModel.items.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(repositorySpy.verifyGetApodRangeWasCalled(times: 0))
    }
    
    @Test("Should load items successfully")
    func testLoadSuccess() async {
        let repositorySpy = ApodRepositorySpy()
        let favoritesManagerSpy = FavoritesManagerSpy()
        
        let mockItems = [
            ApodItem.mock(date: "2023-09-16", title: "APOD 1"),
            ApodItem.mock(date: "2023-09-15", title: "APOD 2")
        ]
        repositorySpy.mockItems = mockItems
        
        let viewModel = ApodListViewModel(repository: repositorySpy, favoritesManager: favoritesManagerSpy, lastNDays: 5)
        
        await viewModel.load()
        
        #expect(viewModel.items.count == 2)
        #expect(viewModel.items[0].title == "APOD 1")
        #expect(viewModel.items[1].title == "APOD 2")
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(repositorySpy.verifyGetApodRangeWasCalled(times: 1))
        #expect(repositorySpy.verifyDateRangeCalculation(expectedDays: 5))
    }
    
    @Test("Should handle toggle favorite")
    func testToggleFavorite() async {
        let repositorySpy = ApodRepositorySpy()
        let favoritesManagerSpy = FavoritesManagerSpy()
        let viewModel = ApodListViewModel(repository: repositorySpy, favoritesManager: favoritesManagerSpy)
        
        let item = ApodItem.mock(date: "2023-09-16")
        
        await viewModel.toggleFavorite(item)
        
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled(times: 1))
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalledWith(item))
        #expect(viewModel.favoriteIds.contains(item.id) == true)
        #expect(viewModel.error == nil)
    }
}

extension ApodItem {
    static func mock(
        date: String = "2023-09-16",
        title: String = "Test APOD",
        explanation: String = "Test explanation",
        mediaType: String = "image",
        url: String = "https://example.com/image.jpg"
    ) -> ApodItem {
        return ApodItem(
            date: date,
            explanation: explanation,
            hdurl: "https://example.com/hd_image.jpg",
            copyright: "Test Copyright",
            thumbnail_url: nil,
            mediaType: mediaType,
            serviceVersion: "v1",
            title: title,
            url: url
        )
    }
}

// MARK: - Test SPY Objects
@MainActor
final class ApodRepositorySpy: ApodRepositoryProtocol {
    private(set) var getApodRangeCallCount = 0
    private(set) var getApodRangeCalls: [(start: Date, end: Date)] = []
    private(set) var lastStartDate: Date?
    private(set) var lastEndDate: Date?
    
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.invalidResponse
    var mockItems: [ApodItem] = []
    
    func getApodRange(start: Date, end: Date) async throws -> [ApodItem] {
        getApodRangeCallCount += 1
        getApodRangeCalls.append((start: start, end: end))
        lastStartDate = start
        lastEndDate = end
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockItems
    }
    
    func getCurrentApod() async throws -> (item: ApodItem, actualDate: Date) {
        if shouldThrowError {
            throw errorToThrow
        }
        
        let item = mockItems.first ?? ApodItem.mock()
        return (item: item, actualDate: Date.nasaTodayDate)
    }
    
    func getApod(for date: Date) async throws -> ApodItem {
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockItems.first ?? ApodItem.mock()
    }
    
    func verifyGetApodRangeWasCalled(times: Int = 1) -> Bool {
        return getApodRangeCallCount == times
    }
    
    func verifyDateRangeCalculation(expectedDays: Int) -> Bool {
        guard let start = lastStartDate, let end = lastEndDate else { return false }
        let daysDifference = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        return daysDifference == (expectedDays - 1)
    }
}

final class FavoritesManagerSpy: FavoritesManagerProtocol {
    var favoriteIds: Set<String> = []
    var favoriteItems: [ApodItem] = []
    var error: AppError?
    
    private(set) var toggleFavoriteCallCount = 0
    private(set) var toggleFavoriteCalls: [ApodItem] = []
    
    var shouldThrowError = false
    
    func isFavorite(_ id: String) -> Bool {
        return favoriteIds.contains(id)
    }
    
    func isFavorite(_ item: ApodItem) -> Bool {
        return favoriteIds.contains(item.id)
    }
    
    func toggleFavorite(_ item: ApodItem) async {
        toggleFavoriteCallCount += 1
        toggleFavoriteCalls.append(item)
        
        if shouldThrowError {
            error = AppError.network(.invalidResponse)
            return
        }
        
        if favoriteIds.contains(item.id) {
            favoriteIds.remove(item.id)
            favoriteItems.removeAll { $0.id == item.id }
        } else {
            favoriteIds.insert(item.id)
            favoriteItems.append(item)
        }
    }
    
    func addFavorite(_ item: ApodItem) async throws {
        if shouldThrowError {
            throw AppError.network(.invalidResponse)
        }
        favoriteIds.insert(item.id)
        favoriteItems.append(item)
    }
    
    func removeFavorite(_ item: ApodItem) async throws {
        if shouldThrowError {
            throw AppError.network(.invalidResponse)
        }
        favoriteIds.remove(item.id)
        favoriteItems.removeAll { $0.id == item.id }
    }
    
    func reload() {}
    
    var favoriteCount: Int {
        return favoriteIds.count
    }
    
    func verifyToggleFavoriteWasCalled(times: Int = 1) -> Bool {
        return toggleFavoriteCallCount == times
    }
    
    func verifyToggleFavoriteWasCalledWith(_ item: ApodItem) -> Bool {
        return toggleFavoriteCalls.contains { $0.id == item.id }
    }
}
