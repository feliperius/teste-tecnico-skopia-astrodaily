import Foundation
import Alamofire

protocol NasaApodServicing {
    func fetchApod(date: Date) async throws -> ApodItem
    func fetchRange(start: Date, end: Date) async throws -> [ApodItem]
}

enum NetworkError: Error, LocalizedError {
    case invalidResponse, decoding, http(Int), unknown
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Resposta inválida do servidor"
        case .decoding:        return "Erro ao decodificar dados"
        case .http(let c):     return "Erro HTTP (\(c))"
        case .unknown:         return "Erro desconhecido"
        }
    }
}

final class NasaApodService: NasaApodServicing {

    private func request<T: Decodable>(_ params: [String: String]) async throws -> T {
        let p = params.merging(["api_key": APIConfig.apiKey, "thumbs": "true"]) { $1 }
        return try await withCheckedThrowingContinuation { cont in
            AF.request(APIConfig.baseURL, parameters: p)
                .validate()
                .responseDecodable(of: T.self) { resp in
                    switch resp.result {
                    case .success(let value): cont.resume(returning: value)
                    case .failure(let error):
                        if let code = resp.response?.statusCode { cont.resume(throwing: NetworkError.http(code)) }
                        else if error.isResponseSerializationError { cont.resume(throwing: NetworkError.decoding) }
                        else { cont.resume(throwing: NetworkError.invalidResponse) }
                    }
                }
        }
    }

    func fetchApod(date: Date) async throws -> ApodItem {
        try await request(["date": date.apodString])
    }

    func fetchRange(start: Date, end: Date) async throws -> [ApodItem] {
        let items: [ApodItem] = try await request([
            "start_date": start.apodString,
            "end_date":   end.apodString
        ])
        return items.sorted { $0.date > $1.date }
    }
    
    struct NasaAPIErrorEnvelope: Decodable {
        struct NasaAPIError: Decodable {
            let code: String?
            let message: String
        }
        let error: NasaAPIError
    }
}

