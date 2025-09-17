import Testing
import Foundation
@testable import TestSkopiaAstroDaily

@Suite("Feed Integration Tests")
@MainActor
struct FeedIntegrationTests {
    
    // MARK: - Properties
    var repositorySpy: ApodRepositorySpy!
    var favoritesManagerSpy: FavoritesManagerSpy!
    var sut: FeedViewModel!
    
    // MARK: - Setup
    init() {
        repositorySpy = ApodRepositorySpy()
        favoritesManagerSpy = FavoritesManagerSpy()
        sut = FeedViewModel(repository: repositorySpy, favoritesManager: favoritesManagerSpy)
    }
    
    @Test("Complete flow: Load today -> Navigate to previous day -> Toggle favorite")
    func testCompleteUserFlow() async {
        // Given
        let todayItem = DummyApodItem.withDate("2023-09-16")
        let yesterdayItem = DummyApodItem.withDate("2023-09-15")
        
        repositorySpy.mockItems = [todayItem]
        
        await sut.loadTodayApod()
        
        #expect(sut.item?.date == todayItem.date)
        
        repositorySpy.mockItems = [yesterdayItem]
        await sut.prevDay()
        
        #expect(sut.item?.date == yesterdayItem.date)
        
        await sut.toggleFavorite()
        
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled())
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalledWith(yesterdayItem))
    }
    
    @Test("Navigation sequence: Previous -> Previous -> Next -> Next")
    func testNavigationSequence() async {
        // Given
        let startDate = Date().adding(days: -3)
        sut.currentDate = startDate
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        // When - Navigate previous twice
        await sut.prevDay()
        await sut.prevDay()
        
        // Then - Should be 2 days earlier
        let expectedAfterPrev = startDate.adding(days: -2)
        #expect(sut.currentDate.apodString == expectedAfterPrev.apodString)
        
        // When - Navigate next twice
        await sut.nextDay()
        await sut.nextDay()
        
        // Then - Should be back to start date
        #expect(sut.currentDate.apodString == startDate.apodString)
    }
    
    // MARK: - Error Recovery Tests
    
    @Test("Error recovery: Network failure -> Retry -> Success")
    func testErrorRecoveryFlow() async {
        repositorySpy.shouldThrowError = true
        repositorySpy.errorToThrow = DummyError.networkError
        
        await sut.loadTodayApod()
        
        #expect(sut.error != nil)
        #expect(sut.item == nil)
        
        repositorySpy.shouldThrowError = false
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        await sut.loadTodayApod()
        
        #expect(sut.error == nil)
        #expect(sut.item?.title == DummyApodItem.sample.title)
    }
    
}

@Suite("Feed Edge Cases Tests")
@MainActor  
struct FeedEdgeCasesTests {
    
    // MARK: - Properties
    var repositorySpy: ApodRepositorySpy!
    var favoritesManagerSpy: FavoritesManagerSpy!
    var sut: FeedViewModel!
    
    // MARK: - Setup
    init() {
        repositorySpy = ApodRepositorySpy()
        favoritesManagerSpy = FavoritesManagerSpy()
        sut = FeedViewModel(repository: repositorySpy, favoritesManager: favoritesManagerSpy)
    }
    
    // MARK: - Basic Tests
    
    @Test("Handling nil item operations")
    func testNilItemOperations() async {
        // Given
        sut.item = nil
        
        // When & Then - Should handle gracefully
        #expect(sut.isFavorite() == false)
        #expect(sut.formattedDate() == "")
        
        await sut.toggleFavorite()
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled(times: 0))
    }
    
    @Test("Navigation at NASA timezone boundaries")
    func testNavigationAtTimezoneBoundaries() async {
        // Given - Current date is NASA today
        sut.currentDate = Date.nasaTodayDate
        
        // When - Try to navigate next (should be blocked)
        let initialDate = sut.currentDate
        await sut.nextDay()
        
        // Then - Date should not change
        #expect(sut.currentDate.apodString == initialDate.apodString)
        #expect(sut.isToday == true)
        
        // When - Navigate previous (should work)
        await sut.prevDay()
        
        // Then - Date should change and no longer be today
        let expectedPrevDate = initialDate.adding(days: -1)
        #expect(sut.currentDate.apodString == expectedPrevDate.apodString)
        #expect(sut.isToday == false)
    }
}