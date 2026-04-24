import SwiftUI
import UIKit

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

    @Environment(\.dismiss) var dismiss
    private var data = TransactionData.shared
    private let scope: Scope
    @State private var showAddTransaction = false
    @State private var editingInfo: EditInfo? = nil

    struct EditInfo: Identifiable {
        let id = UUID()
        let transaction: SpendingTransaction
        let groupIndex: Int
        let groupTitle: String
        let txIndex: Int
    }

    init(scope: Scope = .all) {
        self.scope = scope
    }

    private var visibleGroups: [(groupIndex: Int, group: SpendingTransactionGroup)] {
        switch scope {
        case .all:
            return Array(data.groups.enumerated()).map { ($0.offset, $0.element) }
        case .today:
            return Array(data.groups.enumerated()).filter { _, group in
                data.isGroupInToday(group)
            }.map { ($0.offset, $0.element) }
        }
    }

    private var totalVisibleSpent: Double {
        switch scope {
        case .all:
            return visibleGroups.reduce(0) { running, item in
                running + item.group.transactions.reduce(0) { $0 + $1.amountValue }
            }
        case .today:
            return data.dailySpent
        }
    }

    private var headerTitle: String {
        switch scope {
        case .all: return "TRANSACTIONS"
        case .today: return "TODAY"
        }
    }

    private var spentSectionTitle: String {
        switch scope {
        case .all: return "SPENT THIS WEEK"
        case .today: return "SPENT TODAY"
        }
    }

    private var recentDayTotals: [(label: String, total: Double)] {
        if scope == .today {
            return [("TOD", totalVisibleSpent)]
        }

        let totals = data.groups.prefix(6).map { group in
            (label: String(group.title.prefix(3)).uppercased(),
             total: group.transactions.reduce(0) { $0 + $1.amountValue })
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
                                                groupIndex: groupIndex,
                                                groupTitle: group.title,
                                                txIndex: txIndex
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
                originalGroupIndex: info.groupIndex,
                originalGroupTitle: info.groupTitle,
                originalTxIndex: info.txIndex
            )
            .presentationCornerRadius(30)
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            data.syncRecurringTransactions()
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

            Text("$\(String(format: "%.2f", scope == .today ? totalVisibleSpent : data.totalSpent))")
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .tracking(-1)

            HStack(alignment: .bottom, spacing: 8) {
                let maxValue = max(recentDayTotals.map { $0.total }.max() ?? 1, 1)

                ForEach(Array(recentDayTotals.enumerated()), id: \.offset) { _, day in
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 22, height: 52)
                            .overlay(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(TransactionsTheme.accent)
                                    .frame(height: max(4, 52 * CGFloat(day.total / maxValue)))
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

    // MARK: - Delete
    private func deleteTransaction(groupIndex: Int, txIndex: Int, transactionId: UUID) {
        Haptics.medium()
        if !data.removeTransaction(id: transactionId) {
            var updatedTransactions = data.groups[groupIndex].transactions
            updatedTransactions.remove(at: txIndex)
            if updatedTransactions.isEmpty {
                data.groups.remove(at: groupIndex)
            } else {
                data.groups[groupIndex] = SpendingTransactionGroup(
                    id: data.groups[groupIndex].id,
                    title: data.groups[groupIndex].title,
                    transactions: updatedTransactions
                )
            }
        }
    }

    // MARK: - Row
    private func fullTransactionRow(_ transaction: SpendingTransaction) -> some View {
        let isSubscription = transaction.category == .subscriptions

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

                Text("\(transaction.time) • \(transaction.subtitle)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(TransactionsTheme.muted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.amount)
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundColor(transaction.isImpulse ? TransactionsTheme.accent : .white)
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
    }
}

// MARK: - Edit Transaction View
struct EditTransactionView: View {
    @Environment(\.dismiss) var dismiss
    let transaction: SpendingTransaction
    let originalGroupIndex: Int
    let originalGroupTitle: String
    let originalTxIndex: Int
    let originalGroupDate: Date

    private var data = TransactionData.shared

    @State private var amountString: String
    @State private var merchantName: String
    @State private var selectedCategory: SpendingCategory
    @State private var selectedDate: Date
    @State private var isImpulse: Bool
    @State private var isListening = false

    init(transaction: SpendingTransaction, originalGroupIndex: Int, originalGroupTitle: String, originalTxIndex: Int) {
        self.transaction = transaction
        self.originalGroupIndex = originalGroupIndex
        self.originalGroupTitle = originalGroupTitle
        self.originalTxIndex = originalTxIndex
        self.originalGroupDate = Self.resolveDate(fromGroupTitle: originalGroupTitle) ?? Date()

        _merchantName = State(initialValue: transaction.title)
        _amountString = State(initialValue: String(Int(transaction.amountValue * 100)))
        _selectedCategory = State(initialValue: transaction.category)
        _isImpulse = State(initialValue: transaction.isImpulse)

        _selectedDate = State(initialValue: self.originalGroupDate)
    }

    private var displayAmount: String {
        let value = (Double(amountString) ?? 0) / 100
        return String(format: "%.2f", value)
    }

    private var amountDouble: Double {
        (Double(amountString) ?? 0) / 100
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

                    Text("EDIT EXPENSE")
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
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                    }

                    NoMoveTextField(placeholder: "MERCHANT NAME", text: $merchantName)
                        .frame(height: 30)
                }
                .padding(.bottom, 20)

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
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                KeypadView { key in handleKey(key) }
                    .padding(.horizontal, 24)

                Spacer()

                Button(action: saveExpense) {
                    Text("Save Changes")
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

        // Capture original group title BEFORE we mutate groups,
        // so we can detect "same group" and preserve position.
        let newDayLabel: String
        if Calendar.current.isDate(selectedDate, inSameDayAs: originalGroupDate) {
            newDayLabel = originalGroupTitle
        } else if Calendar.current.isDateInToday(selectedDate) {
            newDayLabel = "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            newDayLabel = "Yesterday"
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEEE, MMM d"
            newDayLabel = fmt.string(from: selectedDate)
        }

        let updated = SpendingTransaction(
            id: transaction.id,
            icon: selectedCategory.icon,
            title: merchantName.isEmpty ? selectedCategory.rawValue : merchantName,
            subtitle: selectedCategory.rawValue,
            time: transaction.time,
            amount: "-$\(String(format: "%.2f", amountDouble))",
            isImpulse: isImpulse,
            iconColor: selectedCategory.color,
            bgColor: selectedCategory.color.opacity(0.1),
            borderColor: selectedCategory.color.opacity(0.2),
            category: selectedCategory,
            accountId: transaction.accountId,
            kind: transaction.kind,
            merchantRaw: merchantName.isEmpty ? transaction.merchantRaw : merchantName,
            merchantNormalized: merchantName.isEmpty ? transaction.merchantNormalized : data.normalizeMerchant(merchantName),
            notes: transaction.notes,
            tags: transaction.tags,
            isExcludedFromBudget: transaction.isExcludedFromBudget,
            isRecurringCandidate: transaction.isRecurringCandidate
        )

        // Remove from original group
        var originalTxns = data.groups[originalGroupIndex].transactions
        originalTxns.remove(at: originalTxIndex)
        if originalTxns.isEmpty {
            data.groups.remove(at: originalGroupIndex)
        } else {
            data.groups[originalGroupIndex] = SpendingTransactionGroup(
                title: data.groups[originalGroupIndex].title,
                transactions: originalTxns
            )
        }

        // Insert into correct group (FIXED: preserve position if same group/date)
        if let existingIndex = data.groups.firstIndex(where: { $0.title == newDayLabel }) {
            var txns = data.groups[existingIndex].transactions

            // If we're staying in the same group (date unchanged), put it back where it was.
            // Otherwise (moving to a different day), insert at top.
            let insertAt: Int
            if newDayLabel == originalGroupTitle {
                insertAt = min(originalTxIndex, txns.count)
            } else {
                insertAt = 0
            }

            txns.insert(updated, at: insertAt)
            data.groups[existingIndex] = SpendingTransactionGroup(
                title: data.groups[existingIndex].title,
                transactions: txns
            )
        } else {
            let labelFormatter = DateFormatter()
            labelFormatter.dateFormat = "EEEE, MMM d"
            let insertIndex = data.groups.firstIndex(where: { group in
                guard group.title != "Today" && group.title != "Yesterday" else { return false }
                if let groupDate = labelFormatter.date(from: group.title) {
                    return groupDate < selectedDate
                }
                return false
            }) ?? data.groups.endIndex

            data.groups.insert(
                SpendingTransactionGroup(title: newDayLabel, transactions: [updated]),
                at: insertIndex
            )
        }

        dismiss()
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
