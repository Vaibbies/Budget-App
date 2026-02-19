import AppIntents
import SwiftUI

// MARK: - App Intent
struct MindfulSpendingIntent: AppIntent {
    static var title: LocalizedStringResource = "Mindful Spending Pause"
    static var description = IntentDescription("Open Penny's mindful pause before a purchase.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        // Post a notification that the app listens to
        await MainActor.run {
            NotificationCenter.default.post(name: .triggerMindfulSpending, object: nil)
        }
        return .result()
    }
}

extension Notification.Name {
    static let triggerMindfulSpending = Notification.Name("triggerMindfulSpending")
}
