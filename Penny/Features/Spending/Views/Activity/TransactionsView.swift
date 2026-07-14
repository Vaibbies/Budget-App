import SwiftUI
import UIKit
import UniformTypeIdentifiers

// MARK: - Theme
private enum TransactionsTheme {
    static let canvas = Color(red: 0.039, green: 0.043, blue: 0.051)
    static let surface = Color(red: 0.071, green: 0.071, blue: 0.086).opacity(0.7)
    static let ink = Color(red: 0.957, green: 0.961, blue: 0.969)
    static let muted = Color(red: 0.643, green: 0.655, blue: 0.682)
    static let line = Color.white.opacity(0.06)
    static let accent = Color(red: 1.0, green: 0.416, blue: 0.165)
}

// MARK: - TransactionsView
struct TransactionsView: View {
    enum Scope: Equatable {
        case all
        case today
    }

    enum TransactionFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case spending = "Spending"
        case income = "Income"
        case transfer = "Transfers"
        case refund = "Refunds"
        case recurring = "Recurring"

        var id: String { rawValue }
    }

    @Environment(\.dismiss) var dismiss
    @Environment(SpendingStore.self) private var spending
    private let scope: Scope
    private let initialAccountId: UUID?
    private let initialCategory: SpendingCategory?
    private let initialFilter: TransactionFilter
    @State private var showAddTransaction = false
    @State private var showImporter = false
    @State private var editingInfo: EditInfo? = nil
    @State private var selectedTransaction: SpendingTransaction? = nil
    @State private var selectedAccountId: UUID? = nil
    @State private var selectedFilter: TransactionFilter = .all
    @State private var selectedCategory: SpendingCategory? = nil
    @State private var searchText = ""
    @State private var importSummaryMessage: String?

    struct EditInfo: Identifiable {
        let id = UUID()
        let transaction: SpendingTransaction
        let groupTitle: String
    }

    init(
        scope: Scope = .all,
        initialAccountId: UUID? = nil,
        initialCategory: SpendingCategory? = nil,
        initialFilter: TransactionFilter = .all
    ) {
        self.scope = scope
        self.initialAccountId = initialAccountId
        self.initialCategory = initialCategory
        self.initialFilter = initialFilter
    }

    private var visibleGroups: [(groupIndex: Int, group: SpendingTransactionGroup)] {
        let scopedGroups: [(offset: Int, element: SpendingTransactionGroup)]
        switch scope {
        case .all:
            scopedGroups = Array(spending.groups.enumerated())
        case .today:
            scopedGroups = Array(spending.groups.enumerated()).filter { _, group in
                spending.isGroupInToday(group)
            }
        }

        return scopedGroups.compactMap { index, group in
            let filteredTransactions = group.transactions.filter { transaction in
                matchesFilters(transaction)
            }

            guard !filteredTransactions.isEmpty else { return nil }

            return (
                groupIndex: index,
                group: SpendingTransactionGroup(
                    id: group.id,
                    title: group.title,
                    transactions: filteredTransactions
                )
            )
        }
    }

    private var visibleTransactions: [SpendingTransaction] {
        visibleGroups.flatMap(\.group.transactions)
    }

    private var summaryAmount: Double {
        visibleTransactions.reduce(0) { running, transaction in
            running + transaction.kind.summaryAmount(transaction.amountValue)
        }
    }

    private var summaryAmountDisplay: String {
        let sign = summaryAmount < 0 ? "-" : ""
        return "\(sign)$\(String(format: "%.2f", abs(summaryAmount)))"
    }

    private var headerTitle: String {
        switch scope {
        case .all: return "TRANSACTIONS"
        case .today: return "TODAY"
        }
    }

    private var spentSectionTitle: String {
        switch selectedFilter {
        case .all:
            return scope == .today ? "TODAY'S ACTIVITY" : "FILTERED ACTIVITY"
        case .spending, .recurring:
            return scope == .today ? "SPENT TODAY" : "SPENDING"
        case .income:
            return scope == .today ? "INCOME TODAY" : "INCOME"
        case .transfer:
            return scope == .today ? "TRANSFERS TODAY" : "TRANSFERS"
        case .refund:
            return scope == .today ? "REFUNDS TODAY" : "REFUNDS"
        }
    }

    private var availableCategories: [SpendingCategory] {
        let categories = Set(spending.allTransactions.compactMap { transaction in
            let matchesAccount = selectedAccountId.map { transaction.accountId == $0 } ?? true
            let matchesFilter = matchesTypeFilter(transaction)
            let matchesSearch = matchesSearch(transaction)
            return (matchesAccount && matchesFilter && matchesSearch) ? transaction.category : nil
        })
        return SpendingCategory.allCases.filter { categories.contains($0) }
    }

    private var recentDayTotals: [(label: String, total: Double)] {
        if scope == .today {
            return [("TOD", summaryAmount)]
        }

        let totals = visibleGroups.prefix(6).map { entry in
            (label: String(entry.group.title.prefix(3)).uppercased(),
             total: entry.group.transactions.reduce(0) { $0 + $1.amountValue })
        }.reversed()

        let values = Array(totals)
        return values.isEmpty ? [("MON", 0), ("TUE", 0), ("WED", 0), ("THU", 0), ("FRI", 0), ("SAT", 0)] : values
    }

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                headerSection
                spentSection
                searchBar
                    .padding(.bottom, 10)
                transactionFilterBar
                    .padding(.bottom, 8)
                if !spending.visibleAccounts.isEmpty {
                    accountFilterBar
                        .padding(.bottom, 8)
                }
                if !availableCategories.isEmpty {
                    categoryFilterBar
                        .padding(.bottom, 8)
                }

                List {
                    ForEach(visibleGroups, id: \.group.id) { entry in
                        let groupIndex = entry.groupIndex
                        let group = entry.group
                        Section {
                            ForEach(Array(group.transactions.enumerated()), id: \.element.id) { txIndex, transaction in
                                fullTransactionRow(transaction)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteTransaction(groupIndex: groupIndex, txIndex: txIndex, transactionId: transaction.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            editingInfo = EditInfo(
                                                transaction: transaction,
                                                groupTitle: group.title
                                            )
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(Color(red: 0.38, green: 0.65, blue: 0.98))
                                    }
                            }
                        } header: {
                            Text(group.title.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.3))
                                .tracking(2)
                                .padding(.horizontal, 24)
                                .padding(.top, 10)
                                .textCase(nil)
                        }
                    }

                    Color.clear
                        .frame(height: 120)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
        }
        .sheet(item: $editingInfo) { info in
            EditTransactionView(
                transaction: info.transaction,
                originalGroupTitle: info.groupTitle
            )
            .presentationCornerRadius(30)
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transactionId: transaction.id)
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .onAppear {
            if selectedAccountId == nil {
                selectedAccountId = initialAccountId
            }
            if selectedCategory == nil {
                selectedCategory = initialCategory
            }
            if selectedFilter == .all {
                selectedFilter = initialFilter
            }
            spending.syncRecurringTransactions()
        }
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            TransactionsTheme.canvas.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.7),
                    Color(red: 1.0, green: 0.376, blue: 0.125).opacity(0.1),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button { dismiss() } label: {
                Circle()
                    .fill(TransactionsTheme.surface)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(TransactionsTheme.line, lineWidth: 1))
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(TransactionsTheme.ink)
                    )
            }

            Spacer()

            Text(headerTitle)
                .font(.system(size: 12, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))

            Spacer()

            Button {
                showAddTransaction = true
                Haptics.medium()
            } label: {
                Circle()
                    .fill(TransactionsTheme.accent)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: TransactionsTheme.accent.opacity(0.5), radius: 8)
            }

            Button {
                showImporter = true
                Haptics.light()
            } label: {
                Circle()
                    .fill(TransactionsTheme.surface)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(TransactionsTheme.line, lineWidth: 1))
                    .overlay(
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(TransactionsTheme.ink)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Spent This Week
    private var spentSection: some View {
        VStack(spacing: 10) {
            Text(spentSectionTitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(TransactionsTheme.muted)
                .tracking(2)

            Text(summaryAmountDisplay)
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .tracking(-1)

            if let importSummaryMessage {
                Text(importSummaryMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }

            HStack(alignment: .bottom, spacing: 8) {
                let maxValue = max(recentDayTotals.map { abs($0.total) }.max() ?? 1, 1)

                ForEach(Array(recentDayTotals.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 22, height: 52)
                            .overlay(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(TransactionsTheme.accent)
                                    .frame(height: max(4, 52 * CGFloat(abs(day.total) / maxValue)))
                            }

                        Text(day.label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                    }
                }
            }
            .padding(.top, 2)
        }
        .padding(.top, 16)
        .padding(.bottom, 16)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.45))

            TextField("Search merchants, categories, or accounts", text: $searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(TransactionsTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(TransactionsTheme.line, lineWidth: 1))
        )
        .padding(.horizontal, 24)
    }

    private var transactionFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionFilter.allCases) { filter in
                    accountFilterChip(title: filter.rawValue, isSelected: selectedFilter == filter) {
                        selectedFilter = filter
                        selectedCategory = nil
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var accountFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                accountFilterChip(title: "All", isSelected: selectedAccountId == nil) {
                    selectedAccountId = nil
                }

                ForEach(spending.visibleAccounts, id: \.id) { account in
                    accountFilterChip(title: account.name, isSelected: selectedAccountId == account.id) {
                        selectedAccountId = account.id
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                accountFilterChip(title: "All Categories", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(availableCategories, id: \.self) { category in
                    accountFilterChip(title: category.rawValue, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    private func accountFilterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.light()
            action()
        } label: {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(isSelected ? .black : .white.opacity(0.72))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.08))
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Delete
    private func deleteTransaction(groupIndex: Int, txIndex: Int, transactionId: UUID) {
        Haptics.medium()
        _ = spending.removeTransaction(id: transactionId)
    }

    private func matchesFilters(_ transaction: SpendingTransaction) -> Bool {
        let matchesAccount = selectedAccountId.map { transaction.accountId == $0 } ?? true
        let matchesCategory = selectedCategory.map { transaction.category == $0 } ?? true
        return matchesAccount && matchesCategory && matchesTypeFilter(transaction) && matchesSearch(transaction)
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        guard case let .success(urls) = result, let url = urls.first else { return }

        do {
            _ = url.startAccessingSecurityScopedResource()
            defer { url.stopAccessingSecurityScopedResource() }

            let contents = try String(contentsOf: url, encoding: .utf8)
            let summary = spending.importCSVTransactions(from: contents, defaultAccountId: selectedAccountId)
            importSummaryMessage = "Imported \(summary.importedCount) • Skipped duplicates \(summary.duplicateCount)"
        } catch {
            importSummaryMessage = "Import failed"
        }
    }

    private func matchesTypeFilter(_ transaction: SpendingTransaction) -> Bool {
        switch selectedFilter {
        case .all:
            return true
        case .spending:
            return transaction.kind == .spending
        case .income:
            return transaction.kind == .income
        case .transfer:
            return transaction.kind == .transfer
        case .refund:
            return transaction.kind == .refund
        case .recurring:
            return transaction.category == .subscriptions || transaction.isRecurringCandidate
        }
    }

    private func matchesSearch(_ transaction: SpendingTransaction) -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return true }

        let haystacks = [
            transaction.title,
            transaction.subtitle,
            transaction.merchantNormalized ?? "",
            transaction.merchantRaw ?? "",
            transaction.category.rawValue,
            spending.accountName(for: transaction.accountId) ?? "",
            transaction.kind.rawValue
        ]

        return haystacks.contains { $0.lowercased().contains(query) }
    }

    // MARK: - Row
    private func fullTransactionRow(_ transaction: SpendingTransaction) -> some View {
        let isSubscription = transaction.category == .subscriptions
        let subtitleParts: [String] = [transaction.time, transaction.subtitle, spending.accountName(for: transaction.accountId)]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }

        return HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                .frame(width: 48, height: 48)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(transaction.borderColor, lineWidth: 1))
                .overlay(
                    BrandLogoView(
                        name: transaction.title,
                        size: 48,
                        fallbackIcon: transaction.icon,
                        fallbackColor: transaction.iconColor
                    )
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text(subtitleParts.joined(separator: " • "))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(TransactionsTheme.muted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.amount)
    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundColor(transaction.isImpulse ? TransactionsTheme.accent : transaction.kind.signedAmountColor)
                    .tracking(-0.5)

                if transaction.isImpulse {
                    Text("impulse")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(TransactionsTheme.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(TransactionsTheme.accent.opacity(0.12)))
                }
            }
        }
        .padding(16)
        .background(TransactionsTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(TransactionsTheme.line, lineWidth: 1))
        .overlay(alignment: .leading) {
            if isSubscription {
                RoundedRectangle(cornerRadius: 2)
                    .fill(TransactionsTheme.accent.opacity(0.85))
                    .frame(width: 3)
                    .padding(.vertical, 10)
                    .padding(.leading, 8)
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
        .onTapGesture {
            selectedTransaction = transaction
        }
    }
}

// MARK: - Edit Transaction View
struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(SpendingStore.self) private var spending
    let transaction: SpendingTransaction
    let originalGroupTitle: String
    let originalGroupDate: Date

    @State private var amountString: String
    @State private var merchantName: String
    @State private var selectedKind: TransactionKind
    @State private var selectedCategory: SpendingCategory
    @State private var selectedDate: Date
    @State private var selectedAccountId: UUID?
    @State private var isImpulse: Bool
    @State private var isSplitTransaction: Bool
    @State private var splitAllocations: [SplitTransactionAllocation]
    @State private var isListening = false
    @State private var applyRuleToFuture = false
    @State private var merchantRuleName = ""
    @State private var merchantRulePattern = ""
    @State private var hasLoadedSplitAllocations = false

    init(transaction: SpendingTransaction, originalGroupTitle: String) {
        self.transaction = transaction
        self.originalGroupTitle = originalGroupTitle
        self.originalGroupDate = Self.resolveDate(fromGroupTitle: originalGroupTitle) ?? Date()

        _merchantName = State(initialValue: transaction.merchantRaw ?? transaction.title)
        _amountString = State(initialValue: String(Int(transaction.amountValue * 100)))
        _selectedKind = State(initialValue: transaction.kind)
        _selectedCategory = State(initialValue: transaction.category)
        _selectedAccountId = State(initialValue: transaction.accountId)
        _isImpulse = State(initialValue: transaction.isImpulse)
        _isSplitTransaction = State(initialValue: transaction.isSplitChild || transaction.splitGroupId != nil)
        _splitAllocations = State(initialValue: [
            SplitTransactionAllocation(
                category: transaction.category,
                amount: transaction.amountValue,
                label: transaction.splitLabel ?? ""
            )
        ])
        _merchantRuleName = State(initialValue: transaction.merchantRaw ?? transaction.title)
        _merchantRulePattern = State(initialValue: transaction.merchantNormalized ?? transaction.merchantRaw ?? transaction.title)

        _selectedDate = State(initialValue: self.originalGroupDate)
    }

    private var displayAmount: String {
        let value = (Double(amountString) ?? 0) / 100
        return String(format: "%.2f", value)
    }

    private var amountDouble: Double {
        (Double(amountString) ?? 0) / 100
    }

    private var splitTotal: Double {
        splitAllocations.reduce(0) { $0 + $1.amount }
    }

    private var splitDifference: Double {
        amountDouble - splitTotal
    }

    private var headerTitle: String {
        "EDIT \(selectedKind.editorTitle.uppercased())"
    }

    var body: some View {
        ZStack {
            ZStack {
                Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.6),
                        Color(red: 1.0, green: 0.376, blue: 0.125).opacity(0.1),
                        Color.clear
                    ],
                    center: .init(x: 0.5, y: 0.0),
                    startRadius: 0,
                    endRadius: 500
                )
                .ignoresSafeArea()
            }

            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }

                    Spacer()

                    Text(headerTitle)
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Button { isListening.toggle(); Haptics.medium() } label: {
                        Circle()
                            .fill(isListening
                                  ? Color(red: 1.0, green: 0.42, blue: 0.16)
                                  : Color.white.opacity(0.07))
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                            .overlay(
                                Image(systemName: isListening ? "waveform" : "mic.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                VStack(spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.white.opacity(0.5))

                        Text(displayAmount)
                            .font(.system(size: 64, weight: .light, design: .serif))
                            .foregroundColor(selectedKind.signedAmountColor)
                            .minimumScaleFactor(0.5)
                    }

                    NoMoveTextField(placeholder: "MERCHANT NAME", text: $merchantName)
                        .frame(height: 30)
                }
                .padding(.bottom, 20)

                kindSelector
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SpendingCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                                Haptics.light()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)

                HStack(spacing: 12) {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(Color(red: 1.0, green: 0.42, blue: 0.16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )

                    Spacer()

                    if selectedKind.usesImpulseFlag {
                        HStack(spacing: 8) {
                            Text("Impulse")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))

                            Toggle("", isOn: $isImpulse)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 1.0, green: 0.42, blue: 0.16)))
                                .scaleEffect(0.85)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                if !spending.visibleAccounts.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ACCOUNT")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.white.opacity(0.4))

                        Picker("Account", selection: $selectedAccountId) {
                            ForEach(spending.visibleAccounts, id: \.id) { account in
                                Text(account.name).tag(Optional(account.id))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }

                merchantRuleSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                splitSection
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)

                KeypadView { key in handleKey(key) }
                    .padding(.horizontal, 24)

                Spacer()

                Button(action: saveExpense) {
                    Text(selectedKind.saveTitle)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    amountDouble > 0
                                    ? LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.53, blue: 0.25),
                                            Color(red: 1.0, green: 0.35, blue: 0.10)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: amountDouble > 0 ? Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.4) : .clear,
                                    radius: 12,
                                    y: 4
                                )
                        )
                }
                .disabled(amountDouble == 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            loadSplitAllocationsIfNeeded()
        }
    }

    private func handleKey(_ key: String) {
        Haptics.light()
        switch key {
        case "delete":
            if amountString.count > 1 { amountString.removeLast() } else { amountString = "0" }
        case ".":
            break
        default:
            if amountString == "0" { amountString = key }
            else if amountString.count < 7 { amountString += key }
        }
    }

    private func saveExpense() {
        Haptics.medium()

        let rawTitle = merchantName.isEmpty ? selectedCategory.rawValue : merchantName
        let updated = spending.normalizeAndApplyRules(to: SpendingTransaction(
            id: transaction.id,
            icon: selectedCategory.icon,
            title: rawTitle,
            subtitle: selectedCategory.rawValue,
            time: transaction.time,
            amount: selectedKind.signedAmountString(for: amountDouble),
            isImpulse: selectedKind.usesImpulseFlag ? isImpulse : false,
            iconColor: selectedCategory.color,
            bgColor: selectedCategory.color.opacity(0.1),
            borderColor: selectedCategory.color.opacity(0.2),
            category: selectedCategory,
            accountId: selectedAccountId ?? spending.defaultSpendingAccount?.id,
            kind: selectedKind,
            merchantRaw: rawTitle,
            merchantNormalized: spending.normalizeMerchant(rawTitle),
            notes: transaction.notes,
            tags: transaction.tags,
            attachments: transaction.attachments,
            isExcludedFromBudget: transaction.isExcludedFromBudget,
            isRecurringCandidate: transaction.isRecurringCandidate
        ))

        if applyRuleToFuture {
            spending.upsertMerchantRule(
                matchPattern: merchantRulePattern.isEmpty ? rawTitle : merchantRulePattern,
                categoryOverride: selectedCategory,
                merchantDisplayName: merchantRuleName.isEmpty ? rawTitle : merchantRuleName,
                recurringHint: selectedKind == .spending && selectedCategory == .subscriptions
            )
        }

        if isSplitTransaction {
            let validAllocations = normalizedSplitAllocations()
            guard !validAllocations.isEmpty else { return }
            spending.replaceTransactionWithSplit(
                original: transaction,
                originalGroupTitle: originalGroupTitle,
                originalGroupDate: originalGroupDate,
                newDate: selectedDate,
                merchantName: rawTitle,
                kind: selectedKind,
                accountId: selectedAccountId ?? spending.defaultSpendingAccount?.id,
                isImpulse: isImpulse,
                allocations: validAllocations,
                notes: transaction.notes
            )
        } else {
            spending.updateTransaction(
                updated,
                originalTransactionId: transaction.id,
                originalGroupTitle: originalGroupTitle,
                originalGroupDate: originalGroupDate,
                newDate: selectedDate
            )
        }

        dismiss()
    }

    private var kindSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TransactionKind.allCases, id: \.self) { kind in
                    Button {
                        selectedKind = kind
                        if !kind.usesImpulseFlag {
                            isImpulse = false
                        }
                        Haptics.light()
                    } label: {
                        Text(kind.editorTitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedKind == kind ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(selectedKind == kind ? kind.signedAmountColor.opacity(0.95) : Color.white.opacity(0.06))
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedKind == kind ? kind.signedAmountColor.opacity(0.25) : Color.white.opacity(0.06), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var merchantRuleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $applyRuleToFuture) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Apply to future transactions")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Rename this merchant and keep this category for matching transactions.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(red: 1.0, green: 0.42, blue: 0.16)))

            if applyRuleToFuture {
                VStack(spacing: 10) {
                    ruleField(title: "Merchant Name", text: $merchantRuleName, placeholder: merchantName.isEmpty ? selectedCategory.rawValue : merchantName)
                    ruleField(title: "Match Text", text: $merchantRulePattern, placeholder: merchantName.isEmpty ? selectedCategory.rawValue : merchantName)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }

    private var splitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $isSplitTransaction) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Split transaction")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    Text("Break this transaction into category parts.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(red: 1.0, green: 0.42, blue: 0.16)))

            if isSplitTransaction {
                VStack(spacing: 10) {
                    ForEach($splitAllocations) { $allocation in
                        SplitAllocationEditor(allocation: $allocation)
                    }

                    HStack {
                        Button {
                            splitAllocations.append(
                                SplitTransactionAllocation(category: selectedCategory, amount: 0, label: "")
                            )
                        } label: {
                            Label("Add Split", systemImage: "plus")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.36))
                        }

                        Spacer()

                        Text("Left: $\(String(format: "%.2f", max(splitDifference, 0)))")
                            .font(.system(size: 12, weight: .medium, design: .serif))
                            .foregroundColor(abs(splitDifference) < 0.01 ? Color(red: 0.29, green: 0.87, blue: 0.50) : .white.opacity(0.55))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }

    private func normalizedSplitAllocations() -> [SplitTransactionAllocation] {
        let nonZero = splitAllocations.filter { $0.amount > 0 }
        guard !nonZero.isEmpty else { return [] }

        var result = nonZero
        let delta = amountDouble - result.reduce(0) { $0 + $1.amount }
        if abs(delta) >= 0.01, let lastIndex = result.indices.last {
            result[lastIndex].amount += delta
        }
        return result.filter { $0.amount > 0 }
    }

    private func loadSplitAllocationsIfNeeded() {
        guard !hasLoadedSplitAllocations else { return }
        hasLoadedSplitAllocations = true

        guard let splitGroupId = transaction.splitGroupId else { return }
        let existingSplitTransactions = spending.splitTransactions(for: splitGroupId)
        guard !existingSplitTransactions.isEmpty else { return }

        splitAllocations = existingSplitTransactions.map {
            SplitTransactionAllocation(
                category: $0.category,
                amount: $0.amountValue,
                label: $0.splitLabel ?? ""
            )
        }
        isSplitTransaction = existingSplitTransactions.count > 1 || transaction.isSplitChild
    }

    private func ruleField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.4))

            TextField(placeholder, text: text)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 1))
                )
        }
    }

    private static func resolveDate(fromGroupTitle title: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()

        if title == "Today" { return now }
        if title == "Yesterday" {
            return calendar.date(byAdding: .day, value: -1, to: now)
        }

        let absoluteFormatter = DateFormatter()
        absoluteFormatter.locale = Locale(identifier: "en_US_POSIX")
        absoluteFormatter.dateFormat = "EEEE, MMM d"
        if let parsed = absoluteFormatter.date(from: title) {
            // Formatter without year defaults to 2000. Rebuild with a sensible year.
            let parsedMonth = calendar.component(.month, from: parsed)
            let parsedDay = calendar.component(.day, from: parsed)
            let currentYear = calendar.component(.year, from: now)

            var components = DateComponents()
            components.year = currentYear
            components.month = parsedMonth
            components.day = parsedDay

            if let candidate = calendar.date(from: components) {
                // If this lands in the future, treat it as previous year.
                if candidate > now, let previousYear = calendar.date(byAdding: .year, value: -1, to: candidate) {
                    return previousYear
                }
                return candidate
            }
        }

        let weekdayMap: [String: Int] = [
            "Sunday": 1,
            "Monday": 2,
            "Tuesday": 3,
            "Wednesday": 4,
            "Thursday": 5,
            "Friday": 6,
            "Saturday": 7
        ]

        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let isLastPrefix = normalized.hasPrefix("Last ")
        let weekdayName = isLastPrefix
            ? String(normalized.dropFirst("Last ".count))
            : normalized

        guard let targetWeekday = weekdayMap[weekdayName] else { return nil }
        let todayWeekday = calendar.component(.weekday, from: now)

        var daysBack = (todayWeekday - targetWeekday + 7) % 7
        if isLastPrefix || daysBack == 0 {
            daysBack += 7
        }

        return calendar.date(byAdding: .day, value: -daysBack, to: now)
    }
}

#Preview {
    TransactionsView()
        .preferredColorScheme(.dark)
}
