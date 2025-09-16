import Foundation
import Alamofire

protocol NasaApodServicing {
    func fetchApod(date: Date) async throws -> ApodItem
    func fetchRange(start: Date, end: Date) async throws -> [ApodItem]
}

enum NetworkError: LocalizedError, Equatable {
    case http(Int)
    case decoding
    case invalidResponse
    case noDataForDate(String)
    
    var errorDescription: String? {
        switch self {
        case .http(let code):
            if code == 404 {
                return Strings.errorNoDataForDate
            }
            return "\(Strings.errorHttp): \(code)"
        case .decoding: return Strings.errorDecoding
        case .invalidResponse: return Strings.errorInvalidResponse
        case .noDataForDate(_): return Strings.errorNoDataForDate
        }
    }
}

final class NasaApodService: NasaApodServicing {

    private func request<T: Decodable>(_ params: [String: String]) async throws -> T {
        let p = params.merging(["api_key": APIConfig.apiKey]) { $1 }
        
        if let date = params["date"] {
            debugPrint("Carregando APOD para: \(date)")
        } else if params.contains(where: { $0.key.contains("date") }) {
            debugPrint("Carregando APOD para range")
        } else {
            debugPrint("Carregando APOD do dia atual")
        }
        
        debugPrint("Fazendo requisição para: \(APIConfig.baseURL)")
        debugPrint("Parâmetros: \(p)")
        
        return try await withCheckedThrowingContinuation { cont in
            AF.request(APIConfig.baseURL, parameters: p)
                .responseData { resp in
                    
                    debugPrint("Status: \(resp.response?.statusCode ?? -1)")
                    
                    if let data = resp.data {
                        debugPrint("Response size: \(data.count) bytes")
                        
                        if let jsonString = String(data: data, encoding: .utf8) {
                            debugPrint("JSON recebido: \(jsonString)")
                        }
                        
                        if let statusCode = resp.response?.statusCode, statusCode >= 400 {
                            debugPrint("Erro HTTP: \(statusCode)")
                            if statusCode == 404 {
                                cont.resume(throwing: NetworkError.noDataForDate("esta data"))
                            } else {
                                cont.resume(throwing: NetworkError.http(statusCode))
                            }
                            return
                        }
                        
                        do {
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            debugPrint("Decodificação bem-sucedida!")
                            cont.resume(returning: decoded)
                        } catch {
                            debugPrint("Erro de decodificação: \(error)")
                            cont.resume(throwing: NetworkError.decoding)
                        }
                    } else if let error = resp.error {
                        debugPrint("Erro de rede: \(error)")
                        cont.resume(throwing: NetworkError.invalidResponse)
                    } else {
                        debugPrint("Resposta inválida")
                        cont.resume(throwing: NetworkError.invalidResponse)
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
}

