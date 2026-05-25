import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var maxHistoryCount: Int {
        didSet { UserDefaults.standard.set(maxHistoryCount, forKey: "maxHistoryCount") }
    }

    @Published var launchAtLogin: Bool {
        didSet { UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin") }
    }

    init() {
        let defaults = UserDefaults.standard
        maxHistoryCount = defaults.integer(forKey: "maxHistoryCount").nonZero ?? 200
        launchAtLogin = defaults.bool(forKey: "launchAtLogin")
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
