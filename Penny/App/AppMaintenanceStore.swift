import Foundation
import Observation
import UserNotifications

struct NotificationPreferences: Equatable {
    let spendingAlerts: Bool
    let budgetWarnings: Bool
    let billReminders: Bool
    let weeklyDigest: Bool
    let savingTips: Bool
}

@MainActor
@Observable
final class AppMaintenanceStore {
    private let spending: SpendingStore
    private let recurring: RecurringStore
    private let notificationManager: any NotificationManaging
    private let minimumForegroundRefreshInterval: TimeInterval

    private var lastForegroundRefreshAt: Date?

    init(
        spending: SpendingStore,
        recurring: RecurringStore,
        notificationManager: (any NotificationManaging)? = nil,
        minimumForegroundRefreshInterval: TimeInterval = 5
    ) {
        self.spending = spending
        self.recurring = recurring
        self.notificationManager = notificationManager ?? LocalNotificationManager.shared
        self.minimumForegroundRefreshInterval = minimumForegroundRefreshInterval
    }

    func handleForegroundActivation(preferences: NotificationPreferences) {
        let now = Date()
        if let lastForegroundRefreshAt,
           now.timeIntervalSince(lastForegroundRefreshAt) < minimumForegroundRefreshInterval {
            return
        }

        lastForegroundRefreshAt = now

        Task { @MainActor in
            await Task.yield()
            recurring.syncRecurringTransactions()
            await refreshNotifications(preferences: preferences)
        }
    }

    func refreshNotifications(preferences: NotificationPreferences) async {
        await notificationManager.refreshNotifications(
            using: spending.notificationSnapshot,
            spendingAlertsEnabled: preferences.spendingAlerts,
            budgetWarningsEnabled: preferences.budgetWarnings,
            billRemindersEnabled: preferences.billReminders,
            weeklyDigestEnabled: preferences.weeklyDigest,
            savingTipsEnabled: preferences.savingTips
        )
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        await notificationManager.authorizationStatus()
    }

    func requestNotificationAuthorization() async -> Bool {
        await notificationManager.requestAuthorization()
    }

    func scheduleTestNotification(after seconds: TimeInterval = 5) async {
        await notificationManager.scheduleTestNotification(after: seconds)
    }
}
