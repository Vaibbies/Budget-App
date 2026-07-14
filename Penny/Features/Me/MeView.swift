import SwiftUI

struct MeView: View {
    @Environment(PennyPlatform.self) private var platform

    private enum Route: String, Identifiable {
        case budgetGoals
        case connectedBanks
        case notifications
        case settings
        case pennyAISettings
        case privacySecurity
        case friendsCommunity
        case helpFAQs
        case contactSupport

        var id: String { rawValue }
    }

    @State private var route: Route?

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection

                    MeProfileHeader()

                    MeMenuGroup(items: menuItems1, onTap: handleMenuTap1)
                        .padding(.bottom, 24)

                    MeMenuGroup(items: menuItems2, onTap: handleMenuTap2)
                        .padding(.bottom, 16)

                    MeMenuGroup(items: menuItems3, onTap: handleMenuTap3)
                        .padding(.bottom, 24)

                    MeFooter()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .background(backgroundGradient)
            .navigationDestination(item: $route) { destination in
                switch destination {
                case .budgetGoals:
                    BudgetGoalsView()
                case .connectedBanks:
                    ConnectedBanksView()
                case .notifications:
                    NotificationsSettingsView()
                case .settings:
                    SettingsView()
                case .pennyAISettings:
                    PennyAISettingsView()
                case .privacySecurity:
                    PrivacySecurityView()
                case .friendsCommunity:
                    FriendsCommunityView()
                case .helpFAQs:
                    HelpFAQsView()
                case .contactSupport:
                    ContactSupportView()
                }
            }
        }
    }

    // MARK: - Menu Items
    private let menuItems2 = [
        MeMenuItem(icon: "gearshape.fill",  label: "Settings"),
        MeMenuItem(icon: "sparkles",        label: "Penny AI Settings"),
        MeMenuItem(icon: "shield.fill",     label: "Privacy & Security"),
        MeMenuItem(icon: "person.2.fill",   label: "Friends & Community"),
    ]

    private let menuItems3 = [
        MeMenuItem(icon: "questionmark.circle.fill", label: "Help & FAQs"),
        MeMenuItem(icon: "envelope.fill",           label: "Contact Support"),
    ]

    private var menuItems1: [MeMenuItem] {
        let linkedAccounts = platform.accountTransactionService.accounts().count
        return [
            MeMenuItem(icon: "chart.pie.fill",  label: "Budget & Goals"),
            MeMenuItem(icon: "lock.fill",       label: "Connected Banks", badge: linkedAccounts == 0 ? "None" : "\(linkedAccounts) Active"),
            MeMenuItem(icon: "bell.fill",       label: "Notifications"),
        ]
    }

    private func handleMenuTap1(_ item: MeMenuItem) {
        switch item.label {
        case "Budget & Goals":
            route = .budgetGoals
        case "Connected Banks":
            route = .connectedBanks
        case "Notifications":
            route = .notifications
        default:
            break
        }
    }

    private func handleMenuTap2(_ item: MeMenuItem) {
        switch item.label {
        case "Settings":
            route = .settings
        case "Penny AI Settings":
            route = .pennyAISettings
        case "Privacy & Security":
            route = .privacySecurity
        case "Friends & Community":
            route = .friendsCommunity
        default:
            break
        }
    }

    private func handleMenuTap3(_ item: MeMenuItem) {
        switch item.label {
        case "Help & FAQs":
            route = .helpFAQs
        case "Contact Support":
            route = .contactSupport
        default:
            break
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Spacer()
            Text("PROFILE")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        PennyWarmBackground()
    }
}

#Preview {
    MeView()
        .preferredColorScheme(.dark)
}
