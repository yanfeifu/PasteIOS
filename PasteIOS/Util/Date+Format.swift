import Foundation

extension Date {
    var relativeDisplay: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    var timeDisplay: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "HH:mm"
        } else if Calendar.current.isDateInYesterday(self) {
            return "昨天"
        } else {
            formatter.dateFormat = "MM/dd HH:mm"
        }
        return formatter.string(from: self)
    }
}
