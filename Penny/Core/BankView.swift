import SwiftUI

struct BankView: View {
    private let data = TransactionData.shared
    private let warmAccent = Color(red: 1.0, green: 0.42, blue: 0.16)
    private let warmAccentSoft = Color(red: 1.0, green: 0.55, blue: 0.36)
    private let warmGold = Color(red: 0.98, green: 0.74, blue: 0.34)
    private let warmCream = Color(red: 0.95, green: 0.86, blue: 0.72)
    private let warmRose = Color(red: 0.86, green: 0.53, blue: 0.42)
    private let warmOlive = Color(red: 0.67, green: 0.73, blue: 0.42)

    @State private var showAddAccount = false
    @State private var editingAccount: Account?
    @State private var showBudgetEditor = false
    @State private var selectedAccountForTransactions: Account?
    @State private var selectedInvestmentAccount: Account?
    @State private var showCashFlow = false

    private var visibleAccounts: [Account] {
        data.visibleAccounts
    }

    private var cashFlowForecast: CashFlowForecast {
        data.cashFlowForecast
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                headerSection

                heroCard
                    .padding(.bottom, 24)

                budgetCard
                    .padding(.bottom, 24)

                metricGrid
                    .padding(.bottom, 24)

                if !data.investmentAccounts.isEmpty || !data.investmentHoldings.isEmpty {
                    sectionHeader("Investments", actionTitle: data.investmentAccounts.isEmpty ? nil : "Manage") {
                        selectedInvestmentAccount = data.investmentAccounts.first
                    }
                    investmentSection
                        .padding(.bottom, 24)
                }

                sectionHeader("Accounts", actionTitle: visibleAccounts.isEmpty ? nil : "Add") {
                    showAddAccount = true
                }
                accountsSection
                    .padding(.bottom, 24)

                if !data.savingsGoals.isEmpty {
                    sectionHeader("Progress")
                    goalsSection
                        .padding(.bottom, 24)
                }

                sectionHeader("Snapshot", actionTitle: "Forecast") {
                    showCashFlow = true
                }
                healthSection
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(backgroundGradient)
        .sheet(isPresented: $showAddAccount) {
            AccountEditorView()
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingAccount) { account in
            AccountEditorView(account: account)
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showBudgetEditor) {
            DailyBudgetEditorView()
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedAccountForTransactions) { account in
            TransactionsView(initialAccountId: account.id)
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedInvestmentAccount) { account in
            InvestmentAccountDetailView(account: account)
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showCashFlow) {
            CashFlowView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }

    private var headerSection: some View {
        HStack {
            Text("BANK")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Spacer()

            Button {
                showAddAccount = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add Account")
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(warmAccentSoft)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(warmAccent.opacity(0.08))
                        .overlay(Capsule().stroke(warmAccent.opacity(0.20), lineWidth: 1))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("NET WORTH")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.45))

            VStack(alignment: .leading, spacing: 6) {
                Text(currencyString(data.netWorthBalance))
                    .font(.system(size: 42, weight: .light, design: .serif))
                    .foregroundColor(.white)

                Text(heroSubtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            }

            HStack(spacing: 12) {
                balancePill(label: "Assets", value: currencyString(data.totalAssetsBalance), color: warmGold)
                balancePill(label: "Liabilities", value: currencyString(data.totalLiabilitiesBalance), color: warmAccent)
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.16, green: 0.09, blue: 0.07),
                            Color(red: 0.07, green: 0.04, blue: 0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var heroSubtitle: String {
        if visibleAccounts.isEmpty {
            return "Add your real accounts here and the rest of the app will use these balances."
        }
        if data.investmentPerformance().holdingsCount > 0 {
            return "\(data.investmentPerformance().holdingsCount) holdings tracked across \(data.investmentAccounts.count) investment accounts"
        }
        return "\(visibleAccounts.count) manual accounts powering your balances and safe-to-spend numbers"
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SPENDING BUDGETS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.45))

                    Text(currencyString(data.configuredBudgetValue > 0 ? data.configuredBudgetValue : data.totalMonthlyBudget))
                        .font(.system(size: 30, weight: .light, design: .serif))
                        .foregroundColor(.white)

                    Text(data.budgetMode == .daily ? "Configured as a daily budget" : "Configured as a monthly budget")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.42))
                }

                Spacer()

                Button {
                    showBudgetEditor = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(warmAccentSoft)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(warmAccent.opacity(0.10))
                                .overlay(Capsule().stroke(warmAccent.opacity(0.22), lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                metricChip(
                    title: "Spent Today",
                    value: currencyString(data.dailySpent),
                    accent: warmAccent
                )

                metricChip(
                    title: "Remaining",
                    value: currencyString(data.dailyRemaining),
                    accent: warmGold
                )
            }

            HStack(spacing: 10) {
                metricChip(
                    title: "Daily Budget",
                    value: currencyString(data.dailyBudget),
                    accent: warmCream
                )

                metricChip(
                    title: "Monthly Budget",
                    value: currencyString(data.totalMonthlyBudget),
                    accent: warmRose
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }

    private var metricGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                metricCard(
                    title: "LIQUID CASH",
                    value: currencyString(data.liquidCashBalance),
                    subtitle: "checking + savings + cash",
                    accent: warmGold
                )

                metricCard(
                    title: "INVESTMENTS",
                    value: currencyString(data.investedBalance),
                    subtitle: "investment accounts",
                    accent: warmCream
                )
            }

            HStack(spacing: 10) {
                metricCard(
                    title: "TOTAL DEBT",
                    value: currencyString(data.totalDebtBalance),
                    subtitle: "cards + loans",
                    accent: warmAccent
                )

                metricCard(
                    title: "SAFE TO SPEND",
                    value: currencyString(data.safeToSpendThisMonth),
                    subtitle: "budget and cash constrained",
                    accent: warmOlive
                )
            }
        }
    }

    private var accountsSection: some View {
        Group {
            if visibleAccounts.isEmpty {
                emptyAccountsState
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(visibleAccounts.enumerated()), id: \.element.id) { index, account in
                        accountRow(account)

                        if index < visibleAccounts.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.05))
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
        }
    }

    private var investmentSection: some View {
        let summary = data.investmentPerformance()
        let allocation = data.portfolioAllocation()

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                metricChip(
                    title: "Portfolio Value",
                    value: currencyString(summary.marketValue),
                    accent: warmCream
                )

                metricChip(
                    title: "Gain / Loss",
                    value: signedCurrencyString(summary.gainLoss),
                    accent: summary.gainLoss >= 0 ? warmOlive : warmAccent
                )
            }

            HStack(spacing: 10) {
                metricChip(
                    title: "Cost Basis",
                    value: currencyString(summary.costBasis),
                    accent: warmGold
                )

                metricChip(
                    title: "Return",
                    value: percentString(summary.gainLossPercent),
                    accent: summary.gainLossPercent >= 0 ? warmOlive : warmRose
                )
            }

            if allocation.isEmpty {
                Text("Add holdings to an investment account to unlock allocation and performance details.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.top, 2)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("ASSET ALLOCATION")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.35))

                    ForEach(allocation) { slice in
                        allocationRow(slice)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var emptyAccountsState: some View {
        VStack(spacing: 14) {
            Image(systemName: "building.columns.circle")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.white.opacity(0.45))

            VStack(spacing: 6) {
                Text("No accounts yet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text("Add your checking, savings, cards, or investments here. These balances will drive the Bank tab and spending capacity across the app.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }

            Button {
                showAddAccount = true
            } label: {
                Text("Add Your First Account")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.55, blue: 0.36),
                                        Color(red: 1.0, green: 0.42, blue: 0.16)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func accountRow(_ account: Account) -> some View {
        let monthSpend = data.monthlySpend(forAccount: account.id)
        let monthIncome = data.monthlyIncome(forAccount: account.id)
        let monthNet = data.monthlyNet(forAccount: account.id)
        let transactionCount = data.transactions(forAccount: account.id).count
        let investmentSummary = data.investmentPerformance(forAccount: account.id)
        let hasActivity = account.type == .investment
            ? investmentSummary.holdingsCount > 0
            : transactionCount > 0 || monthSpend > 0 || monthIncome > 0

        return HStack(spacing: 14) {
            Button {
                if account.type == .investment {
                    selectedInvestmentAccount = account
                } else {
                    selectedAccountForTransactions = account
                }
            } label: {
                HStack(spacing: 14) {
                    Circle()
                        .fill(accountAccent(for: account.type).opacity(0.14))
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: accountIcon(for: account.type))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(accountAccent(for: account.type))
                        )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(account.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Text(account.institution)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text(currencyString(data.effectiveBalance(for: account)))
                            .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundColor(data.effectiveBalance(for: account) >= 0 ? .white : Color(red: 1.0, green: 0.42, blue: 0.16))

                        Text(account.type.rawValue.uppercased())
                            .font(.system(size: 9, weight: .medium))
                            .tracking(1)
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
            }
            .buttonStyle(.plain)

            Button {
                editingAccount = account
            } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.05))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button {
                data.deleteAccount(id: account.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                    .frame(width: 30, height: 30)
                    .background(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.08))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .overlay(alignment: .bottomLeading) {
            Group {
                if hasActivity {
                    if account.type == .investment {
                        HStack(spacing: 8) {
                            accountActivityPill(
                                title: "Holdings",
                                value: "\(investmentSummary.holdingsCount)",
                                accent: warmCream
                            )

                            accountActivityPill(
                                title: "Gain/Loss",
                                value: signedCurrencyString(investmentSummary.gainLoss),
                                accent: investmentSummary.gainLoss >= 0 ? warmOlive : warmRose
                            )

                            accountActivityPill(
                                title: "Return",
                                value: percentString(investmentSummary.gainLossPercent),
                                accent: investmentSummary.gainLossPercent >= 0 ? warmOlive : warmRose
                            )
                        }
                        .padding(.leading, 52)
                        .padding(.bottom, 6)
                    } else {
                        HStack(spacing: 8) {
                            accountActivityPill(
                                title: "Spent",
                                value: currencyString(monthSpend),
                                accent: warmAccent
                            )

                            if monthIncome > 0 {
                                accountActivityPill(
                                    title: "Income",
                                    value: currencyString(monthIncome),
                                    accent: warmGold
                                )
                            }

                            accountActivityPill(
                                title: "Net",
                                value: currencyString(monthNet),
                                accent: monthNet >= 0 ? warmOlive : warmRose
                            )
                        }
                        .padding(.leading, 52)
                        .padding(.bottom, 6)
                    }
                }
            }
        }
        .padding(.bottom, hasActivity ? 36 : 0)
    }

    private func accountActivityPill(title: String, value: String, accent: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(accent)
                .frame(width: 5, height: 5)

            Text("\(title): \(value)")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.72))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.05))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private var goalsSection: some View {
        VStack(spacing: 10) {
            ForEach(data.savingsGoals) { goal in
                let progress = goal.targetAmount == 0 ? 0 : min(goal.currentAmount / goal.targetAmount, 1)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.name)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))

                            Text("\(currencyString(goal.currentAmount)) of \(currencyString(goal.targetAmount))")
                                .font(.system(size: 11, weight: .regular))
                                .foregroundColor(.white.opacity(0.45))
                        }

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(warmAccentSoft)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [warmAccentSoft, warmAccent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(16)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
        }
    }

    private var healthSection: some View {
        VStack(spacing: 0) {
            snapshotRow(title: "Daily Budget", subtitle: "current daily budget for this month", value: currencyString(data.dailyBudget), valueColor: .white.opacity(0.8))
            divider
            snapshotRow(title: "Monthly Budget", subtitle: "current monthly budget for this month", value: currencyString(data.totalMonthlyBudget), valueColor: .white.opacity(0.8))
            divider
            snapshotRow(title: "Monthly Net", subtitle: "income minus budgetable spend", value: currencyString(data.monthlyNet), valueColor: data.monthlyNet >= 0 ? warmGold : warmAccent)
            divider
            snapshotRow(title: "Projected Month End", subtitle: "starting cash plus forecasted inflows and bills", value: currencyString(cashFlowForecast.projectedEndOfMonthCash), valueColor: cashFlowForecast.projectedEndOfMonthCash >= 0 ? .white.opacity(0.75) : warmAccent)
            divider
            snapshotRow(title: "Expected Bills", subtitle: "dated recurring charges in this forecast window", value: currencyString(cashFlowForecast.expectedBills), valueColor: .white.opacity(0.75))
            divider
            snapshotRow(title: "Expected Income", subtitle: "inferred paychecks and deposits this cycle", value: currencyString(cashFlowForecast.expectedIncome), valueColor: warmGold)
            divider
            snapshotRow(title: "Goal Progress", subtitle: "saved across all active goals", value: currencyString(data.totalGoalProgress), valueColor: warmGold)
        }
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func snapshotRow(title: String, subtitle: String, value: String, valueColor: Color) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(valueColor)
        }
        .padding(16)
    }

    private var divider: some View {
        Divider()
            .background(Color.white.opacity(0.05))
            .padding(.leading, 16)
    }

    private func sectionHeader(_ text: String, actionTitle: String? = nil, action: (() -> Void)? = nil) -> some View {
        HStack {
            Text(text.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .tracking(2)

            Spacer()

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(warmAccentSoft)
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 10)
    }

    private func balancePill(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.4))

            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .serif))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.22), lineWidth: 1)
                )
        )
    }

    private func metricChip(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.4))

            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 6, height: 6)

                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .serif))
                    .foregroundColor(.white)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func metricCard(title: String, value: String, subtitle: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.4))

            Text(value)
                .font(.system(size: 20, weight: .light, design: .serif))
                .foregroundColor(.white)

            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 6, height: 6)

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.45))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func allocationRow(_ slice: PortfolioAllocationSlice) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(allocationAccent(for: slice.assetClass))
                .frame(width: 8, height: 8)

            Text(slice.assetClass.rawValue)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.78))

            Spacer()

            Text(currencyString(slice.marketValue))
                .font(.system(size: 12, weight: .semibold, design: .serif))
                .foregroundColor(.white)

            Text(percentString(slice.percentage))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.45))
                .frame(width: 48, alignment: .trailing)
        }
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

    private func accountAccent(for type: AccountType) -> Color {
        switch type {
        case .checking: return warmAccentSoft
        case .savings: return warmGold
        case .creditCard: return warmAccent
        case .investment: return warmCream
        case .loan: return warmRose
        case .cash: return warmOlive
        }
    }

    private func allocationAccent(for assetClass: InvestmentAssetClass) -> Color {
        switch assetClass {
        case .stock: return warmAccentSoft
        case .etf: return warmGold
        case .mutualFund: return warmCream
        case .bond: return warmOlive
        case .crypto: return warmAccent
        case .cash: return .white.opacity(0.7)
        case .alternative: return warmRose
        }
    }

    private func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }

    private func signedCurrencyString(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : "-"
        return prefix + currencyString(abs(value))
    }

    private func percentString(_ value: Double) -> String {
        String(format: "%@%.1f%%", value >= 0 ? "+" : "-", abs(value) * 100)
    }

    private var backgroundGradient: some View {
        PennyWarmBackground()
    }
}

private struct AccountEditorView: View {
    @Environment(\.dismiss) private var dismiss

    private let data = TransactionData.shared
    private let account: Account?
    private let warmAccent = Color(red: 1.0, green: 0.42, blue: 0.16)

    @State private var name: String
    @State private var institution: String
    @State private var type: AccountType
    @State private var balanceText: String

    init(account: Account? = nil) {
        self.account = account
        _name = State(initialValue: account?.name ?? "")
        _institution = State(initialValue: account?.institution ?? "")
        _type = State(initialValue: account?.type ?? .checking)
        _balanceText = State(initialValue: account.map { Self.decimalString(abs($0.balance)) } ?? "")
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !institution.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && parsedNumber(from: balanceText) != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.18, green: 0.11, blue: 0.08),
                        Color(red: 0.08, green: 0.05, blue: 0.04),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        field(title: "Account Name", text: $name, placeholder: "Checking")
                        field(title: "Institution", text: $institution, placeholder: "Chase")

                        VStack(alignment: .leading, spacing: 8) {
                            Text("ACCOUNT TYPE")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))

                            Picker("", selection: $type) {
                                ForEach(AccountType.allCases, id: \.self) { accountType in
                                    Text(accountType.rawValue).tag(accountType)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                        }

                        amountField(
                            title: type == .creditCard || type == .loan ? "Amount Owed" : "Balance",
                            text: $balanceText,
                            placeholder: "0.00"
                        )
                    }
                    .padding(20)
                }
            }
            .navigationTitle(account == nil ? "Add Account" : "Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveAccount() }
                        .foregroundColor(isValid ? warmAccent : .white.opacity(0.3))
                        .disabled(!isValid)
                }
            }
        }
    }

    private func field(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(keyboardType == .default ? .words : .never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
        }
    }

    private func amountField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .onChange(of: text.wrappedValue) { _, newValue in
                    let formatted = Self.formattedAmountInput(newValue)
                    if formatted != newValue {
                        text.wrappedValue = formatted
                    }
                }
        }
    }

    private func saveAccount() {
        guard let rawBalance = parsedNumber(from: balanceText) else { return }

        let storedBalance = data.normalizedBalance(for: type, enteredBalance: rawBalance)
        let finalAccount = Account(
            id: account?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            institution: institution.trimmingCharacters(in: .whitespacesAndNewlines),
            balance: storedBalance,
            lastUpdated: Date(),
            isHidden: false
        )

        data.upsertAccount(finalAccount)
        dismiss()
    }

    private func parsedNumber(from input: String) -> Double? {
        Double(input.replacingOccurrences(of: ",", with: ""))
    }

    private static func decimalString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    private static func formattedAmountInput(_ input: String) -> String {
        let filtered = input.filter { "0123456789.,".contains($0) }
        let normalized = filtered.replacingOccurrences(of: ",", with: "")
        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)

        let integerDigits = String(parts.first ?? "")
        let hasDecimal = normalized.contains(".")
        let rawFraction = parts.count > 1 ? String(parts[1]) : ""
        let fractionDigits = String(rawFraction.prefix(2))

        let integerNumber = Double(integerDigits.isEmpty ? "0" : integerDigits) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        let groupedInteger = formatter.string(from: NSNumber(value: integerNumber)) ?? integerDigits

        if hasDecimal {
            return groupedInteger + "." + fractionDigits
        }

        if integerDigits.isEmpty {
            return ""
        }

        return groupedInteger
    }
}

private struct DailyBudgetEditorView: View {
    @Environment(\.dismiss) private var dismiss

    private let data = TransactionData.shared
    private let warmAccent = Color(red: 1.0, green: 0.42, blue: 0.16)
    @State private var budgetMode: BudgetMode
    @State private var budgetValueText: String

    init() {
        _budgetMode = State(initialValue: TransactionData.shared.budgetMode)
        _budgetValueText = State(initialValue: Self.decimalString(TransactionData.shared.configuredBudgetValue))
    }

    private var budgetValue: Double? {
        Self.parsedNumber(from: budgetValueText)
    }

    private var derivedDailyBudget: Double {
        guard let value = budgetValue else { return 0 }
        switch budgetMode {
        case .daily:
            return value
        case .monthly:
            return value / Double(data.daysInCurrentMonth)
        }
    }

    private var derivedMonthlyBudget: Double {
        guard let value = budgetValue else { return 0 }
        switch budgetMode {
        case .daily:
            return value * Double(data.daysInCurrentMonth)
        case .monthly:
            return value
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.18, green: 0.11, blue: 0.08),
                        Color(red: 0.08, green: 0.05, blue: 0.04),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("BUDGET MODE")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.4))

                        Picker("", selection: $budgetMode) {
                            ForEach(BudgetMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(budgetMode == .daily ? "DAILY BUDGET" : "MONTHLY BUDGET")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.4))

                        TextField("0.00", text: $budgetValueText)
                            .keyboardType(.decimalPad)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                            .onChange(of: budgetValueText) { _, newValue in
                                let formatted = Self.formattedAmountInput(newValue)
                                if formatted != newValue {
                                    budgetValueText = formatted
                                }
                            }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("CALCULATED FOR \(data.daysInCurrentMonth)-DAY MONTH")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.35))

                        HStack {
                            Text("Daily Budget")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text(currencyString(derivedDailyBudget))
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .foregroundColor(.white)
                        }

                        HStack {
                            Text("Monthly Budget")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Text(currencyString(derivedMonthlyBudget))
                                .font(.system(size: 14, weight: .semibold, design: .serif))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.04))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )

                    Spacer()
                }
                .padding(20)
            }
            .onChange(of: budgetMode) { oldMode, newMode in
                guard oldMode != newMode, let currentValue = budgetValue else { return }
                let convertedValue: Double

                switch (oldMode, newMode) {
                case (.daily, .monthly):
                    convertedValue = currentValue * Double(data.daysInCurrentMonth)
                case (.monthly, .daily):
                    convertedValue = currentValue / Double(data.daysInCurrentMonth)
                default:
                    convertedValue = currentValue
                }

                budgetValueText = Self.decimalString(convertedValue)
            }
            .navigationTitle("Budget Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        data.setBudget(mode: budgetMode, value: max(budgetValue ?? 0, 0))
                        dismiss()
                    }
                    .foregroundColor(warmAccent)
                }
            }
        }
    }

    private static func parsedNumber(from input: String) -> Double? {
        Double(input.replacingOccurrences(of: ",", with: ""))
    }

    private static func decimalString(_ value: Double) -> String {
        guard value > 0 else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    private static func formattedAmountInput(_ input: String) -> String {
        let filtered = input.filter { "0123456789.,".contains($0) }
        let normalized = filtered.replacingOccurrences(of: ",", with: "")
        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)

        let integerDigits = String(parts.first ?? "")
        let hasDecimal = normalized.contains(".")
        let rawFraction = parts.count > 1 ? String(parts[1]) : ""
        let fractionDigits = String(rawFraction.prefix(2))

        let integerNumber = Double(integerDigits.isEmpty ? "0" : integerDigits) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        let groupedInteger = formatter.string(from: NSNumber(value: integerNumber)) ?? integerDigits

        if hasDecimal {
            return groupedInteger + "." + fractionDigits
        }

        if integerDigits.isEmpty {
            return ""
        }

        return groupedInteger
    }

    private func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }
}

private struct InvestmentAccountDetailView: View {
    @Environment(\.dismiss) private var dismiss

    private let data = TransactionData.shared
    private let account: Account
    private let warmAccent = Color(red: 1.0, green: 0.42, blue: 0.16)
    private let warmGold = Color(red: 0.98, green: 0.74, blue: 0.34)
    private let warmOlive = Color(red: 0.67, green: 0.73, blue: 0.42)
    private let warmRose = Color(red: 0.86, green: 0.53, blue: 0.42)

    @State private var editingHolding: InvestmentHolding?
    @State private var showAddHolding = false

    init(account: Account) {
        self.account = account
    }

    private var holdings: [InvestmentHolding] {
        data.holdings(forAccount: account.id)
    }

    private var summary: InvestmentPerformanceSummary {
        data.investmentPerformance(forAccount: account.id)
    }

    private var allocation: [PortfolioAllocationSlice] {
        data.portfolioAllocation(forAccount: account.id)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PennyWarmBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        summaryCard
                        allocationCard
                        holdingsCard
                    }
                    .padding(20)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle(account.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Holding") { showAddHolding = true }
                        .foregroundColor(warmAccent)
                }
            }
        }
        .sheet(isPresented: $showAddHolding) {
            InvestmentHoldingEditorView(account: account)
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingHolding) { holding in
            InvestmentHoldingEditorView(account: account, holding: holding)
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PORTFOLIO")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Text(currencyString(summary.marketValue))
                .font(.system(size: 38, weight: .light, design: .serif))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                detailChip(title: "Cost Basis", value: currencyString(summary.costBasis), accent: warmGold)
                detailChip(title: "Gain / Loss", value: signedCurrencyString(summary.gainLoss), accent: summary.gainLoss >= 0 ? warmOlive : warmRose)
            }

            HStack(spacing: 10) {
                detailChip(title: "Return", value: percentString(summary.gainLossPercent), accent: summary.gainLossPercent >= 0 ? warmOlive : warmRose)
                detailChip(title: "Holdings", value: "\(summary.holdingsCount)", accent: warmAccent)
            }
        }
        .padding(20)
        .background(cardBackground)
    }

    private var allocationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALLOCATION")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            if allocation.isEmpty {
                Text("Add holdings to see how this account is allocated across asset classes.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            } else {
                ForEach(allocation) { slice in
                    HStack {
                        Text(slice.assetClass.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.82))
                        Spacer()
                        Text(currencyString(slice.marketValue))
                            .font(.system(size: 12, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                        Text(percentString(slice.percentage))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.45))
                            .frame(width: 48, alignment: .trailing)
                    }
                }
            }
        }
        .padding(20)
        .background(cardBackground)
    }

    private var holdingsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("HOLDINGS")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text("\(holdings.count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))
            }

            if holdings.isEmpty {
                Text("No holdings yet. Add your first position to track performance for this investment account.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            } else {
                ForEach(holdings) { holding in
                    Button {
                        editingHolding = holding
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.white.opacity(0.06))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Text(String(holding.symbol.prefix(1)))
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white.opacity(0.8))
                                )

                            VStack(alignment: .leading, spacing: 3) {
                                Text(holding.symbol)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("\(holding.name) • \(formattedShares(holding.shares)) shares")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.45))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 3) {
                                Text(currencyString(holding.marketValue))
                                    .font(.system(size: 14, weight: .semibold, design: .serif))
                                    .foregroundColor(.white)
                                Text(signedCurrencyString(holding.gainLoss))
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(holding.gainLoss >= 0 ? warmOlive : warmRose)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button("Edit") { editingHolding = holding }
                        Button("Delete", role: .destructive) {
                            data.deleteInvestmentHolding(id: holding.id)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.white.opacity(0.04))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }

    private func detailChip(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.4))
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .serif))
                .foregroundColor(.white)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(accent.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accent.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }

    private func signedCurrencyString(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : "-"
        return prefix + currencyString(abs(value))
    }

    private func percentString(_ value: Double) -> String {
        String(format: "%@%.1f%%", value >= 0 ? "+" : "-", abs(value) * 100)
    }

    private func formattedShares(_ shares: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: shares)) ?? String(format: "%.4f", shares)
    }
}

private struct InvestmentHoldingEditorView: View {
    @Environment(\.dismiss) private var dismiss

    private let data = TransactionData.shared
    private let account: Account
    private let holding: InvestmentHolding?
    private let warmAccent = Color(red: 1.0, green: 0.42, blue: 0.16)

    @State private var symbol: String
    @State private var name: String
    @State private var assetClass: InvestmentAssetClass
    @State private var sharesText: String
    @State private var averageCostText: String
    @State private var currentPriceText: String

    init(account: Account, holding: InvestmentHolding? = nil) {
        self.account = account
        self.holding = holding
        _symbol = State(initialValue: holding?.symbol ?? "")
        _name = State(initialValue: holding?.name ?? "")
        _assetClass = State(initialValue: holding?.assetClass ?? .stock)
        _sharesText = State(initialValue: holding.map { Self.decimalString($0.shares, places: 4) } ?? "")
        _averageCostText = State(initialValue: holding.map { Self.decimalString($0.averageCostPerShare, places: 2) } ?? "")
        _currentPriceText = State(initialValue: holding.map { Self.decimalString($0.currentPricePerShare, places: 2) } ?? "")
    }

    private var isValid: Bool {
        !symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        parsedNumber(from: sharesText) ?? 0 > 0 &&
        parsedNumber(from: averageCostText) ?? 0 >= 0 &&
        parsedNumber(from: currentPriceText) ?? 0 >= 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PennyWarmBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        investmentField(title: "Ticker", text: $symbol, placeholder: "VOO", autocapitalize: true)
                        investmentField(title: "Holding Name", text: $name, placeholder: "Vanguard S&P 500 ETF")

                        VStack(alignment: .leading, spacing: 8) {
                            Text("ASSET CLASS")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))

                            Picker("", selection: $assetClass) {
                                ForEach(InvestmentAssetClass.allCases) { assetClass in
                                    Text(assetClass.rawValue).tag(assetClass)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                                    )
                            )
                        }

                        investmentField(title: "Shares", text: $sharesText, placeholder: "0.0000", keyboardType: .decimalPad)
                        investmentField(title: "Average Cost / Share", text: $averageCostText, placeholder: "0.00", keyboardType: .decimalPad)
                        investmentField(title: "Current Price / Share", text: $currentPriceText, placeholder: "0.00", keyboardType: .decimalPad)
                    }
                    .padding(20)
                }
            }
            .navigationTitle(holding == nil ? "Add Holding" : "Edit Holding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveHolding() }
                        .foregroundColor(isValid ? warmAccent : .white.opacity(0.3))
                        .disabled(!isValid)
                }
            }
        }
    }

    private func investmentField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        autocapitalize: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalize ? .characters : .never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .onChange(of: text.wrappedValue) { _, newValue in
                    guard keyboardType == .decimalPad else { return }
                    let formatted = Self.formattedAmountInput(newValue, maxFractionDigits: title == "Shares" ? 4 : 2)
                    if formatted != newValue {
                        text.wrappedValue = formatted
                    }
                }
        }
    }

    private func saveHolding() {
        guard
            let shares = parsedNumber(from: sharesText), shares > 0,
            let averageCost = parsedNumber(from: averageCostText),
            let currentPrice = parsedNumber(from: currentPriceText)
        else { return }

        data.upsertInvestmentHolding(
            InvestmentHolding(
                id: holding?.id ?? UUID(),
                accountId: account.id,
                symbol: symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased(),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                assetClass: assetClass,
                shares: shares,
                averageCostPerShare: averageCost,
                currentPricePerShare: currentPrice,
                lastUpdated: Date()
            )
        )
        dismiss()
    }

    private func parsedNumber(from input: String) -> Double? {
        Double(input.replacingOccurrences(of: ",", with: ""))
    }

    private static func decimalString(_ value: Double, places: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = places
        formatter.minimumFractionDigits = min(2, places)
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private static func formattedAmountInput(_ input: String, maxFractionDigits: Int) -> String {
        let filtered = input.filter { "0123456789.,".contains($0) }
        let normalized = filtered.replacingOccurrences(of: ",", with: "")
        let parts = normalized.split(separator: ".", omittingEmptySubsequences: false)

        let integerDigits = String(parts.first ?? "")
        let hasDecimal = normalized.contains(".")
        let rawFraction = parts.count > 1 ? String(parts[1]) : ""
        let fractionDigits = String(rawFraction.prefix(maxFractionDigits))

        let integerNumber = Double(integerDigits.isEmpty ? "0" : integerDigits) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        let groupedInteger = formatter.string(from: NSNumber(value: integerNumber)) ?? integerDigits

        if hasDecimal {
            return groupedInteger + "." + fractionDigits
        }

        if integerDigits.isEmpty {
            return ""
        }

        return groupedInteger
    }
}

#Preview {
    BankView()
}
