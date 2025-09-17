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
    

    static var nasaTodayDate: Date {
        guard let easternTimeZone = TimeZone(identifier: "America/New_York") else {
            return Date().addingTimeInterval(-5 * 3600)
        }
        
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = easternTimeZone
        

        let easternComponents = calendar.dateComponents([.year, .month, .day, .hour], from: now)
        
        let currentHour = easternComponents.hour ?? 0
        let safetyMarginHours = 6 // Margem de segurança de 6 horas
        
        var targetDate = calendar.date(from: DateComponents(
            year: easternComponents.year,
            month: easternComponents.month,
            day: easternComponents.day
        )) ?? now
        
        if currentHour < safetyMarginHours {
            targetDate = calendar.date(byAdding: .day, value: -1, to: targetDate) ?? targetDate
        }
        
        return targetDate
    }
    
    func isNasaToday() -> Bool {
        let nasaToday = Date.nasaTodayDate
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: nasaToday)
    }
}
