import UIKit

enum Haptics {
    static let settingsKey = "penny.preferences.hapticsEnabled"

    private static var isEnabled: Bool {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: settingsKey) != nil else { return true }
        return defaults.bool(forKey: settingsKey)
    }

    static func light() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func medium() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func soft() {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}
