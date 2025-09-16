import Foundation

enum APIConfig {
    static let baseURL = "https://api.nasa.gov/planetary/apod"

    static var apiKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = dict["NASA_API_KEY"] as? String
        else { 
            debugPrint("⚠️ Usando DEMO_KEY - adicione sua chave da NASA no Secrets.plist")
            return "DEMO_KEY"
        }
        return key
    }
}
