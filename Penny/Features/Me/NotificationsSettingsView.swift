import SwiftUI
import UserNotifications

// MARK: - Notifications Settings View
struct NotificationsSettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(TransactionData.self) private var data
    @AppStorage("penny.preferences.languageCode") private var languageCode = AppLanguage.english.rawValue
    @AppStorage("penny.notifications.spendingAlerts") private var spendingAlerts = true
    @AppStorage("penny.notifications.budgetWarnings") private var budgetWarnings = true
    @AppStorage("penny.notifications.weeklyDigest") private var weeklyDigest = false
    @AppStorage("penny.notifications.savingTips") private var savingTips = false
    @AppStorage("penny.notifications.billReminders") private var billReminders = true
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection

                sectionLabel(language.text(.alerts))

                notifCard {
                    statusRow
                    divider
                    toggleRow(
                        icon: "bell.badge.fill",
                        title: language.text(.spendingAlerts),
                        description: language.text(.spendingAlertsDescription),
                        isOn: $spendingAlerts
                    )
                    divider
                    toggleRow(
                        icon: "exclamationmark.circle.fill",
                        title: language.text(.budgetProgress),
                        description: language.text(.budgetProgressDescription),
                        isOn: $budgetWarnings
                    )
                    divider
                    toggleRow(
                        icon: "calendar",
                        title: language.text(.weeklyDigest),
                        description: language.text(.weeklyDigestDescription),
                        isOn: $weeklyDigest
                    )
                    divider
                    toggleRow(
                        icon: "creditcard.trianglebadge.exclamationmark",
                        title: language.text(.billReminders),
                        description: language.text(.billRemindersDescription),
                        isOn: $billReminders
                    )
                    divider
                    toggleRow(
                        icon: "sparkles",
                        title: language.text(.savingTips),
                        description: language.text(.savingTipsDescription),
                        isOn: $savingTips
                    )
                }

                sectionLabel("Test")
                    .padding(.top, 24)

                notifCard {
                    actionRow(
                        icon: "checkmark.bubble.fill",
                        title: "Send Test Notification",
                        description: "Schedules a local notification in 5 seconds."
                    ) {
                        Task {
                            let manager = LocalNotificationManager.shared
                            let alreadyAuthorized = await manager.isAuthorizedForUI
                            let granted = alreadyAuthorized ? true : await manager.requestAuthorization()
                            guard granted else { return }
                            await manager.scheduleTestNotification()
                            await refreshAuthorizationStatus()
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(backgroundGradient)
        .navigationBarHidden(true)
        .task {
            await refreshAuthorizationStatus()
            await refreshLocalNotifications()
        }
        .onChange(of: billReminders) { _, _ in
            Task {
                await refreshLocalNotifications()
            }
        }
        .onChange(of: weeklyDigest) { _, _ in
            Task {
                await refreshLocalNotifications()
            }
        }
        .onChange(of: spendingAlerts) { _, _ in
            Task {
                await refreshLocalNotifications()
            }
        }
        .onChange(of: budgetWarnings) { _, _ in
            Task {
                await refreshLocalNotifications()
            }
        }
        .onChange(of: savingTips) { _, _ in
            Task {
                await refreshLocalNotifications()
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(MeTheme.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(MeTheme.glassBorder, lineWidth: 1))
            }

            Spacer()

            Text(language.text(.notifications).uppercased())
                .font(.system(size: 13, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Spacer()

            // Balance the back button
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - Helpers
    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 10)
    }

    private func notifCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(MeTheme.glassBorder, lineWidth: 1)
        )
    }

    private func toggleRow(icon: String, title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            iconCircle(icon)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text(description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(MeTheme.accent)
        }
        .padding(16)
    }

    private var statusRow: some View {
        HStack(spacing: 14) {
            iconCircle(statusIcon)

            VStack(alignment: .leading, spacing: 3) {
                Text("Local Notifications")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                Text(statusDescription)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            Button(authorizationActionTitle) {
                Task {
                    _ = await LocalNotificationManager.shared.requestAuthorization()
                    await refreshAuthorizationStatus()
                    await refreshLocalNotifications()
                }
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(MeTheme.accent.opacity(authorizationStatus.isEnabled ? 0.14 : 0.85))
            .clipShape(Capsule())
            .disabled(authorizationStatus.isEnabled)
        }
        .padding(16)
    }

    private func actionRow(icon: String, title: String, description: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                iconCircle(icon)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    Text(description)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }

    private func iconCircle(_ systemName: String) -> some View {
        Circle()
            .fill(Color.white.opacity(0.05))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            )
    }

    private var divider: some View {
        Divider()
            .background(Color.white.opacity(0.05))
            .padding(.leading, 56)
    }

    private var backgroundGradient: some View {
        PennyWarmBackground()
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    private var authorizationActionTitle: String {
        authorizationStatus.isEnabled ? "Enabled" : "Allow"
    }

    private var statusIcon: String {
        authorizationStatus.isEnabled ? "bell.circle.fill" : "bell.slash.circle.fill"
    }

    private var statusDescription: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Bill reminders and weekly digests can be delivered on this device."
        case .denied:
            return "Notifications are disabled for Penny. Re-enable them in Settings."
        case .notDetermined:
            return "Allow notifications to test reminders directly on your phone."
        @unknown default:
            return "Notification status is unavailable."
        }
    }

    private func refreshAuthorizationStatus() async {
        authorizationStatus = await LocalNotificationManager.shared.authorizationStatus()
    }

    private func refreshLocalNotifications() async {
        if authorizationStatus == .notDetermined {
            _ = await LocalNotificationManager.shared.requestAuthorization()
            await refreshAuthorizationStatus()
        }

        await LocalNotificationManager.shared.refreshNotifications(
            using: data,
            spendingAlertsEnabled: spendingAlerts,
            budgetWarningsEnabled: budgetWarnings,
            billRemindersEnabled: billReminders,
            weeklyDigestEnabled: weeklyDigest,
            savingTipsEnabled: savingTips
        )
    }
}

#Preview {
    NotificationsSettingsView()
        .preferredColorScheme(.dark)
}

private extension UNAuthorizationStatus {
    var isEnabled: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }
}
