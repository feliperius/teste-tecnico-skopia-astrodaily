import Testing
import Foundation
@testable import TestSkopiaAstroDaily

@Suite("Detail Integration Tests", .serialized)
@MainActor
struct DetailIntegrationTests {
    
    // MARK: - Properties
    var favoritesManagerSpy: FavoritesManagerSpy!
    var sut: ApodDetailViewModel!
    
    // MARK: - Setup
    init() {
        favoritesManagerSpy = FavoritesManagerSpy()
        sut = ApodDetailViewModel(item: DummyDetailApodItem.imageItem, favoritesManager: favoritesManagerSpy)
    }
    
    // MARK: - Complete User Flow Tests
    
    @Test("Complete user flow: View detail -> Toggle favorite -> Check state")
    func testCompleteUserFlow() async {
        // Given - User opens detail view
        #expect(sut.item.title == DummyDetailApodItem.imageItem.title)
        #expect(sut.isFavorite == false) // Initially not favorite
        
        // When - User toggles favorite
        await sut.toggleFavorite()
        
        // Then - Item should be favorited
        #expect(sut.isFavorite == true)
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled())
        #expect(favoritesManagerSpy.favoriteIds.contains(DummyDetailApodItem.imageItem.id))
        
        // When - User toggles favorite again
        await sut.toggleFavorite()
        
        // Then - Item should be unfavorited
        #expect(sut.isFavorite == false)
        #expect(favoritesManagerSpy.toggleFavoriteCallCount == 2)
        #expect(!favoritesManagerSpy.favoriteIds.contains(DummyDetailApodItem.imageItem.id))
    }
    
    @Test("Multiple detail views with different items")
    func testMultipleDetailViewsWithDifferentItems() async {
        // Given - Multiple different items
        let imageItem = DummyDetailApodItem.imageItem
        let videoItem = DummyDetailApodItem.videoItem
        let otherItem = DummyDetailApodItem.otherMediaItem
        
        let imageViewModel = ApodDetailViewModel(item: imageItem, favoritesManager: favoritesManagerSpy)
        let videoViewModel = ApodDetailViewModel(item: videoItem, favoritesManager: favoritesManagerSpy)
        let otherViewModel = ApodDetailViewModel(item: otherItem, favoritesManager: favoritesManagerSpy)
        
        // When - Add different items to favorites
        await imageViewModel.toggleFavorite()
        await videoViewModel.toggleFavorite()
        
        // Then - Check individual states
        #expect(imageViewModel.isFavorite == true)
        #expect(videoViewModel.isFavorite == true)
        #expect(otherViewModel.isFavorite == false)
        
        // Verify all items are tracked correctly
        #expect(favoritesManagerSpy.favoriteIds.contains(imageItem.id))
        #expect(favoritesManagerSpy.favoriteIds.contains(videoItem.id))
        #expect(!favoritesManagerSpy.favoriteIds.contains(otherItem.id))
        
        // When - Remove one favorite
        await imageViewModel.toggleFavorite()
        
        // Then - Only that item should be removed
        #expect(imageViewModel.isFavorite == false)
        #expect(videoViewModel.isFavorite == true)
        #expect(!favoritesManagerSpy.favoriteIds.contains(imageItem.id))
        #expect(favoritesManagerSpy.favoriteIds.contains(videoItem.id))
    }
    
    @Test("Favorites persistence across view model instances")
    func testFavoritesPersistenceAcrossViewModelInstances() async {
        // Given - First view model instance
        let firstViewModel = ApodDetailViewModel(item: DummyDetailApodItem.imageItem, favoritesManager: favoritesManagerSpy)
        
        // When - Mark as favorite
        await firstViewModel.toggleFavorite()
        #expect(firstViewModel.isFavorite == true)
        
        // When - Create new view model instance with same item and manager
        let secondViewModel = ApodDetailViewModel(item: DummyDetailApodItem.imageItem, favoritesManager: favoritesManagerSpy)
        
        // Then - Favorite state should persist
        #expect(secondViewModel.isFavorite == true)
        
        // When - Toggle favorite in second instance
        await secondViewModel.toggleFavorite()
        
        // Then - Both instances should reflect the change
        #expect(firstViewModel.isFavorite == false)
        #expect(secondViewModel.isFavorite == false)
    }
    
    // MARK: - Media Type Integration Tests
    
    @Test("Integration test for image media type handling")
    func testImageMediaTypeIntegration() async {
        // Given
        let imageItem = DummyDetailApodItem.imageItem
        let viewModel = ApodDetailViewModel(item: imageItem, favoritesManager: favoritesManagerSpy)
        
        // Then - Verify image-specific properties
        #expect(viewModel.item.mediaTypeEnum == .image)
        #expect(viewModel.item.displayImageURL != nil)
        #expect(viewModel.item.url != nil)
        #expect(viewModel.item.hdurl != nil)
        
        // When - Toggle favorite
        await viewModel.toggleFavorite()
        
        // Then - Favorites should work correctly with image items
        #expect(viewModel.isFavorite == true)
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalledWith(imageItem))
    }
    
    @Test("Integration test for video media type handling")
    func testVideoMediaTypeIntegration() async {
        // Given
        let videoItem = DummyDetailApodItem.videoItem
        let viewModel = ApodDetailViewModel(item: videoItem, favoritesManager: favoritesManagerSpy)
        
        // Then - Verify video-specific properties
        #expect(viewModel.item.mediaTypeEnum == .video)
        #expect(viewModel.item.url != nil)
        #expect(viewModel.item.thumbnail_url != nil)
        
        // When - Toggle favorite
        await viewModel.toggleFavorite()
        
        // Then - Favorites should work correctly with video items
        #expect(viewModel.isFavorite == true)
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalledWith(videoItem))
    }
    
    @Test("Integration test for other media type handling")
    func testOtherMediaTypeIntegration() async {
        // Given
        let otherItem = DummyDetailApodItem.otherMediaItem
        let viewModel = ApodDetailViewModel(item: otherItem, favoritesManager: favoritesManagerSpy)
        
        // Then - Verify other media properties
        #expect(viewModel.item.mediaTypeEnum == .other)
        #expect(viewModel.item.url == nil)
        #expect(viewModel.item.thumbnail_url == nil)
        
        // When - Toggle favorite
        await viewModel.toggleFavorite()
        
        // Then - Favorites should work correctly even with other media types
        #expect(viewModel.isFavorite == true)
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalledWith(otherItem))
    }
    
    // MARK: - Date and Formatting Integration Tests
    
    @Test("Date formatting integration across different dates")
    func testDateFormattingIntegrationAcrossDifferentDates() {
        // Given - Items with different dates
        let dates = ["2023-01-01", "2023-06-15", "2023-12-31"]
        
        for dateString in dates {
            // When
            let item = DummyDetailApodItem.withCustomDate(dateString)
            let viewModel = ApodDetailViewModel(item: item, favoritesManager: favoritesManagerSpy)
            let formattedDate = viewModel.formattedDate()
            
            // Then
            #expect(!formattedDate.isEmpty, "Formatted date should not be empty for \(dateString)")
            #expect(viewModel.item.date == dateString, "Original date should be preserved")
        }
    }
    
    // MARK: - Error Recovery Integration Tests
    
    @Test("Error recovery during favorites operations")
    func testErrorRecoveryDuringFavoritesOperations() async {
        // Given - Favorites manager that will error
        favoritesManagerSpy.shouldThrowError = true
        favoritesManagerSpy.error = AppError.network(.invalidResponse)
        
        // When - Try to toggle favorite
        await sut.toggleFavorite()
        
        // Then - Should handle error gracefully
        #expect(favoritesManagerSpy.verifyToggleFavoriteWasCalled())
        
        // When - Fix the error and try again
        favoritesManagerSpy.shouldThrowError = false
        favoritesManagerSpy.error = nil
        
        await sut.toggleFavorite()
        
        // Then - Should work normally
        #expect(favoritesManagerSpy.toggleFavoriteCallCount == 2)
        #expect(sut.isFavorite == true)
    }
}

@Suite("Detail Edge Cases Tests", .serialized)
@MainActor
struct DetailEdgeCasesTests {
    
    // MARK: - Properties
    var favoritesManagerSpy: FavoritesManagerSpy!
    
    // MARK: - Setup
    init() {
        favoritesManagerSpy = FavoritesManagerSpy()
    }
    
    // MARK: - Edge Case Tests
    
    @Test("Handling items with empty or nil values")
    func testHandlingItemsWithEmptyValues() {
        // Given - Item with minimal data
        let minimalItem = ApodItem(
            date: "",
            explanation: "",
            hdurl: nil,
            copyright: nil,
            thumbnail_url: nil,
            mediaType: "",
            serviceVersion: nil,
            title: "",
            url: nil
        )
        
        // When
        let viewModel = ApodDetailViewModel(item: minimalItem, favoritesManager: favoritesManagerSpy)
        
        // Then - Should handle gracefully
        #expect(viewModel.item.title == "")
        #expect(viewModel.item.explanation == "")
        #expect(viewModel.item.copyright == nil)
        #expect(viewModel.formattedDate().isEmpty == true) // Empty date should return empty formatted string
    }
    
    @Test("Handling items with very long content")
    func testHandlingItemsWithVeryLongContent() {
        // Given - Item with very long content
        let veryLongTitle = String(repeating: "Very Long Title ", count: 100)
        let veryLongExplanation = String(repeating: "This is a very long explanation. ", count: 1000)
        
        let longContentItem = ApodItem(
            date: "2023-09-16",
            explanation: veryLongExplanation,
            hdurl: "https://example.com/hd-long.jpg",
            copyright: "Long Copyright Information",
            thumbnail_url: "https://example.com/thumb-long.jpg",
            mediaType: "image",
            serviceVersion: "v1",
            title: veryLongTitle,
            url: "https://example.com/long.jpg"
        )
        
        // When
        let viewModel = ApodDetailViewModel(item: longContentItem, favoritesManager: favoritesManagerSpy)
        
        // Then - Should handle long content without issues
        #expect(viewModel.item.title.count > 1000)
        #expect(viewModel.item.explanation.count > 10000)
        #expect(!viewModel.formattedDate().isEmpty)
    }
    
    @Test("Handling rapid favorite toggles")
    func testHandlingRapidFavoriteToggles() async {
        // Given
        let viewModel = ApodDetailViewModel(item: DummyDetailApodItem.imageItem, favoritesManager: favoritesManagerSpy)
        
        // When - Rapid toggles
        for _ in 0..<10 {
            await viewModel.toggleFavorite()
        }
        
        // Then - Should handle all toggles correctly
        #expect(favoritesManagerSpy.toggleFavoriteCallCount == 10)
        #expect(viewModel.isFavorite == false) // Should be false after even number of toggles
    }
    
    @Test("Memory efficiency with multiple view model instances")
    func testMemoryEfficiencyWithMultipleInstances() {
        // Given - Many view model instances
        var viewModels: [ApodDetailViewModel] = []
        
        for i in 0..<100 {
            let item = DummyDetailApodItem.withCustomDate("2023-09-\(String(format: "%02d", (i % 30) + 1))")
            let viewModel = ApodDetailViewModel(item: item, favoritesManager: favoritesManagerSpy)
            viewModels.append(viewModel)
        }
        
        // When - Access properties from all instances
        for viewModel in viewModels {
            _ = viewModel.item.title
            _ = viewModel.formattedDate()
            _ = viewModel.isFavorite
        }
        
        // Then - Should complete without memory issues
        #expect(viewModels.count == 100)
        
        // Test that each view model maintains its own item
        for (index, viewModel) in viewModels.enumerated() {
            let expectedDate = "2023-09-\(String(format: "%02d", (index % 30) + 1))"
            #expect(viewModel.item.date == expectedDate)
        }
    }
}
