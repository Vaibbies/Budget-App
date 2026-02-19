import SwiftUI

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var profile = SettingsProfile(
        name: "Alex Rivers",
        email: "alex.r@protonmail.com",
        twoFactorEnabled: true
    )

    @State private var preferences = SettingsPreferences(
        currency: "USD ($)",
        language: "English",
        theme: "Deep Dark",
        timezone: "GMT -5"
    )

    @State private var notifications = SettingsNotifications(
        spending: "Immediate",
        budgets: "Daily",
        reports: "Weekly",
        tips: "Paused"
    )

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection

                // ── Account & Security ───────────────────────────────────
                sectionLabel("Account & Security")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    gridCell(label: "Profile", value: profile.name)
                    gridCell(label: "Two-Factor", value: profile.twoFactorEnabled ? "Active" : "Inactive",
                             valueColor: MeTheme.success)
                }
                gridCell(label: "Linked Email", value: profile.email)
                    .padding(.top, 12)

                divider

                // ── Preferences ──────────────────────────────────────────
                sectionLabel("Preferences")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    gridCell(label: "Currency",  value: preferences.currency)
                    gridCell(label: "Language",  value: preferences.language)
                    gridCell(label: "Theme",     value: preferences.theme)
                    gridCell(label: "Timezone",  value: preferences.timezone)
                }

                divider

                // ── Notification Grid ────────────────────────────────────
                sectionLabel("Notification Grid")

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    gridCell(label: "Spending", value: notifications.spending, hasAccent: true)
                    gridCell(label: "Budgets",  value: notifications.budgets)
                    gridCell(label: "Reports",  value: notifications.reports)
                    gridCell(label: "Tips",     value: notifications.tips, isDisabled: true)
                }

                // ── System Info ──────────────────────────────────────────
                systemInfoCard
                    .padding(.top, 32)
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
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 36, height: 36)
                    .background(MeTheme.surface)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(MeTheme.glassBorder, lineWidth: 1))
            }

            Spacer()

            Text("SETTINGS")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Spacer()

            Button("Save") {}
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(MeTheme.accent)
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

    // MARK: - Grid Cell
    private func gridCell(
        label: String,
        value: String,
        valueColor: Color = .white,
        hasAccent: Bool = false,
        isDisabled: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1.5)

            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MeTheme.glassBorder, lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            if hasAccent {
                RoundedRectangle(cornerRadius: 2)
                    .fill(MeTheme.accent)
                    .frame(width: 3)
                    .padding(.vertical, 10)
            }
        }
        .opacity(isDisabled ? 0.4 : 1.0)
    }

    // MARK: - Section Label
    private func sectionLabel(_ text: String) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 12)
    }

    // MARK: - Divider
    private var divider: some View {
        LinearGradient(
            colors: [.clear, .white.opacity(0.08), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.vertical, 24)
    }

    // MARK: - System Info Card
    private var systemInfoCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.4))

            VStack(alignment: .leading, spacing: 4) {
                Text("SYSTEM INFO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(1.5)

                Text("Version 4.2.0  •  Last sync 2m ago  •  All systems operational.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(MeTheme.glassBorder, lineWidth: 1)
        )
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            MeTheme.canvas.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.12),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Models
struct SettingsProfile {
    var name: String
    var email: String
    var twoFactorEnabled: Bool
}

struct SettingsPreferences {
    var currency: String
    var language: String
    var theme: String
    var timezone: String
}

struct SettingsNotifications {
    var spending: String
    var budgets: String
    var reports: String
    var tips: String
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
