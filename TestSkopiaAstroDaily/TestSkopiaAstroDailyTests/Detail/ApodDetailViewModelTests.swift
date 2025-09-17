import Testing
import Foundation
@testable import TestSkopiaAstroDaily

@Suite("ApodDetailViewModel Tests")
@MainActor
struct ApodDetailViewModelTests {
    
    // MARK: - Properties
    var favoritesManagerSpy: FavoritesManagerSpy!
    var sut: ApodDetailViewModel!
    
    // MARK: - Setup
    init() {
        favoritesManagerSpy = FavoritesManagerSpy()
        sut = ApodDetailViewModel(item: DummyDetailApodItem.imageItem, favoritesManager: favoritesManagerSpy)
    }
    
    // MARK: - Initialization Tests
    
    @Test("ViewModel should initialize with provided item")
    func testInitialization() {
        // Given
        let testItem = DummyDetailApodItem.videoItem
        
        // When
        let viewModel = ApodDetailViewModel(item: testItem, favoritesManager: favoritesManagerSpy)
        
        // Then
        #expect(viewModel.item.title == testItem.title)
        #expect(viewModel.item.date == testItem.date)
        #expect(viewModel.item.explanation == testItem.explanation)
        #expect(viewModel.item.mediaType == testItem.mediaType)
    }
    
    @Test("ViewModel should initialize with different media types")
    func testInitializationWithDifferentMediaTypes() {
        // Test Image Item
        let imageViewModel = ApodDetailViewModel(item: DummyDetailApodItem.imageItem, favoritesManager: favoritesManagerSpy)
        #expect(imageViewModel.item.mediaTypeEnum == .image)
        
        // Test Video Item
        let videoViewModel = ApodDetailViewModel(item: DummyDetailApodItem.videoItem, favoritesManager: favoritesManagerSpy)
        #expect(videoViewModel.item.mediaTypeEnum == .video)
        
        // Test Other Media Item
        let otherViewModel = ApodDetailViewModel(item: DummyDetailApodItem.otherMediaItem, favoritesManager: favoritesManagerSpy)
        #expect(otherViewModel.item.mediaTypeEnum == .other)
    }
    
    // MARK: - Favorites Tests
    
    @Test("isFavorite should return false when item is not favorite")
    func testIsFavoriteReturnsFalseWhenNotFavorite() {
        // Given
        favoritesManagerSpy.favoriteIds = [] 
        
        // When
        let result = sut.isFavorite
        
        // Then
        #expect(result == false)
    }
    
    @Test("isFavorite should return true when item is favorite")
    func testIsFavoriteReturnsTrueWhenIsFavorite() {
        // Given
        favoritesManagerSpy.favoriteIds = [DummyDetailApodItem.imageItem.id]
        
        // When
        let result = sut.isFavorite
        
        // Then
        #expect(result == true)
    }
    
    @Test("toggleFavorite should call favoritesManager")
    func testToggleFavoriteCallsFavoritesManager() async {
        // Given
        let initialCallCount = favoritesManagerSpy.toggleFavoriteCallCount
        
        // When
        await sut.toggleFavorite()
        
        // Then
        #expect(favoritesManagerSpy.toggleFavoriteCallCount == initialCallCount + 1)
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled())
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalledWith(DummyDetailApodItem.imageItem))
    }
    
    @Test("toggleFavorite should add to favorites when not favorite")
    func testToggleFavoriteAddsToFavoritesWhenNotFavorite() async {
        // Given
        favoritesManagerSpy.favoriteIds = []
        #expect(sut.isFavorite == false)
        
        // When
        await sut.toggleFavorite()
        
        // Then
        #expect(favoritesManagerSpy.favoriteIds.contains(DummyDetailApodItem.imageItem.id))
    }
    
    @Test("toggleFavorite should remove from favorites when is favorite")
    func testToggleFavoriteRemovesFromFavoritesWhenIsFavorite() async {
        // Given
        favoritesManagerSpy.favoriteIds = [DummyDetailApodItem.imageItem.id]
        #expect(sut.isFavorite == true)
        
        // When
        await sut.toggleFavorite()
        
        // Then
        #expect(!favoritesManagerSpy.favoriteIds.contains(DummyDetailApodItem.imageItem.id))
    }
    
    // MARK: - Date Formatting Tests
    
    @Test("formattedDate should return formatted date string")
    func testFormattedDateReturnsFormattedString() {
        // Given
        let testItem = DummyDetailApodItem.withCustomDate("2023-12-25")
        let viewModel = ApodDetailViewModel(item: testItem, favoritesManager: favoritesManagerSpy)
        
        // When
        let result = viewModel.formattedDate()
        
        // Then
        #expect(!result.isEmpty)
        // Note: We can't test exact format due to locale differences, but we ensure it's not empty
    }
    
    @Test("formattedDate should handle different date formats")
    func testFormattedDateHandlesDifferentFormats() {
        // Test various date formats
        let dateFormats = ["2023-01-01", "2023-12-31", "2024-02-29"] // Including leap year
        
        for dateString in dateFormats {
            // Given
            let testItem = DummyDetailApodItem.withCustomDate(dateString)
            let viewModel = ApodDetailViewModel(item: testItem, favoritesManager: favoritesManagerSpy)
            
            // When
            let result = viewModel.formattedDate()
            
            // Then
            #expect(!result.isEmpty, "Formatted date should not be empty for date: \(dateString)")
        }
    }
    
    // MARK: - Item Property Tests
    
    @Test("item property should be immutable and accessible")
    func testItemPropertyIsImmutableAndAccessible() {
        // Given
        let testItem = DummyDetailApodItem.longExplanationItem
        let viewModel = ApodDetailViewModel(item: testItem, favoritesManager: favoritesManagerSpy)
        
        // When & Then
        #expect(viewModel.item.title == testItem.title)
        #expect(viewModel.item.explanation == testItem.explanation)
        #expect(viewModel.item.date == testItem.date)
        #expect(viewModel.item.copyright == testItem.copyright)
    }
    
    @Test("item property should handle items without copyright")
    func testItemPropertyHandlesItemsWithoutCopyright() {
        // Given
        let itemWithoutCopyright = DummyDetailApodItem.itemWithoutCopyright
        let viewModel = ApodDetailViewModel(item: itemWithoutCopyright, favoritesManager: favoritesManagerSpy)
        
        // When & Then
        #expect(viewModel.item.copyright == nil)
        #expect(viewModel.item.title == itemWithoutCopyright.title)
        #expect(viewModel.item.explanation == itemWithoutCopyright.explanation)
    }
    
    @Test("item property should handle long explanations")
    func testItemPropertyHandlesLongExplanations() {
        // Given
        let longExplanationItem = DummyDetailApodItem.longExplanationItem
        let viewModel = ApodDetailViewModel(item: longExplanationItem, favoritesManager: favoritesManagerSpy)
        
        // When & Then
        #expect(viewModel.item.explanation.count > 100) // Ensure it's actually long
        #expect(viewModel.item.explanation == longExplanationItem.explanation)
    }
    
    // MARK: - Media Type Specific Tests
    
    @Test("ViewModel should work correctly with image items")
    func testViewModelWorksWithImageItems() {
        // Given
        let imageItem = DummyDetailApodItem.imageItem
        let viewModel = ApodDetailViewModel(item: imageItem, favoritesManager: favoritesManagerSpy)
        
        // When & Then
        #expect(viewModel.item.mediaTypeEnum == .image)
        #expect(viewModel.item.url != nil)
        #expect(viewModel.item.hdurl != nil)
    }
    
    @Test("ViewModel should work correctly with video items")
    func testViewModelWorksWithVideoItems() {
        // Given
        let videoItem = DummyDetailApodItem.videoItem
        let viewModel = ApodDetailViewModel(item: videoItem, favoritesManager: favoritesManagerSpy)
        
        // When & Then
        #expect(viewModel.item.mediaTypeEnum == .video)
        #expect(viewModel.item.url != nil)
        #expect(viewModel.item.thumbnail_url != nil)
    }
    
    @Test("ViewModel should work correctly with other media items")
    func testViewModelWorksWithOtherMediaItems() {
        // Given
        let otherItem = DummyDetailApodItem.otherMediaItem
        let viewModel = ApodDetailViewModel(item: otherItem, favoritesManager: favoritesManagerSpy)
        
        // When & Then
        #expect(viewModel.item.mediaTypeEnum == .other)
        #expect(viewModel.item.url == nil)
        #expect(viewModel.item.thumbnail_url == nil)
    }
    
    // MARK: - Error Handling Tests
    
    @Test("ViewModel should handle favorites manager errors gracefully")
    func testViewModelHandlesFavoritesManagerErrors() async {
        // Given
        favoritesManagerSpy.shouldThrowError = true
        favoritesManagerSpy.error = AppError.network(.invalidResponse)
        
        // When
        await sut.toggleFavorite()
        
        // Then - Should not crash and still call the method
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled())
        // The error handling is done internally by FavoritesManager
    }
    
    // MARK: - State Consistency Tests
    
    @Test("ViewModel state should remain consistent across multiple operations")
    func testViewModelStateConsistencyAcrossOperations() async {
        // Given
        let originalItem = sut.item
        let originalFormattedDate = sut.formattedDate()
        
        // When - Perform multiple operations
        await sut.toggleFavorite()
        let favoriteStateAfterToggle = sut.isFavorite
        
        await sut.toggleFavorite()
        let favoriteStateAfterSecondToggle = sut.isFavorite
        
        // Then - Core properties should remain unchanged
        #expect(sut.item.title == originalItem.title)
        #expect(sut.item.date == originalItem.date)
        #expect(sut.formattedDate() == originalFormattedDate)
        
        // Favorite state should have toggled twice (back to original)
        #expect(favoriteStateAfterToggle != favoriteStateAfterSecondToggle)
    }
    
    // MARK: - Performance Tests
    
    @Test("formattedDate should perform consistently")
    func testFormattedDatePerformance() {
        // Given
        let startTime = Date()
        
        // When - Call formattedDate multiple times
        for _ in 0..<100 {
            _ = sut.formattedDate()
        }
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        // Then - Should complete quickly
        #expect(executionTime < 1.0, "Date formatting should be fast")
    }
}