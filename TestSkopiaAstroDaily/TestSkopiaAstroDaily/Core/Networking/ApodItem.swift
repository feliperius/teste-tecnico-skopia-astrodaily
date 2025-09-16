import Foundation

struct ApodItem: Decodable {
    let date: String
    let title: String
    let explanation: String
    let url: String
    let hdurl: String?
    let media_type: String
    let thumbnail_url: String?

    var mediaType: MediaType { MediaType(rawValue: media_type) ?? .other }

    var displayImageURL: URL? {
        if mediaType == .video, let t = thumbnail_url, let u = URL(string: t) { return u }
        return URL(string: url)
    }
}
