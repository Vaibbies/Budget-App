import SwiftUI

struct MeView: View {
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
    private let data = TransactionData.shared

    private let stats = [
    private var streakDays: Int {
        let calendar = Calendar.current
        let resolved = data.groups.compactMap { group in
            TransactionData.resolvedDateForUI(group.title, now: Date())
        }
        let uniqueDays = Array(Set(resolved.map { calendar.startOfDay(for: $0) })).sorted(by: >)
        guard let first = uniqueDays.first, calendar.isDateInToday(first) else { return 0 }

        var streak = 0
        var cursor = calendar.startOfDay(for: Date())
        for day in uniqueDays {
            if calendar.isDate(day, inSameDayAs: cursor) {
                streak += 1
                cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
            } else {
                break
            }
        }
        return streak
    }

    private var stats: [MeStatItem] {
        [
            MeStatItem(emoji: "🔥", value: "\(streakDays)", label: "Streak"),
            MeStatItem(emoji: "💰", value: "$\(Int(data.totalGoalProgress))", label: "Saved"),
            MeStatItem(emoji: "🎯", value: "\(data.allTransactions.filter { $0.isImpulse }.count)", label: "Impulses"),
        ]
    }

    private var achievements: [MeAchievement] {
        [
            MeAchievement(
                emoji: "🏔️",
                name: "Budget Keeper",
                date: data.totalMonthlyBudget <= 0 ? "Set your first budget" : (data.monthlySpent <= data.totalMonthlyBudget ? "On pace this month" : "Over budget this month"),
                unlocked: data.totalMonthlyBudget > 0 && data.monthlySpent <= data.totalMonthlyBudget,
                gradientColors: [Color.orange, Color(red: 1.0, green: 0.55, blue: 0.0)]
            ),
            MeAchievement(
                emoji: "💎",
                name: "Goal Builder",
                date: data.savingsGoals.isEmpty ? "Create your first goal" : "Saved $\(Int(data.totalGoalProgress))",
                unlocked: data.totalGoalProgress >= 1000 && !data.savingsGoals.isEmpty,
                gradientColors: [Color.cyan, Color.blue]
            ),
            MeAchievement(
                emoji: "🚀",
                name: "High Velocity",
                date: "\(data.transactionCount) tracked transactions",
                unlocked: data.transactionCount >= 25
            ),
            MeAchievement(
                emoji: "🧘",
                name: "Zen Master",
                date: "\(streakDays) day streak",
                unlocked: streakDays >= 7
            ),
        ]
    }

    private var insightMessage: String {
        guard !data.allTransactions.isEmpty || !data.accounts.isEmpty || data.totalMonthlyBudget > 0 else {
            return "Start by adding an account, setting a daily budget, or logging a transaction. Penny will build insights from the data you enter."
        }

        let comparison = data.monthToDateComparison()
        let topCategory = data.topCategories.first?.name ?? "spending"
        let direction = comparison.delta <= 0 ? "down" : "up"
        let percent = Int(abs(comparison.percentChange) * 100)
        return "\(topCategory) is your top category and spending is \(direction) \(percent)% vs last month. You still have \(currencyString(data.safeToSpendThisMonth)) safe to spend."
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection

                    MeProfileHeader()

                    MeStatsGrid(stats: stats)
                    MeInsightCard(title: "Penny Insight", message: insightMessage)

                    MeMenuGroup(items: menuItems1, onTap: handleMenuTap1)
                        .padding(.bottom, 24)

                    MeAchievementsSection(achievements: achievements)

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
    private let menuItems1 = [
        MeMenuItem(icon: "chart.pie.fill",  label: "Budget & Goals"),
        MeMenuItem(icon: "lock.fill",       label: "Connected Banks", badge: TransactionData.shared.accounts.isEmpty ? "None" : "\(TransactionData.shared.accounts.count) Active"),
        MeMenuItem(icon: "bell.fill",       label: "Notifications"),
    ]

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
        ZStack {
            MeTheme.canvas.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.25),
                    Color(red: 1.0, green: 0.376, blue: 0.125).opacity(0.05),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }

    private func currencyString(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        return "\(sign)$\(String(format: "%.0f", abs(value)))"
    }
}

#Preview {
    MeView()
        .preferredColorScheme(.dark)
}
