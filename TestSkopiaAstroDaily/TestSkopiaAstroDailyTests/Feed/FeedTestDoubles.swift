import Foundation
@testable import TestSkopiaAstroDaily

enum DummyApodItem {
    static let sample = ApodItem(
        date: "2023-09-16",
        explanation: "This is a dummy explanation for testing purposes.",
        hdurl: "https://example.com/hd-image.jpg",
        copyright: "Dummy Copyright",
        thumbnail_url: "https://example.com/thumbnail.jpg",
        mediaType: "image",
        serviceVersion: "v1",
        title: "Dummy APOD Title",
        url: "https://example.com/image.jpg"
    )
    
    static let sampleVideo = ApodItem(
        date: "2023-09-17",
        explanation: "This is a dummy video explanation for testing purposes.",
        hdurl: nil,
        copyright: nil,
        thumbnail_url: "https://example.com/video-thumb.jpg",
        mediaType: "video",
        serviceVersion: "v1",
        title: "Dummy Video APOD",
        url: "https://example.com/video.mp4"
    )
    
    static let sampleWithoutMedia = ApodItem(
        date: "2023-09-18",
        explanation: "This is a dummy item without media.",
        hdurl: nil,
        copyright: nil,
        thumbnail_url: nil,
        mediaType: "other",
        serviceVersion: "v1",
        title: "Dummy No Media APOD",
        url: nil
    )
    
    static func withDate(_ dateString: String) -> ApodItem {
        ApodItem(
            date: dateString,
            explanation: "APOD for \(dateString)",
            hdurl: "https://example.com/hd-\(dateString).jpg",
            copyright: "Test Copyright",
            thumbnail_url: nil,
            mediaType: "image",
            serviceVersion: "v1",
            title: "APOD \(dateString)",
            url: "https://example.com/\(dateString).jpg"
        )
    }
}

enum DummyError: Error, LocalizedError {
    case networkError
    case invalidData
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network connection failed"
        case .invalidData:
            return "Invalid data received"
        case .serverError:
            return "Server error occurred"
        }
    }
}