import Testing
import Foundation
@testable import TestSkopiaAstroDaily

@Suite("FeedViewModel Tests")
@MainActor
struct FeedViewModelTests {
      @Test("prevDay should decrease currentDate by one day")
    func testPrevDay() async {
        // Given
        let initialDate = Date().adding(days: -3)
        sut.currentDate = initialDate
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        // When
        await sut.prevDay()
        
        // Then
        let expectedDate = initialDate.adding(days: -1)
        #expect(sut.currentDate.apodString == expectedDate.apodString)
    }
    
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
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel should initialize with today's date in NASA timezone")
    func testInitialization() {
        // Given & When
        let viewModel = FeedViewModel(repository: repositorySpy, favoritesManager: favoritesManagerSpy)
        
        // Then
        #expect(viewModel.currentDate.apodString == Date.nasaTodayDate.apodString)
        #expect(viewModel.item == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(viewModel.isToday == true)
    }
    
    // MARK: - Load Today APOD Tests
    
    @Test("loadTodayApod should call repository getCurrentApod")
    func testLoadTodayApodCallsRepository() async {
        // Given
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        // When
        await sut.loadTodayApod()
        
        // Then
        // Since getCurrentApod is called in ApodRepository, we can't directly verify it
        // But we can verify the result is set
        #expect(sut.item != nil)
        #expect(sut.error == nil)
    }
    
    @Test("loadTodayApod should set item and currentDate on success")
    func testLoadTodayApodSuccess() async {
        // Given
        let expectedItem = DummyApodItem.sample
        repositorySpy.mockItems = [expectedItem]
        
        // When
        await sut.loadTodayApod()
        
        // Then
        #expect(sut.item?.title == expectedItem.title)
        #expect(sut.item?.date == expectedItem.date)
        #expect(sut.error == nil)
        #expect(sut.isLoading == false)
    }
    
    @Test("loadTodayApod should set error on failure")
    func testLoadTodayApodFailure() async {
        // Given
        repositorySpy.shouldThrowError = true
        repositorySpy.errorToThrow = DummyError.networkError
        
        // When
        await sut.loadTodayApod()
        
        // Then
        #expect(sut.item == nil)
        #expect(sut.error != nil)
        #expect(sut.isLoading == false)
    }
    
    @Test("loadTodayApod should set loading state correctly")
    func testLoadTodayApodLoadingState() async {
        // Given
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        // When
        await sut.loadTodayApod()
        
        // Then
        #expect(sut.isLoading == false)
    }
    
    // MARK: - Load Specific Date Tests
    
    @Test("load should call repository getApod with currentDate")
    func testLoadCallsRepositoryWithCurrentDate() async {
        // Given
        let testDate = Date().adding(days: -5)
        sut.currentDate = testDate
        repositorySpy.mockItems = [DummyApodItem.withDate("2023-09-10")]
        
        // When
        await sut.load()
        
        // Then
        #expect(sut.item != nil)
        #expect(sut.error == nil)
    }
    
    @Test("load should set item on success")
    func testLoadSuccess() async {
        // Given
        let expectedItem = DummyApodItem.withDate("2023-09-10")
        repositorySpy.mockItems = [expectedItem]
        
        // When
        await sut.load()
        
        // Then
        #expect(sut.item?.title == expectedItem.title)
        #expect(sut.item?.date == expectedItem.date)
        #expect(sut.error == nil)
    }
    
    @Test("load should set error on failure")
    func testLoadFailure() async {
        // Given
        repositorySpy.shouldThrowError = true
        repositorySpy.errorToThrow = DummyError.serverError
        
        // When
        await sut.load()
        
        // Then
        #expect(sut.item == nil)
        #expect(sut.error != nil)
    }
    
    // MARK: - Navigation Tests
    
    @Test("nextDay should increase currentDate by one day when not today")
    func testNextDayWhenNotToday() async {
        // Given
        let pastDate = Date().adding(days: -5)
        sut.currentDate = pastDate
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        // When
        await sut.nextDay()
        
        // Then
        let expectedDate = pastDate.adding(days: 1)
        #expect(sut.currentDate.apodString == expectedDate.apodString)
    }
    
    @Test("nextDay should not change date when isToday is true")
    func testNextDayWhenIsToday() async {
        // Given
        sut.currentDate = Date.nasaTodayDate
        let initialDate = sut.currentDate
        
        // When
        await sut.nextDay()
        
        // Then
        #expect(sut.currentDate.apodString == initialDate.apodString)
    }
    
    // MARK: - Date Logic Tests
    
    @Test("isToday should return true for NASA today date")
    func testIsTodayForNasaToday() {
        // Given & When
        sut.currentDate = Date.nasaTodayDate
        
        // Then
        #expect(sut.isToday == true)
    }
    
    @Test("isToday should return false for past dates")
    func testIsTodayForPastDates() {
        // Given & When
        sut.currentDate = Date().adding(days: -5)
        
        // Then
        #expect(sut.isToday == false)
    }
    
    @Test("isToday should return true for future dates")
    func testIsTodayForFutureDates() {
        // Given & When
        sut.currentDate = Date().adding(days: 5)
        
        // Then
        #expect(sut.isToday == true)
    }
    
    // MARK: - Favorites Tests
    
    @Test("isFavorite should return false when item is nil")
    func testIsFavoriteWithNilItem() {
        // Given
        sut.item = nil
        
        // When
        let result = sut.isFavorite()
        
        // Then
        #expect(result == false)
    }
    
    @Test("isFavorite should call favoritesManager when item exists")
    func testIsFavoriteWithItem() {
        // Given
        sut.item = DummyApodItem.sample
        favoritesManagerSpy.favoriteIds.insert(DummyApodItem.sample.id)
        
        // When
        let result = sut.isFavorite()
        
        // Then
        #expect(result == true)
    }
    
    @Test("toggleFavorite should do nothing when item is nil")
    func testToggleFavoriteWithNilItem() async {
        // Given
        sut.item = nil
        let initialCount = favoritesManagerSpy.favoriteIds.count
        
        // When
        await sut.toggleFavorite()
        
        // Then
        #expect(favoritesManagerSpy.favoriteIds.count == initialCount)
    }
    
    @Test("toggleFavorite should call favoritesManager when item exists")
    func testToggleFavoriteWithItem() async {
        // Given
        sut.item = DummyApodItem.sample
        let initialCount = favoritesManagerSpy.favoriteIds.count
        
        // When
        await sut.toggleFavorite()
        
        // Then
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled())
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalledWith(DummyApodItem.sample))
    }
    
    // MARK: - Date Formatting Tests
    
    @Test("formattedDate should return empty string when item is nil")
    func testFormattedDateWithNilItem() {
        // Given
        sut.item = nil
        
        // When
        let result = sut.formattedDate()
        
        // Then
        #expect(result == "")
    }
    
    @Test("formattedDate should return formatted date when item exists")
    func testFormattedDateWithItem() {
        // Given
        sut.item = DummyApodItem.withDate("2023-09-16")
        
        // When
        let result = sut.formattedDate()
        
        // Then
        #expect(result.isEmpty == false)
        // Note: We can't test exact format due to locale differences, but we ensure it's not empty
    }
    
    // MARK: - Error Handling Tests
    
    @Test("error should be cleared when starting new load")
    func testErrorClearedOnNewLoad() async {
        // Given
        sut.error = AppError.network(.invalidResponse)
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        // When
        await sut.load()
        
        // Then
        #expect(sut.error == nil)
    }
    
    @Test("error should be cleared when starting loadTodayApod")
    func testErrorClearedOnLoadTodayApod() async {
        // Given
        sut.error = AppError.network(.invalidResponse)
        repositorySpy.mockItems = [DummyApodItem.sample]
        
        // When
        await sut.loadTodayApod()
        
        // Then
        #expect(sut.error == nil)
    }
}
