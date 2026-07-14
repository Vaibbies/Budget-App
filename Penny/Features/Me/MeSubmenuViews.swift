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
    @Environment(PennyPlatform.self) private var platform
    @AppStorage("penny.ai.proactiveInsights") private var proactiveInsights = true
    @AppStorage("penny.ai.weeklyCoaching") private var weeklyCoaching = true
    @AppStorage("penny.ai.toughLoveTone") private var roastOverspending = false
    @AppStorage("penny.ai.savingsTone") private var savingsTone = 1.0

    var body: some View {
        let aiSnapshot = platform.aiAssistantService.snapshot()
        let capabilities = platform.capabilities

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
                    title: "Architecture",
                    rows: [
                        MeDetailRowModel(icon: "message.badge.waveform.fill", title: "Conversation Surface", subtitle: "In-app assistant shell is already present", value: aiSnapshot.hasConversationUI ? "Ready" : "Missing", valueColor: aiSnapshot.hasConversationUI ? MeTheme.success : MeTheme.accent),
                        MeDetailRowModel(icon: "tray.full.fill", title: "Finance Context Layer", subtitle: "Structured budgets, accounts, transactions, and recurring context for AI", value: aiSnapshot.hasStructuredFinanceContext ? "Wired" : "Next", valueColor: aiSnapshot.hasStructuredFinanceContext ? MeTheme.success : warmPendingColor),
                        MeDetailRowModel(icon: "network", title: "Server-backed Inference", subtitle: "Authenticated API service for real model calls and tool execution", value: aiSnapshot.hasServerBackedInference ? "Live" : "Not Connected", valueColor: aiSnapshot.hasServerBackedInference ? MeTheme.success : warmPendingColor),
                        MeDetailRowModel(icon: "bolt.badge.clock", title: "Action Execution", subtitle: "Workers and assistants taking follow-up actions after insights", value: aiSnapshot.hasActionExecution ? "Enabled" : "Planned", valueColor: aiSnapshot.hasActionExecution ? MeTheme.success : warmPendingColor),
                        MeDetailRowModel(icon: "square.3.stack.3d.top.filled", title: "Overall Readiness", subtitle: "Current AI platform maturity for competing with Copilot", value: aiSnapshot.readiness.rawValue, valueColor: readinessColor(aiSnapshot.readiness))
                    ]
                ),
                MeDetailSectionModel(
                    title: "Dependencies",
                    rows: [
                        MeDetailRowModel(icon: "person.3.fill", title: "User & Household Service", subtitle: "Foundation for shared assistants, shared budgets, and collaborative plans", value: capabilities.userHouseholds.rawValue, valueColor: readinessColor(capabilities.userHouseholds)),
                        MeDetailRowModel(icon: "creditcard.and.123", title: "Account & Transaction Service", subtitle: "Needed before the assistant can answer with trustworthy financial facts", value: capabilities.accountsTransactions.rawValue, valueColor: readinessColor(capabilities.accountsTransactions)),
                        MeDetailRowModel(icon: "bell.badge.fill", title: "Notification Service", subtitle: "Required for AI follow-ups, recurring alerts, and proactive nudges", value: capabilities.notificationEngine.rawValue, valueColor: readinessColor(capabilities.notificationEngine))
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

    private var warmPendingColor: Color {
        Color(red: 0.98, green: 0.74, blue: 0.34)
    }

    private func readinessColor(_ readiness: ServiceReadiness) -> Color {
        switch readiness {
        case .backendReady:
            return MeTheme.success
        case .foundationReady:
            return warmPendingColor
        case .localOnly:
            return .white.opacity(0.55)
        }
    }
}

struct BudgetGoalsView: View {
    @Environment(SpendingStore.self) private var spending

    private var savingsGoalRows: [MeDetailRowModel] {
        if spending.savingsGoals.isEmpty {
            return [
                MeDetailRowModel(
                    icon: "target",
                    title: "No Goals Yet",
                    subtitle: "Create a savings goal after you finish entering your accounts and spending targets",
                    value: "Empty"
                )
            ]
        }

        return spending.savingsGoals.map {
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
                        MeDetailRowModel(icon: "chart.pie.fill", title: "Monthly Budget", subtitle: "Configured budget across tracked categories", value: "$\(Int(spending.totalMonthlyBudget))"),
                        MeDetailRowModel(icon: "arrow.down.circle.fill", title: "Month-to-Date Spend", subtitle: "Budgetable spending this month", value: "$\(Int(spending.monthlySpent))"),
                        MeDetailRowModel(icon: "checkmark.seal.fill", title: "Safe to Spend", subtitle: "After accounting for upcoming bills", value: "$\(Int(spending.safeToSpendThisMonth))", valueColor: MeTheme.success)
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
    @Environment(PennyPlatform.self) private var platform

    private var lastRefreshLabel: String {
        let refreshDates = platform.accountTransactionService.institutionConnections().compactMap(\.lastSyncedAt)
        guard !refreshDates.isEmpty else { return "No data" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: refreshDates.max() ?? Date())
    }

    private var linkedAccountRows: [MeDetailRowModel] {
        let accounts = platform.accountTransactionService.accounts()
        if accounts.isEmpty {
            return [
                MeDetailRowModel(
                    icon: "building.columns.fill",
                    title: "No Accounts Added",
                    subtitle: "Add checking, savings, credit, or cash accounts from the Bank tab",
                    value: "Empty"
                )
            ]
        }

        return accounts.map { account in
            MeDetailRowModel(
                icon: accountIcon(for: account.accountType),
                title: account.name,
                subtitle: account.institution,
                value: currencyString(account.effectiveBalance),
                valueColor: account.effectiveBalance >= 0 ? .white.opacity(0.75) : MeTheme.accent
            )
        }
    }

    var body: some View {
        let connections = platform.accountTransactionService.institutionConnections()
        let capabilities = platform.capabilities

        MeDetailScaffold(
            title: "CONNECTED BANKS",
            sections: [
                MeDetailSectionModel(
                    title: "Linked Accounts",
                    rows: linkedAccountRows
                ),
                MeDetailSectionModel(
                    title: "Institutions",
                    rows: connections.isEmpty ? [
                        MeDetailRowModel(
                            icon: "link.badge.plus",
                            title: "No Institution Layer Yet",
                            subtitle: "Manual accounts work today; Plaid, MX, or Finicity can plug in here later",
                            value: "Manual"
                        )
                    ] : connections.map { connection in
                        MeDetailRowModel(
                            icon: "building.columns.fill",
                            title: connection.displayName,
                            subtitle: "\(connection.linkedAccountCount) linked accounts • \(connection.syncLabel)",
                            value: connection.syncHealth.rawValue,
                            valueColor: syncColor(connection.syncHealth)
                        )
                    }
                ),
                MeDetailSectionModel(
                    title: "Connection Status",
                    rows: [
                        MeDetailRowModel(icon: "link.badge.plus", title: "Linked Accounts", subtitle: "Tracked account connections in this profile", value: "\(platform.accountTransactionService.accounts().count)", valueColor: platform.accountTransactionService.accounts().isEmpty ? .white.opacity(0.6) : MeTheme.success),
                        MeDetailRowModel(icon: "clock.arrow.circlepath", title: "Latest Refresh", subtitle: "Most recent account balance update", value: lastRefreshLabel),
                        MeDetailRowModel(icon: "shield.lefthalf.filled", title: "Connection Mode", subtitle: "Current account sync mode for this build", value: "Local First"),
                        MeDetailRowModel(icon: "server.rack", title: "Aggregator Layer", subtitle: "Backend-ready seam for Plaid, MX, or Finicity", value: capabilities.dataAggregators.rawValue, valueColor: readinessColor(capabilities.dataAggregators)),
                        MeDetailRowModel(icon: "lock.shield.fill", title: "Authenticated API", subtitle: "Needed before real institution sync can run safely", value: capabilities.authenticatedAPI.rawValue, valueColor: readinessColor(capabilities.authenticatedAPI))
                    ]
                )
            ],
            banner: nil
        )
    }

    private func accountIcon(for type: String) -> String {
        switch type {
        case AccountType.checking.rawValue: return "banknote.fill"
        case AccountType.savings.rawValue: return "tray.full.fill"
        case AccountType.creditCard.rawValue: return "creditcard.fill"
        case AccountType.investment.rawValue: return "chart.line.uptrend.xyaxis"
        case AccountType.loan.rawValue: return "building.columns.fill"
        case AccountType.cash.rawValue: return "dollarsign.circle.fill"
        default: return "creditcard.fill"
        }
    }

    private func currencyString(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        return "\(sign)$\(String(format: "%.0f", abs(value)))"
    }

    private func syncColor(_ health: SyncHealth) -> Color {
        switch health {
        case .healthy:
            return MeTheme.success
        case .needsAttention:
            return MeTheme.accent
        case .paused:
            return .white.opacity(0.6)
        case .notConfigured:
            return .white.opacity(0.55)
        }
    }

    private func readinessColor(_ readiness: ServiceReadiness) -> Color {
        switch readiness {
        case .backendReady:
            return MeTheme.success
        case .foundationReady:
            return Color(red: 0.98, green: 0.74, blue: 0.34)
        case .localOnly:
            return .white.opacity(0.55)
        }
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
