import SwiftUI

// MARK: - Notifications Settings View
struct NotificationsSettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("penny.preferences.languageCode") private var languageCode = AppLanguage.english.rawValue
    @AppStorage("penny.notifications.spendingAlerts") private var spendingAlerts = true
    @AppStorage("penny.notifications.budgetWarnings") private var budgetWarnings = true
    @AppStorage("penny.notifications.weeklyDigest") private var weeklyDigest = false
    @AppStorage("penny.notifications.savingTips") private var savingTips = false
    @AppStorage("penny.notifications.billReminders") private var billReminders = true

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection

                sectionLabel(language.text(.alerts))

                notifCard {
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
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(backgroundGradient)
        .navigationBarHidden(true)
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
}

#Preview {
    NotificationsSettingsView()
        .preferredColorScheme(.dark)
}
