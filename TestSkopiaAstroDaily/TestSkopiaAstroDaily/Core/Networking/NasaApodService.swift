import Foundation
import Alamofire

protocol NasaApodServicing {
    func fetchApod(date: Date) async throws -> ApodItem
    func fetchRange(start: Date, end: Date) async throws -> [ApodItem]
}

enum NetworkError: LocalizedError {
    case http(Int)
    case decoding
    case invalidResponse
    case noDataForDate(String)
    
    var errorDescription: String? {
        switch self {
        case .http(let code):
            if code == 404 {
                return "Não há dados disponíveis para esta data"
            }
            return "Erro HTTP: \(code)"
        case .decoding: return "Erro ao processar dados"
        case .invalidResponse: return "Resposta inválida do servidor"
        case .noDataForDate(let date): return "Não há dados para \(date)"
        }
    }
}

final class NasaApodService: NasaApodServicing {

    private func request<T: Decodable>(_ params: [String: String]) async throws -> T {
        let p = params.merging(["api_key": APIConfig.apiKey]) { $1 }
        
        if let date = params["date"] {
            print("🔄 Carregando APOD para: \(date)")
        } else if params.contains(where: { $0.key.contains("date") }) {
            print("🔄 Carregando APOD para range")
        } else {
            print("🔄 Carregando APOD do dia atual")
        }
        
        print("🌐 Fazendo requisição para: \(APIConfig.baseURL)")
        print("📝 Parâmetros: \(p)")
        
        return try await withCheckedThrowingContinuation { cont in
            AF.request(APIConfig.baseURL, parameters: p)
                .responseData { resp in
                    
                    print("📡 Status: \(resp.response?.statusCode ?? -1)")
                    
                    if let data = resp.data {
                        print("📄 Response size: \(data.count) bytes")
                        
                        if let jsonString = String(data: data, encoding: .utf8) {
                            print("📄 JSON recebido: \(jsonString)")
                        }
                        
                        // Verificar se é um erro HTTP
                        if let statusCode = resp.response?.statusCode, statusCode >= 400 {
                            print("❌ Erro HTTP: \(statusCode)")
                            if statusCode == 404 {
                                cont.resume(throwing: NetworkError.noDataForDate("esta data"))
                            } else {
                                cont.resume(throwing: NetworkError.http(statusCode))
                            }
                            return
                        }
                        
                        // Tentar decodificar como objeto esperado
                        do {
                            let decoded = try JSONDecoder().decode(T.self, from: data)
                            print("✅ Decodificação bem-sucedida!")
                            cont.resume(returning: decoded)
                        } catch {
                            print("❌ Erro de decodificação: \(error)")
                            cont.resume(throwing: NetworkError.decoding)
                        }
                    } else if let error = resp.error {
                        print("❌ Erro de rede: \(error)")
                        cont.resume(throwing: NetworkError.invalidResponse)
                    } else {
                        print("❌ Resposta inválida")
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

