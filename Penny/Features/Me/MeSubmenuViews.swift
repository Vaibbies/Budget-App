import SwiftUI

private struct MeDetailRowModel: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let value: String?
    var valueColor: Color = .white.opacity(0.6)
}

private struct MeDetailSectionModel: Identifiable {
    let id = UUID()
    let title: String
    let rows: [MeDetailRowModel]
}

private struct MeDetailScaffold: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let sections: [MeDetailSectionModel]
    let banner: AnyView?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection

                if let banner {
                    banner
                        .padding(.bottom, sections.isEmpty ? 0 : 24)
                }

                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                    sectionLabel(section.title)
                    detailCard(section.rows)
                        .padding(.bottom, index == sections.count - 1 ? 40 : 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(backgroundGradient)
        .navigationBarHidden(true)
    }

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

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
    }

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

    private func detailCard(_ rows: [MeDetailRowModel]) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: row.icon)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(row.title)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Text(row.subtitle)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Spacer()

                    if let value = row.value {
                        Text(value)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(row.valueColor)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(16)

                if index < rows.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.05))
                        .padding(.leading, 56)
                }
            }
        }
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(MeTheme.glassBorder, lineWidth: 1)
        )
    }

    private var backgroundGradient: some View {
        PennyWarmBackground()
    }
}

struct PennyAISettingsView: View {
    @AppStorage("penny.ai.proactiveInsights") private var proactiveInsights = true
    @AppStorage("penny.ai.weeklyCoaching") private var weeklyCoaching = true
    @AppStorage("penny.ai.toughLoveTone") private var roastOverspending = false
    @AppStorage("penny.ai.savingsTone") private var savingsTone = 1.0

    var body: some View {
        MeDetailScaffold(
            title: "PENNY AI SETTINGS",
            sections: [
                MeDetailSectionModel(
                    title: "Behavior",
                    rows: [
                        MeDetailRowModel(icon: "sparkles", title: "Proactive Insights", subtitle: "Let Penny surface trends before you ask", value: proactiveInsights ? "On" : "Off", valueColor: proactiveInsights ? MeTheme.success : .white.opacity(0.5)),
                        MeDetailRowModel(icon: "calendar.badge.clock", title: "Weekly Coaching", subtitle: "Deliver one habit review every Sunday", value: weeklyCoaching ? "Enabled" : "Paused", valueColor: weeklyCoaching ? MeTheme.success : .white.opacity(0.5)),
                        MeDetailRowModel(icon: "theatermasks.fill", title: "Tough Love Tone", subtitle: "Sharper wording when spending spikes", value: roastOverspending ? "Armed" : "Gentle", valueColor: roastOverspending ? MeTheme.accent : .white.opacity(0.5))
                    ]
                ),
                MeDetailSectionModel(
                    title: "Context",
                    rows: [
                        MeDetailRowModel(icon: "text.bubble.fill", title: "Default Assistant Style", subtitle: "Short, direct answers with actionable steps", value: "Concise"),
                        MeDetailRowModel(icon: "brain.head.profile", title: "Goal Awareness", subtitle: "Reference savings goals before suggesting new spend", value: "High"),
                        MeDetailRowModel(icon: "lock.doc.fill", title: "Sensitive Categories", subtitle: "Keep health and transfers out of AI summaries", value: "Protected", valueColor: MeTheme.success)
                    ]
                )
            ],
            banner: AnyView(
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(MeTheme.accent.opacity(0.12))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(MeTheme.accent)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text("PENNY PERSONALITY")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(MeTheme.accent)
                                .tracking(1.5)

                            Text("Tune how assertive Penny should be when it sees budget drift, subscription creep, or impulse spikes.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.55))
                                .lineSpacing(3)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Savings Motivation")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                            Spacer()
                            Text(savingsTone < 0.5 ? "Balanced" : "Aggressive")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(MeTheme.accent)
                        }

                        Slider(value: $savingsTone)
                            .tint(MeTheme.accent)
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
            )
        )
    }
}

struct BudgetGoalsView: View {
    private let data = TransactionData.shared

    private var savingsGoalRows: [MeDetailRowModel] {
        if data.savingsGoals.isEmpty {
            return [
                MeDetailRowModel(
                    icon: "target",
                    title: "No Goals Yet",
                    subtitle: "Create a savings goal after you finish entering your accounts and spending targets",
                    value: "Empty"
                )
            ]
        }

        return data.savingsGoals.map {
            MeDetailRowModel(
                icon: "target",
                title: $0.name,
                subtitle: "Saved $\(Int($0.currentAmount)) of $\(Int($0.targetAmount))",
                value: "\($0.targetAmount == 0 ? 0 : Int(($0.currentAmount / $0.targetAmount) * 100))%",
                valueColor: MeTheme.accent
            )
        }
    }

    var body: some View {
        MeDetailScaffold(
            title: "BUDGET & GOALS",
            sections: [
                MeDetailSectionModel(
                    title: "Budget Health",
                    rows: [
                        MeDetailRowModel(icon: "chart.pie.fill", title: "Monthly Budget", subtitle: "Configured budget across tracked categories", value: "$\(Int(data.totalMonthlyBudget))"),
                        MeDetailRowModel(icon: "arrow.down.circle.fill", title: "Month-to-Date Spend", subtitle: "Budgetable spending this month", value: "$\(Int(data.monthlySpent))"),
                        MeDetailRowModel(icon: "checkmark.seal.fill", title: "Safe to Spend", subtitle: "After accounting for upcoming bills", value: "$\(Int(data.safeToSpendThisMonth))", valueColor: MeTheme.success)
                    ]
                ),
                MeDetailSectionModel(
                    title: "Savings Goals",
                    rows: savingsGoalRows
                )
            ],
            banner: nil
        )
    }
}

struct ConnectedBanksView: View {
    private let data = TransactionData.shared

    private var lastRefreshLabel: String {
        guard !data.accounts.isEmpty else { return "No data" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: data.accounts.map(\.lastUpdated).max() ?? Date())
    }

    private var linkedAccountRows: [MeDetailRowModel] {
        if data.accounts.isEmpty {
            return [
                MeDetailRowModel(
                    icon: "building.columns.fill",
                    title: "No Accounts Added",
                    subtitle: "Add checking, savings, credit, or cash accounts from the Bank tab",
                    value: "Empty"
                )
            ]
        }

        return data.accounts.map { account in
            MeDetailRowModel(
                icon: accountIcon(for: account.type),
                title: account.name,
                subtitle: account.institution,
                value: currencyString(account.balance),
                valueColor: account.balance >= 0 ? .white.opacity(0.75) : MeTheme.accent
            )
        }
    }

    var body: some View {
        MeDetailScaffold(
            title: "CONNECTED BANKS",
            sections: [
                MeDetailSectionModel(
                    title: "Linked Accounts",
                    rows: linkedAccountRows
                ),
                MeDetailSectionModel(
                    title: "Connection Status",
                    rows: [
                        MeDetailRowModel(icon: "link.badge.plus", title: "Linked Accounts", subtitle: "Tracked account connections in this profile", value: "\(data.accounts.count)", valueColor: data.accounts.isEmpty ? .white.opacity(0.6) : MeTheme.success),
                        MeDetailRowModel(icon: "clock.arrow.circlepath", title: "Latest Refresh", subtitle: "Most recent account balance update", value: lastRefreshLabel),
                        MeDetailRowModel(icon: "shield.lefthalf.filled", title: "Connection Mode", subtitle: "Current account sync mode for this build", value: "Local First")
                    ]
                )
            ],
            banner: nil
        )
    }

    private func accountIcon(for type: AccountType) -> String {
        switch type {
        case .checking: return "banknote.fill"
        case .savings: return "tray.full.fill"
        case .creditCard: return "creditcard.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .loan: return "building.columns.fill"
        case .cash: return "dollarsign.circle.fill"
        }
    }

    private func currencyString(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        return "\(sign)$\(String(format: "%.0f", abs(value)))"
    }
}

struct PrivacySecurityView: View {
    var body: some View {
        MeDetailScaffold(
            title: "PRIVACY & SECURITY",
            sections: [
                MeDetailSectionModel(
                    title: "Protection",
                    rows: [
                        MeDetailRowModel(icon: "lock.fill", title: "App Lock", subtitle: "Require Face ID before revealing balances", value: "Enabled", valueColor: MeTheme.success),
                        MeDetailRowModel(icon: "eye.slash.fill", title: "Sensitive Screenshots", subtitle: "Blur balances in the app switcher", value: "On", valueColor: MeTheme.success),
                        MeDetailRowModel(icon: "person.crop.circle.badge.checkmark", title: "Trusted Device", subtitle: "This iPhone is marked as primary", value: "Primary")
                    ]
                ),
                MeDetailSectionModel(
                    title: "Data",
                    rows: [
                        MeDetailRowModel(icon: "tray.and.arrow.down.fill", title: "Data Export", subtitle: "Download your transactions and settings", value: "Available"),
                        MeDetailRowModel(icon: "trash.fill", title: "Delete Local Data", subtitle: "Erase budgets, goals, and cached balances", value: "Manual"),
                        MeDetailRowModel(icon: "network.slash", title: "Tracking", subtitle: "No third-party analytics configured in this build", value: "Off", valueColor: MeTheme.success)
                    ]
                )
            ],
            banner: nil
        )
    }
}

struct FriendsCommunityView: View {
    var body: some View {
        MeDetailScaffold(
            title: "FRIENDS & COMMUNITY",
            sections: [
                MeDetailSectionModel(
                    title: "Social Layer",
                    rows: [
                        MeDetailRowModel(icon: "person.2.fill", title: "Connected Friends", subtitle: "No one is linked to this profile yet", value: "0"),
                        MeDetailRowModel(icon: "gift.fill", title: "Split Challenges", subtitle: "Shared goals will appear here once social features are enabled", value: "Empty"),
                        MeDetailRowModel(icon: "trophy.fill", title: "Leaderboard", subtitle: "No leaderboard data until you invite friends", value: "None")
                    ]
                ),
                MeDetailSectionModel(
                    title: "Permissions",
                    rows: [
                        MeDetailRowModel(icon: "hand.raised.fill", title: "Visible Metrics", subtitle: "Nothing is shared until you explicitly enable social features", value: "Off", valueColor: MeTheme.success),
                        MeDetailRowModel(icon: "message.fill", title: "Encouragement Nudges", subtitle: "No nudges will be sent because there are no connected friends", value: "Off", valueColor: MeTheme.success)
                    ]
                )
            ],
            banner: nil
        )
    }
}

struct HelpFAQsView: View {
    private var versionLabel: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? version
        return "\(version) (\(build))"
    }

    var body: some View {
        MeDetailScaffold(
            title: "HELP & FAQS",
            sections: [
                MeDetailSectionModel(
                    title: "Common Topics",
                    rows: [
                        MeDetailRowModel(icon: "questionmark.circle.fill", title: "How budgets work", subtitle: "Monthly budgets exclude transfers and protected categories", value: "Read"),
                        MeDetailRowModel(icon: "repeat.circle.fill", title: "Recurring charges", subtitle: "Subscriptions can auto-log and affect safe-to-spend", value: "Read"),
                        MeDetailRowModel(icon: "brain.fill", title: "Penny AI", subtitle: "Insights are based on local app data in this build", value: "Read")
                    ]
                ),
                MeDetailSectionModel(
                    title: "Diagnostics",
                    rows: [
                        MeDetailRowModel(icon: "ladybug.fill", title: "Report a bug", subtitle: "Capture the screen and current flow before filing", value: "Ready"),
                        MeDetailRowModel(icon: "square.and.arrow.up.fill", title: "Share app version", subtitle: "Include the running build in support requests", value: versionLabel)
                    ]
                )
            ],
            banner: nil
        )
    }
}

struct ContactSupportView: View {
    var body: some View {
        MeDetailScaffold(
            title: "CONTACT SUPPORT",
            sections: [
                MeDetailSectionModel(
                    title: "Channels",
                    rows: [
                        MeDetailRowModel(icon: "envelope.fill", title: "Email Support", subtitle: "Best for account, billing, or bug reports", value: "support@penny.app"),
                        MeDetailRowModel(icon: "message.fill", title: "In-App Message", subtitle: "Fastest route for feature questions", value: "Available"),
                        MeDetailRowModel(icon: "doc.text.fill", title: "Response Time", subtitle: "Typical turnaround for detailed issues", value: "< 24 hrs", valueColor: MeTheme.success)
                    ]
                ),
                MeDetailSectionModel(
                    title: "Before You Send",
                    rows: [
                        MeDetailRowModel(icon: "paperclip.fill", title: "Attach Screenshots", subtitle: "Include the screen and the action that failed", value: "Recommended"),
                        MeDetailRowModel(icon: "text.bubble.fill", title: "Describe the Goal", subtitle: "Say what you expected, not just what broke", value: "Required")
                    ]
                )
            ],
            banner: nil
        )
    }
}
