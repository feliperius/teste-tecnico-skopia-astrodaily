import Foundation
@testable import TestSkopiaAstroDaily

enum DummyDetailApodItem {
    static let imageItem = ApodItem(
        date: "2023-09-16",
        explanation: "This is a test image APOD item for Detail view testing purposes.",
        hdurl: "https://example.com/hd-image.jpg",
        copyright: "Test Copyright",
        thumbnail_url: "https://example.com/thumbnail.jpg",
        mediaType: "image",
        serviceVersion: "v1",
        title: "Test Image APOD",
        url: "https://example.com/image.jpg"
    )
    
    static let videoItem = ApodItem(
        date: "2023-09-17",
        explanation: "This is a test video APOD item for Detail view testing purposes.",
        hdurl: nil,
        copyright: "Video Test Copyright",
        thumbnail_url: "https://example.com/video-thumb.jpg",
        mediaType: "video",
        serviceVersion: "v1",
        title: "Test Video APOD",
        url: "https://example.com/video.mp4"
    )
    
    static let otherMediaItem = ApodItem(
        date: "2023-09-18",
        explanation: "This is a test other media APOD item for Detail view testing purposes.",
        hdurl: nil,
        copyright: nil,
        thumbnail_url: nil,
        mediaType: "other",
        serviceVersion: "v1",
        title: "Test Other Media APOD",
        url: nil
    )
    
    static let itemWithoutCopyright = ApodItem(
        date: "2023-09-19",
        explanation: "This is a test APOD item without copyright information.",
        hdurl: "https://example.com/hd-no-copyright.jpg",
        copyright: nil,
        thumbnail_url: nil,
        mediaType: "image",
        serviceVersion: "v1",
        title: "Test No Copyright APOD",
        url: "https://example.com/no-copyright.jpg"
    )
    
    static let longExplanationItem = ApodItem(
        date: "2023-09-20",
        explanation: "This is a very long explanation for testing purposes. It contains multiple sentences and should be used to test how the Detail view handles longer text content. The explanation can span several lines and should maintain good readability throughout the entire text content display.",
        hdurl: "https://example.com/hd-long.jpg",
        copyright: "Long Text Copyright",
        thumbnail_url: "https://example.com/long-thumb.jpg",
        mediaType: "image",
        serviceVersion: "v1",
        title: "Long Explanation Test APOD",
        url: "https://example.com/long-explanation.jpg"
    )
    
    static func withCustomDate(_ dateString: String) -> ApodItem {
        ApodItem(
            date: dateString,
            explanation: "Custom date APOD for \(dateString)",
            hdurl: "https://example.com/hd-\(dateString).jpg",
            copyright: "Custom Copyright",
            thumbnail_url: "https://example.com/thumb-\(dateString).jpg",
            mediaType: "image",
            serviceVersion: "v1",
            title: "Custom Date APOD \(dateString)",
            url: "https://example.com/\(dateString).jpg"
        )
    }
}

// MARK: - Error Stubs for Detail Tests

enum DetailDummyError: Error, LocalizedError {
    case favoritesError
    case dataCorruption
    case networkTimeout
    
    var errorDescription: String? {
        switch self {
        case .favoritesError:
            return "Failed to update favorites"
        case .dataCorruption:
            return "Data corruption detected"
        case .networkTimeout:
            return "Network operation timed out"
        }
    }
}

// MARK: - Mock Date Formatter for Testing

enum MockDateFormatter {
    static func expectedFormattedDate(for apiDateString: String) -> String {
        // Simulate what DateFormatter.localizedLong would return
        // This is a simplified mock for testing purposes
        return "September 16, 2023" // Default mock format
    }
}