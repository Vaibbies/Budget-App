import SwiftUI

struct BankView: View {
    private let data = TransactionData.shared

    @State private var showAddAccount = false
    @State private var editingAccount: Account?
    @State private var showBudgetEditor = false

    private var visibleAccounts: [Account] {
        data.visibleAccounts
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

                sectionHeader("Snapshot")
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
                .foregroundColor(Color(red: 0.38, green: 0.65, blue: 0.98))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                        .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
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
                balancePill(label: "Assets", value: currencyString(data.totalAssetsBalance), color: Color(red: 0.29, green: 0.87, blue: 0.50))
                balancePill(label: "Liabilities", value: currencyString(data.totalLiabilitiesBalance), color: Color(red: 1.0, green: 0.42, blue: 0.16))
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.13, green: 0.14, blue: 0.18),
                            Color(red: 0.07, green: 0.07, blue: 0.09)
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

                    Text(currencyString(data.manualMonthlyBudget > 0 ? data.manualMonthlyBudget : data.dailyBudget))
                        .font(.system(size: 30, weight: .light, design: .serif))
                        .foregroundColor(.white)
                }

                Spacer()

                Button {
                    showBudgetEditor = true
                } label: {
                    Text("Edit")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(MeTheme.accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(MeTheme.accent.opacity(0.10))
                                .overlay(Capsule().stroke(MeTheme.accent.opacity(0.20), lineWidth: 1))
                        )
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                metricChip(
                    title: "Spent Today",
                    value: currencyString(data.dailySpent),
                    accent: Color(red: 1.0, green: 0.42, blue: 0.16)
                )

                metricChip(
                    title: "Remaining",
                    value: currencyString(data.dailyRemaining),
                    accent: Color(red: 0.29, green: 0.87, blue: 0.50)
                )
            }

            HStack(spacing: 10) {
                metricChip(
                    title: "Daily Budget",
                    value: currencyString(data.dailyBudget),
                    accent: Color(red: 0.38, green: 0.65, blue: 0.98)
                )

                metricChip(
                    title: "Monthly Budget",
                    value: currencyString(data.totalMonthlyBudget),
                    accent: Color(red: 0.35, green: 0.98, blue: 0.85)
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
                    accent: Color(red: 0.38, green: 0.65, blue: 0.98)
                )

                metricCard(
                    title: "INVESTMENTS",
                    value: currencyString(data.investedBalance),
                    subtitle: "investment accounts",
                    accent: Color(red: 0.35, green: 0.98, blue: 0.85)
                )
            }

            HStack(spacing: 10) {
                metricCard(
                    title: "TOTAL DEBT",
                    value: currencyString(data.totalDebtBalance),
                    subtitle: "cards + loans",
                    accent: Color(red: 1.0, green: 0.42, blue: 0.16)
                )

                metricCard(
                    title: "SAFE TO SPEND",
                    value: currencyString(data.safeToSpendThisMonth),
                    subtitle: "budget and cash constrained",
                    accent: Color(red: 0.29, green: 0.87, blue: 0.50)
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
                Text(currencyString(account.balance))
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(account.balance >= 0 ? .white : Color(red: 1.0, green: 0.42, blue: 0.16))

                Text(account.type.rawValue.uppercased())
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.3))
            }

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
                            .foregroundColor(MeTheme.accent)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [MeTheme.accentLight, MeTheme.accent],
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
            snapshotRow(title: "Daily Budget", subtitle: "your manual budget cap for each day", value: currencyString(data.dailyBudget), valueColor: .white.opacity(0.8))
            divider
            snapshotRow(title: "Monthly Budget", subtitle: "your manual budget cap for the month", value: currencyString(data.totalMonthlyBudget), valueColor: .white.opacity(0.8))
            divider
            snapshotRow(title: "Monthly Net", subtitle: "income minus budgetable spend", value: currencyString(data.monthlyNet), valueColor: data.monthlyNet >= 0 ? MeTheme.success : MeTheme.accent)
            divider
            snapshotRow(title: "Upcoming Bills", subtitle: "next recurring charges in this cycle", value: currencyString(data.upcomingRecurringTotal), valueColor: .white.opacity(0.75))
            divider
            snapshotRow(title: "Goal Progress", subtitle: "saved across all active goals", value: currencyString(data.totalGoalProgress), valueColor: MeTheme.success)
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
                    .foregroundColor(Color(red: 0.38, green: 0.65, blue: 0.98))
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
        case .checking: return Color(red: 0.38, green: 0.65, blue: 0.98)
        case .savings: return Color(red: 0.29, green: 0.87, blue: 0.50)
        case .creditCard: return Color(red: 1.0, green: 0.42, blue: 0.16)
        case .investment: return Color(red: 0.35, green: 0.98, blue: 0.85)
        case .loan: return Color(red: 0.96, green: 0.45, blue: 0.71)
        case .cash: return Color(red: 0.98, green: 0.85, blue: 0.35)
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

    private var backgroundGradient: some View {
        ZStack {
            Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.09, green: 0.10, blue: 0.14),
                    Color(red: 0.05, green: 0.05, blue: 0.07),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 0.36, green: 0.72, blue: 1.0).opacity(0.25),
                    Color(red: 0.20, green: 0.45, blue: 0.92).opacity(0.08),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()
        }
    }
}

private struct AccountEditorView: View {
    @Environment(\.dismiss) private var dismiss

    private let data = TransactionData.shared
    private let account: Account?

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
                Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()

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

                        field(
                            title: type == .creditCard || type == .loan ? "Amount Owed" : "Balance",
                            text: $balanceText,
                            placeholder: "0.00",
                            keyboardType: .numbersAndPunctuation
                        )

                        Text(type == .creditCard || type == .loan
                            ? "Debt accounts are stored as negative balances automatically."
                            : "This balance will feed your Bank tab and spending capacity."
                        )
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
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
                        .foregroundColor(isValid ? MeTheme.accent : .white.opacity(0.3))
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
                .textInputAutocapitalization(.words)
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
}

private struct DailyBudgetEditorView: View {
    @Environment(\.dismiss) private var dismiss

    private let data = TransactionData.shared
    @State private var budgetText: String
    @State private var monthlyBudgetText: String

    init() {
        _budgetText = State(initialValue: Self.decimalString(TransactionData.shared.dailyBudget))
        _monthlyBudgetText = State(initialValue: Self.decimalString(TransactionData.shared.manualMonthlyBudget))
    }

    private var budgetValue: Double? {
        Self.parsedNumber(from: budgetText)
    }

    private var monthlyBudgetValue: Double? {
        Self.parsedNumber(from: monthlyBudgetText)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DAILY BUDGET")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.4))

                        TextField("0.00", text: $budgetText)
                            .keyboardType(.numbersAndPunctuation)
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
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("MONTHLY BUDGET")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.4))

                        TextField("0.00", text: $monthlyBudgetText)
                            .keyboardType(.numbersAndPunctuation)
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
                    }

                    Text("These values drive the daily remaining amount and the monthly budget cards on the home and bank screens.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .lineSpacing(3)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Daily Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white.opacity(0.7))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        data.dailyBudget = max(budgetValue ?? 0, 0)
                        data.manualMonthlyBudget = max(monthlyBudgetValue ?? 0, 0)
                        dismiss()
                    }
                    .foregroundColor(MeTheme.accent)
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
}

#Preview {
    BankView()
}
