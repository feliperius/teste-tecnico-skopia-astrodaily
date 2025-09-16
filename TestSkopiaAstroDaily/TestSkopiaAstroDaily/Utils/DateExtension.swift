import Foundation

extension Date {
    var apodString: String {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.timeZone = .init(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
    
    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    static func from(apodString: String) -> Date? {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.timeZone = .init(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: apodString)
    }
}
