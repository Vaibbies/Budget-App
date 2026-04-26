import SwiftUI

// MARK: - Notifications Settings View
struct NotificationsSettingsView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var spendingAlerts  = true
    @State private var budgetWarnings  = true
    @State private var savingTips      = true
    @State private var weeklyDigest    = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection

                sectionLabel("Alert Types")

                notifCard {
                    toggleRow(
                        icon: "bell.badge.fill",
                        title: "Spending Alerts",
                        description: "Instant updates on large purchases",
                        isOn: $spendingAlerts
                    )
                    divider
                    toggleRow(
                        icon: "exclamationmark.circle.fill",
                        title: "Budget Warnings",
                        description: "Notify when near monthly limits",
                        isOn: $budgetWarnings
                    )
                    divider
                    toggleRow(
                        icon: "sparkles",
                        title: "Penny's Saving Tips",
                        description: "AI insights to reach goals faster",
                        isOn: $savingTips
                    )
                    divider
                    toggleRow(
                        icon: "calendar",
                        title: "Weekly Digest",
                        description: "Summary of your habits every Sunday",
                        isOn: $weeklyDigest
                    )
                }
                .padding(.bottom, 24)

                // ── Preferences ──────────────────────────────────────────
                sectionLabel("Preferences")

                notifCard {
                    HStack {
                        iconCircle("moon.fill")
                        Text("Quiet Hours")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Text("10 PM – 7 AM")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(MeTheme.accent)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(16)

                    divider

                    HStack {
                        iconCircle("dollarsign.circle.fill")
                        Text("Minimum Alert Amount")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Text("$20.00")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(16)
                }
                .padding(.bottom, 24)

                // ── Smart Delivery banner ─────────────────────────────────
                HStack(alignment: .top, spacing: 12) {
                    Circle()
                        .fill(MeTheme.accent.opacity(0.12))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "shield.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(MeTheme.accent)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("SMART DELIVERY")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(MeTheme.accent)
                            .tracking(1.5)

                        Text("Penny will prioritize notifications based on your activity and current budget health to avoid distraction.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .lineSpacing(3)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(MeTheme.accent.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(MeTheme.accent.opacity(0.12), lineWidth: 1)
                        )
                )
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

            Text("NOTIFICATIONS")
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
}

#Preview {
    NotificationsSettingsView()
        .preferredColorScheme(.dark)
}
