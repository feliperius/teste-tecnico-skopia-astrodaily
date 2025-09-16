import Foundation

struct ApodItem: Codable, Identifiable, Hashable {
    let date: String
    let explanation: String
    let hdurl: String?
    let copyright: String?
    let thumbnail_url: String?
    let mediaType: String
    let serviceVersion: String
    let title: String
    let url: String
    var id: String { date }
    var displayImageURL: URL? {
        if mediaTypeEnum == .video, let t = thumbnail_url, let u = URL(string: t) { return u }
        return URL(string: url)
    }
    
    enum CodingKeys: String, CodingKey {
        case date
        case explanation
        case hdurl
        case copyright
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title
        case url
        case thumbnail_url
    }

    enum MediaType {
        case image
        case video
        case other
    }

    var mediaTypeEnum: MediaType {
        switch mediaType.lowercased() {
        case "image": return .image
        case "video": return .video
        default: return .other
        }
    }
}
