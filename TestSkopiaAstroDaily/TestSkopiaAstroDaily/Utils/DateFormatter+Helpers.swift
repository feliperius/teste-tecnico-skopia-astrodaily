import Foundation

extension DateFormatter {
    static let apodAPIDate: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    static func localizedLong(fromAPIDateString s: String) -> String {
        if let date = DateFormatter.apodAPIDate.date(from: s) {
            let f = DateFormatter()
            f.locale = Locale(identifier: "pt_BR")
            f.dateStyle = .full
            return f.string(from: date)
        }
        return s
    }
}
