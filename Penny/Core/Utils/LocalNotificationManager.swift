import Foundation
import UserNotifications

struct NotificationRefreshSnapshot {
    let subscriptions: [RecurringSubscription]
    let manualForecastItems: [ManualForecastItem]
    let dailySpent: Double
    let dailyRemaining: Double
    let dailyBudget: Double
    let totalMonthlyBudget: Double
    let safeToSpendThisMonth: Double
    let topCategories: [CategoryData]
}

final class LocalNotificationManager {
    static let shared = LocalNotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let managedPrefix = "penny.local."
    private let billPrefix = "penny.local.bill."
    private let weeklyDigestIdentifier = "penny.local.weeklyDigest"
    private let spendingAlertIdentifier = "penny.local.spendingAlert"
    private let budgetWarningIdentifier = "penny.local.budgetWarning"
    private let savingTipIdentifier = "penny.local.savingTip"
    private let testIdentifier = "penny.local.test"

    private init() {}

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationSettings()
        return settings.authorizationStatus
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                continuation.resume(returning: granted)
            }
        }
    }

    func refreshNotifications(
        using snapshot: NotificationRefreshSnapshot,
        spendingAlertsEnabled: Bool,
        budgetWarningsEnabled: Bool,
        billRemindersEnabled: Bool,
        weeklyDigestEnabled: Bool,
        savingTipsEnabled: Bool
    ) async {
        await clearManagedNotifications()

        let authorized = await isAuthorized()
        guard authorized else { return }

        if spendingAlertsEnabled {
            await scheduleSpendingAlert(using: snapshot)
        }

        if budgetWarningsEnabled {
            await scheduleBudgetWarning(using: snapshot)
        }

        if billRemindersEnabled {
            await scheduleBillReminders(using: snapshot)
        }

        if weeklyDigestEnabled {
            await scheduleWeeklyDigest()
        }

        if savingTipsEnabled {
            await scheduleSavingTip(using: snapshot)
        }
    }

    func scheduleTestNotification(after seconds: TimeInterval = 5) async {
        let alreadyAuthorized = await isAuthorized()
        let granted = alreadyAuthorized ? true : await requestAuthorization()
        guard granted else { return }

        center.removePendingNotificationRequests(withIdentifiers: [testIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Penny Test"
        content.body = "Local notifications are working on this device."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds, 1), repeats: false)
        let request = UNNotificationRequest(identifier: testIdentifier, content: content, trigger: trigger)

        await add(request)
    }

    var isAuthorizedForUI: Bool {
        get async { await isAuthorized() }
    }

    private func isAuthorized() async -> Bool {
        let status = await authorizationStatus()
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    private func clearManagedNotifications() async {
        let requests = await pendingNotificationRequests()
        let identifiers = requests
            .map(\.identifier)
            .filter { $0.hasPrefix(managedPrefix) }

        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func scheduleBillReminders(using snapshot: NotificationRefreshSnapshot) async {
        let calendar = Calendar.current
        let now = Date()

        struct BillReminder {
            let identifier: String
            let title: String
            let amount: Double
            let dueDate: Date
            let source: String
        }

        let subscriptionReminders: [BillReminder] = snapshot.subscriptions.compactMap { subscription in
            guard subscription.status == .active else { return nil }
            guard let epoch = subscription.nextBillingEpoch else { return nil }
            let dueDate = Date(timeIntervalSince1970: epoch)
            guard dueDate >= now else { return nil }

            return BillReminder(
                identifier: "\(billPrefix)subscription.\(subscription.id.uuidString)",
                title: subscription.name,
                amount: subscription.price,
                dueDate: dueDate,
                source: subscription.plan ?? "Recurring bill"
            )
        }

        let manualReminders: [BillReminder] = snapshot.manualForecastItems.compactMap { item in
            guard item.kind == .bill else { return nil }
            guard item.date >= now else { return nil }

            return BillReminder(
                identifier: "\(billPrefix)manual.\(item.id.uuidString)",
                title: item.title,
                amount: item.amount,
                dueDate: item.date,
                source: item.note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? item.note! : "Planned bill"
            )
        }

        let reminders = (subscriptionReminders + manualReminders)
            .sorted { $0.dueDate < $1.dueDate }
            .prefix(32)

        for reminder in reminders {
            let reminderDate = reminderTriggerDate(for: reminder.dueDate, calendar: calendar, now: now)
            guard reminderDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = "Upcoming bill tomorrow: \(currency(reminder.amount)) • \(reminder.source)"
            content.sound = .default

            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminderDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger)

            await add(request)
        }
    }

    private func scheduleWeeklyDigest() async {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Digest"
        content.body = "Open Penny to review your spending, bills, and cash flow."
        content.sound = .default

        var components = DateComponents()
        components.weekday = 1
        components.hour = 18
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyDigestIdentifier, content: content, trigger: trigger)

        await add(request)
    }

    private func scheduleSpendingAlert(using snapshot: NotificationRefreshSnapshot) async {
        let content = UNMutableNotificationContent()
        content.title = "Daily Spending Check-In"
        content.body = "You’ve spent \(currency(snapshot.dailySpent)) today and have \(currency(snapshot.dailyRemaining)) remaining."
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: spendingAlertIdentifier, content: content, trigger: trigger)

        await add(request)
    }

    private func scheduleBudgetWarning(using snapshot: NotificationRefreshSnapshot) async {
        let dailyOverBudget = snapshot.dailyBudget > 0 && snapshot.dailySpent >= snapshot.dailyBudget
        let monthlyLow = snapshot.totalMonthlyBudget > 0 && snapshot.safeToSpendThisMonth <= max(snapshot.dailyBudget, 25)

        guard dailyOverBudget || monthlyLow else { return }

        let content = UNMutableNotificationContent()
        content.title = dailyOverBudget ? "Daily Budget Reached" : "Budget Running Tight"
        content.body = dailyOverBudget
            ? "You’ve spent \(currency(snapshot.dailySpent)) today, which is at or above your daily budget."
            : "You have \(currency(snapshot.safeToSpendThisMonth)) left that looks safe to spend this month."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
        let request = UNNotificationRequest(identifier: budgetWarningIdentifier, content: content, trigger: trigger)

        await add(request)
    }

    private func scheduleSavingTip(using snapshot: NotificationRefreshSnapshot) async {
        let tipBody: String

        if let topCategory = snapshot.topCategories.first {
            tipBody = "Your highest spend category is \(topCategory.name). Cutting back there will move the needle fastest."
        } else if snapshot.safeToSpendThisMonth > 0 {
            tipBody = "You still have \(currency(snapshot.safeToSpendThisMonth)) safe to spend this month. Keep that buffer intact."
        } else {
            tipBody = "Add accounts, bills, and transactions to get more accurate savings tips."
        }

        let content = UNMutableNotificationContent()
        content.title = "Penny Saving Tip"
        content.body = tipBody
        content.sound = .default

        var components = DateComponents()
        components.hour = 10
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: savingTipIdentifier, content: content, trigger: trigger)

        await add(request)
    }

    private func reminderTriggerDate(for dueDate: Date, calendar: Calendar, now: Date) -> Date {
        let dueDayStart = calendar.startOfDay(for: dueDate)
        let dayBefore = calendar.date(byAdding: .day, value: -1, to: dueDayStart) ?? dueDayStart
        let preferred = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dayBefore) ?? dayBefore

        if preferred > now {
            return preferred
        }

        let sameDay = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: dueDayStart) ?? dueDayStart
        if sameDay > now {
            return sameDay
        }

        return dueDate.addingTimeInterval(-3600)
    }

    private func currency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currencyCode ?? "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "$%.2f", amount)
    }

    private func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            center.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    private func add(_ request: UNNotificationRequest) async {
        await withCheckedContinuation { continuation in
            center.add(request) { _ in
                continuation.resume()
            }
        }
    }
}
