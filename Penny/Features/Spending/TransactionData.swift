import SwiftUI

// MARK: - Category Enum
enum SpendingCategory: String, CaseIterable, Codable {
    case dining = "Dining"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case groceries = "Groceries"
    case utilities = "Utilities"
    case fitness = "Fitness"
    case subscriptions = "Subscriptions"
    case lifestyle = "Lifestyle"
    case other = "Other"

    var color: Color {
        switch self {
        case .dining:        return Color(red: 0.29, green: 0.87, blue: 0.50)
        case .transport:     return Color(red: 0.38, green: 0.65, blue: 0.98)
        case .shopping:      return Color(red: 0.96, green: 0.45, blue: 0.71)
        case .entertainment: return Color(red: 0.68, green: 0.45, blue: 0.98)
        case .groceries:     return Color(red: 0.29, green: 0.87, blue: 0.50)
        case .utilities:     return Color(red: 0.98, green: 0.85, blue: 0.35)
        case .fitness:       return Color(red: 1.0, green: 0.42, blue: 0.16)
        case .subscriptions: return Color(red: 0.35, green: 0.98, blue: 0.85)
        case .lifestyle:     return Color(red: 1.0, green: 0.42, blue: 0.16)
        case .other:         return Color.gray
        }
    }

    var icon: String {
        switch self {
        case .dining:        return "fork.knife"
        case .transport:     return "car.fill"
        case .shopping:      return "bag.fill"
        case .entertainment: return "gamecontroller.fill"
        case .groceries:     return "cart.fill"
        case .utilities:     return "bolt.fill"
        case .fitness:       return "dumbbell.fill"
        case .subscriptions: return "music.note"
        case .lifestyle:     return "cup.and.saucer.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }
}

// MARK: - Transaction Model
struct SpendingTransaction: Identifiable, Codable {
    let id: UUID
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let amount: String
    let isImpulse: Bool
    let iconColorHex: String
    let bgColorHex: String
    let borderColorHex: String
    let category: SpendingCategory

    init(
        id: UUID = UUID(),
        icon: String, title: String, subtitle: String,
        time: String, amount: String, isImpulse: Bool,
        iconColor: Color, bgColor: Color, borderColor: Color,
        category: SpendingCategory
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.time = time
        self.amount = amount
        self.isImpulse = isImpulse
        self.iconColorHex = iconColor.toHex()
        self.bgColorHex = bgColor.toHex()
        self.borderColorHex = borderColor.toHex()
        self.category = category
    }

    var iconColor: Color { Color(hex: iconColorHex) ?? .orange }
    var bgColor: Color { Color(hex: bgColorHex) ?? .clear }
    var borderColor: Color { Color(hex: borderColorHex) ?? .clear }

    var amountValue: Double {
        let cleaned = amount
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "-", with: "")
        return Double(cleaned) ?? 0
    }
}

// MARK: - Transaction Group
struct SpendingTransactionGroup: Identifiable, Codable {
    let id: UUID
    var title: String
    var transactions: [SpendingTransaction]

    init(id: UUID = UUID(), title: String, transactions: [SpendingTransaction]) {
        self.id = id
        self.title = title
        self.transactions = transactions
    }
}

// MARK: - Recurring Subscription Model
struct RecurringSubscription: Identifiable, Codable {
    let id: UUID
    let name: String
    let plan: String?
    let price: Double
    let iconName: String
    let iconColorHex: String
    let bgColorHex: String
    let nextBilling: String
    let frequencyDays: Int?
    let frequencyKey: String?
    let nextBillingEpoch: TimeInterval?

    init(
        id: UUID = UUID(),
        name: String,
        plan: String?,
        price: Double,
        iconName: String,
        iconColor: Color,
        bgColor: Color,
        nextBilling: String,
        frequencyDays: Int? = nil,
        frequencyKey: String? = nil,
        nextBillingEpoch: TimeInterval? = nil
    ) {
        self.id = id
        self.name = name
        self.plan = plan
        self.price = price
        self.iconName = iconName
        self.iconColorHex = iconColor.toHex()
        self.bgColorHex = bgColor.toHex()
        self.nextBilling = nextBilling
        self.frequencyDays = frequencyDays
        self.frequencyKey = frequencyKey
        self.nextBillingEpoch = nextBillingEpoch
    }

    var iconColor: Color { Color(hex: iconColorHex) ?? .white }
    var bgColor: Color { Color(hex: bgColorHex) ?? .black }
}

// MARK: - Color Hex Helpers
extension Color {
    init?(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        guard h.count == 8 else { return nil }
        let scanner = Scanner(string: h)
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)
        let r = Double((value & 0xFF000000) >> 24) / 255
        let g = Double((value & 0x00FF0000) >> 16) / 255
        let b = Double((value & 0x0000FF00) >> 8) / 255
        let a = Double(value & 0x000000FF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func toHex() -> String {
        let resolved = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        resolved.getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = Int(r * 255), gi = Int(g * 255), bi = Int(b * 255), ai = Int(a * 255)
        return String(format: "%02X%02X%02X%02X", ri, gi, bi, ai)
    }
}

// MARK: - Shared Data
@Observable
class TransactionData {
    static let shared = TransactionData()

    private let groupsKey = "penny_transaction_groups"
    private let budgetKey = "penny_daily_budget"
    private let subscriptionsKey = "penny_recurring_subscriptions"
    private var isNormalizingGroups = false
    private var isSyncingRecurring = false

    var groups: [SpendingTransactionGroup] {
        didSet {
            if isNormalizingGroups {
                save()
                return
            }

            isNormalizingGroups = true
            groups = Self.groupsWithTransactionsSortedByTime(groups)
            isNormalizingGroups = false
        }
    }

    var subscriptions: [RecurringSubscription] {
        didSet { saveSubscriptions() }
    }

    var dailyBudget: Double {
        didSet { UserDefaults.standard.set(dailyBudget, forKey: budgetKey) }
    }

    private init() {
        let savedBudget = UserDefaults.standard.double(forKey: budgetKey)
        self.dailyBudget = savedBudget > 0 ? savedBudget : 170.0

        let loadedGroups: [SpendingTransactionGroup]
        if let data = UserDefaults.standard.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([SpendingTransactionGroup].self, from: data) {
            loadedGroups = decoded
        } else {
            loadedGroups = TransactionData.sampleGroups
        }
        self.groups = Self.groupsWithTransactionsSortedByTime(loadedGroups)

        // ✅ per screenshot: if nothing saved yet, start EMPTY (not sampleSubscriptions)
        if let data = UserDefaults.standard.data(forKey: subscriptionsKey),
           let decoded = try? JSONDecoder().decode([RecurringSubscription].self, from: data) {
            self.subscriptions = decoded
        } else {
            self.subscriptions = [] // empty instead of sampleSubscriptions
        }

        syncRecurringTransactions()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: groupsKey)
        }
    }

    private func saveSubscriptions() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: subscriptionsKey)
        }
    }

    private static func groupsWithTransactionsSortedByTime(_ groups: [SpendingTransactionGroup]) -> [SpendingTransactionGroup] {
        groups.map { group in
            let sortedTransactions = group.transactions
                .enumerated()
                .sorted { lhs, rhs in
                    let lhsTime = parsedMinutesSinceMidnight(lhs.element.time)
                    let rhsTime = parsedMinutesSinceMidnight(rhs.element.time)

                    switch (lhsTime, rhsTime) {
                    case let (l?, r?):
                        if l != r { return l > r } // latest time first
                    case (_?, nil):
                        return true // known clock times before labels like "Auto-Pay"
                    case (nil, _?):
                        return false
                    case (nil, nil):
                        break
                    }

                    return lhs.offset < rhs.offset // stable order for ties/unparseable times
                }
                .map(\.element)

            return SpendingTransactionGroup(
                id: group.id,
                title: group.title,
                transactions: sortedTransactions
            )
        }
    }

    private static func parsedMinutesSinceMidnight(_ time: String) -> Int? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"

        guard let date = formatter.date(from: time) else { return nil }
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return (hour * 60) + minute
    }

    // MARK: - Add Subscription + Auto-log Transaction
    func addSubscription(_ sub: RecurringSubscription, logInitialTransaction: Bool = true) {
        // Add to recurring list
        subscriptions.append(sub)

        guard logInitialTransaction else { return }

        // Auto-log as a transaction today
        addRecurringTransaction(
            for: sub,
            on: Date(),
            timeString: recurringTimeString(for: Date())
        )
    }

    func syncRecurringTransactions() {
        if isSyncingRecurring { return }
        isSyncingRecurring = true
        defer { isSyncingRecurring = false }

        guard !subscriptions.isEmpty else { return }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        var updated = subscriptions
        var didMutateSubscriptions = false

        for index in updated.indices {
            guard let epoch = updated[index].nextBillingEpoch else { continue }
            if updated[index].frequencyKey == nil && ((updated[index].frequencyDays ?? 0) <= 0) {
                continue
            }

            var nextDate = Date(timeIntervalSince1970: epoch)
            var addedAny = false

            while calendar.startOfDay(for: nextDate) <= todayStart {
                addRecurringTransaction(for: updated[index], on: nextDate, timeString: "Auto-Pay")
                addedAny = true
                nextDate = Self.advanceRecurringDate(
                    current: nextDate,
                    frequencyKey: updated[index].frequencyKey,
                    fallbackDays: updated[index].frequencyDays
                )
            }

            if addedAny {
                didMutateSubscriptions = true
                let nextBillingString = Self.billingDisplayString(for: nextDate)
                updated[index] = RecurringSubscription(
                    id: updated[index].id,
                    name: updated[index].name,
                    plan: updated[index].plan,
                    price: updated[index].price,
                    iconName: updated[index].iconName,
                    iconColor: updated[index].iconColor,
                    bgColor: updated[index].bgColor,
                    nextBilling: nextBillingString,
                    frequencyDays: updated[index].frequencyDays,
                    frequencyKey: updated[index].frequencyKey,
                    nextBillingEpoch: nextDate.timeIntervalSince1970
                )
            }
        }

        if didMutateSubscriptions {
            subscriptions = updated
        }
    }

    private static func billingDisplayString(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: date)
    }

    private static func advanceRecurringDate(current: Date, frequencyKey: String?, fallbackDays: Int?) -> Date {
        let calendar = Calendar.current

        switch frequencyKey {
        case "weekly":
            return calendar.date(byAdding: .day, value: 7, to: current) ?? current
        case "monthly":
            return calendar.date(byAdding: .month, value: 1, to: current) ?? current
        case "quarterly":
            return calendar.date(byAdding: .month, value: 3, to: current) ?? current
        case "biannual":
            return calendar.date(byAdding: .month, value: 6, to: current) ?? current
        case "annual":
            return calendar.date(byAdding: .year, value: 1, to: current) ?? current
        default:
            let days = max(fallbackDays ?? 0, 1)
            return calendar.date(byAdding: .day, value: days, to: current) ?? current.addingTimeInterval(Double(days) * 86_400)
        }
    }

    private func recurringTimeString(for date: Date) -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        return timeFormatter.string(from: date)
    }

    private func addRecurringTransaction(for sub: RecurringSubscription, on date: Date, timeString: String) {
        let dayLabel = Self.dayLabel(for: date)

        let transaction = SpendingTransaction(
            icon: sub.iconName.contains(".") ? sub.iconName : "music.note",
            title: sub.name,
            subtitle: sub.plan ?? "Subscription",
            time: timeString,
            amount: "-$\(String(format: "%.2f", sub.price))",
            isImpulse: false,
            iconColor: SpendingCategory.subscriptions.color,
            bgColor: SpendingCategory.subscriptions.color.opacity(0.1),
            borderColor: SpendingCategory.subscriptions.color.opacity(0.2),
            category: .subscriptions
        )

        if let index = groups.firstIndex(where: { $0.title == dayLabel }) {
            var updated = groups[index].transactions
            updated.insert(transaction, at: 0)
            groups[index] = SpendingTransactionGroup(
                title: groups[index].title,
                transactions: updated
            )
        } else {
            let labelFormatter = DateFormatter()
            labelFormatter.dateFormat = "EEEE, MMM d"
            let insertIndex = groups.firstIndex(where: { group in
                if group.title == "Today" { return false }
                if group.title == "Yesterday" {
                    return !Calendar.current.isDateInToday(date)
                }
                if let groupDate = labelFormatter.date(from: group.title) {
                    return groupDate < date
                }
                return false
            }) ?? groups.endIndex

            groups.insert(SpendingTransactionGroup(title: dayLabel, transactions: [transaction]), at: insertIndex)
        }
    }

    private static func dayLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEEE, MMM d"
            return fmt.string(from: date)
        }
    }

    // MARK: - Computed Analytics
    var allTransactions: [SpendingTransaction] {
        groups.flatMap { $0.transactions }
    }

    var totalSpent: Double {
        allTransactions.reduce(0) { $0 + $1.amountValue }
    }

    var transactionCount: Int {
        allTransactions.count
    }

    var categoryTotals: [CategoryData] {
        var totals: [SpendingCategory: Double] = [:]
        for t in allTransactions {
            totals[t.category, default: 0] += t.amountValue
        }
        return totals
            .sorted { $0.value > $1.value }
            .map { CategoryData(name: $0.key.rawValue, color: $0.key.color, amount: $0.value, total: totalSpent) }
    }

    var topCategories: [CategoryData] {
        Array(categoryTotals.prefix(4))
    }

    var recentTransactions: [SpendingTransaction] {
        Array(allTransactions.prefix(3))
    }

    var dailySpent: Double {
        groups.first?.transactions.reduce(0) { $0 + $1.amountValue } ?? 0
    }

    var dailyRemaining: Double {
        max(dailyBudget - dailySpent, 0)
    }

    // MARK: - Sample Data
    static var sampleGroups: [SpendingTransactionGroup] = [
        SpendingTransactionGroup(title: "Today", transactions: [
            SpendingTransaction(icon: "cup.and.saucer.fill", title: "Blue Bottle", subtitle: "Coffee & Pastry", time: "08:42 AM", amount: "-$12.50", isImpulse: false, iconColor: Color(red: 1.0, green: 0.416, blue: 0.165), bgColor: Color.orange.opacity(0.1), borderColor: Color.orange.opacity(0.2), category: .lifestyle),
            SpendingTransaction(icon: "car.fill", title: "Uber Trip", subtitle: "Transport", time: "10:15 AM", amount: "-$24.20", isImpulse: false, iconColor: Color.blue.opacity(0.8), bgColor: Color.blue.opacity(0.1), borderColor: Color.blue.opacity(0.2), category: .transport),
            SpendingTransaction(icon: "bag.fill", title: "Target", subtitle: "Shopping", time: "12:30 PM", amount: "-$47.83", isImpulse: true, iconColor: Color.red.opacity(0.8), bgColor: Color.red.opacity(0.1), borderColor: Color.red.opacity(0.2), category: .shopping),
            SpendingTransaction(icon: "fork.knife", title: "Chipotle", subtitle: "Dining", time: "01:15 PM", amount: "-$14.25", isImpulse: false, iconColor: Color(red: 0.2, green: 0.78, blue: 0.55), bgColor: Color.green.opacity(0.1), borderColor: Color.green.opacity(0.2), category: .dining),
        ]),
        SpendingTransactionGroup(title: "Yesterday", transactions: [
            SpendingTransaction(icon: "fork.knife", title: "Sweetgreen Salads", subtitle: "Dining", time: "01:30 PM", amount: "-$18.90", isImpulse: false, iconColor: Color(red: 0.2, green: 0.78, blue: 0.55), bgColor: Color.green.opacity(0.1), borderColor: Color.green.opacity(0.2), category: .dining),
            SpendingTransaction(icon: "tram.fill", title: "CalTrain Ticket", subtitle: "Transport", time: "05:45 PM", amount: "-$12.00", isImpulse: false, iconColor: Color.blue.opacity(0.8), bgColor: Color.blue.opacity(0.1), borderColor: Color.blue.opacity(0.2), category: .transport),
            SpendingTransaction(icon: "gamecontroller.fill", title: "Steam Store", subtitle: "Entertainment", time: "09:41 PM", amount: "-$59.99", isImpulse: true, iconColor: Color.purple.opacity(0.8), bgColor: Color.purple.opacity(0.1), borderColor: Color.purple.opacity(0.2), category: .entertainment),
            SpendingTransaction(icon: "cup.and.saucer.fill", title: "Ritual Coffee", subtitle: "Lifestyle", time: "09:12 AM", amount: "-$5.75", isImpulse: false, iconColor: Color(red: 1.0, green: 0.416, blue: 0.165), bgColor: Color.orange.opacity(0.1), borderColor: Color.orange.opacity(0.2), category: .lifestyle),
        ]),
        SpendingTransactionGroup(title: "Monday", transactions: [
            SpendingTransaction(icon: "bolt.fill", title: "PG&E Electric", subtitle: "Utilities", time: "Auto-Pay", amount: "-$82.40", isImpulse: false, iconColor: Color.yellow.opacity(0.9), bgColor: Color.yellow.opacity(0.1), borderColor: Color.yellow.opacity(0.2), category: .utilities),
            SpendingTransaction(icon: "cart.fill", title: "Trader Joe's", subtitle: "Groceries", time: "11:20 AM", amount: "-$63.17", isImpulse: false, iconColor: Color(red: 0.2, green: 0.78, blue: 0.55), bgColor: Color.green.opacity(0.1), borderColor: Color.green.opacity(0.2), category: .groceries),
            SpendingTransaction(icon: "dumbbell.fill", title: "Equinox", subtitle: "Fitness", time: "Auto-Pay", amount: "-$95.00", isImpulse: true, iconColor: Color(red: 1.0, green: 0.416, blue: 0.165), bgColor: Color.orange.opacity(0.1), borderColor: Color.orange.opacity(0.2), category: .fitness),
            SpendingTransaction(icon: "music.note", title: "Spotify Premium", subtitle: "Subscriptions", time: "Auto-Pay", amount: "-$10.99", isImpulse: false, iconColor: Color.green.opacity(0.8), bgColor: Color.green.opacity(0.1), borderColor: Color.green.opacity(0.2), category: .subscriptions),
        ]),
        SpendingTransactionGroup(title: "Last Sunday", transactions: [
            SpendingTransaction(icon: "fuelpump.fill", title: "Shell Gas", subtitle: "Transport", time: "10:05 AM", amount: "-$52.30", isImpulse: false, iconColor: Color.blue.opacity(0.8), bgColor: Color.blue.opacity(0.1), borderColor: Color.blue.opacity(0.2), category: .transport),
            SpendingTransaction(icon: "film.fill", title: "AMC Theatres", subtitle: "Entertainment", time: "07:30 PM", amount: "-$28.50", isImpulse: true, iconColor: Color.purple.opacity(0.8), bgColor: Color.purple.opacity(0.1), borderColor: Color.purple.opacity(0.2), category: .entertainment),
            SpendingTransaction(icon: "cup.and.saucer.fill", title: "Philz Coffee", subtitle: "Lifestyle", time: "09:00 AM", amount: "-$7.25", isImpulse: false, iconColor: Color(red: 1.0, green: 0.416, blue: 0.165), bgColor: Color.orange.opacity(0.1), borderColor: Color.orange.opacity(0.2), category: .lifestyle),
        ]),
    ]

    // Keeping this here is fine, but it is no longer used for default seeding
    static var sampleSubscriptions: [RecurringSubscription] = [
        RecurringSubscription(name: "Netflix", plan: "Premium Plan", price: 19.99, iconName: "netflix", iconColor: .white, bgColor: .black, nextBilling: "May 12"),
        RecurringSubscription(name: "Spotify", plan: nil, price: 10.99, iconName: "spotify", iconColor: .black, bgColor: Color(red: 0.11, green: 0.72, blue: 0.33), nextBilling: "May 15"),
        RecurringSubscription(name: "Notion", plan: nil, price: 8.00, iconName: "notion", iconColor: .black, bgColor: .white, nextBilling: "May 18"),
        RecurringSubscription(name: "YouTube", plan: "Premium", price: 13.99, iconName: "youtube", iconColor: .white, bgColor: Color(red: 1.0, green: 0.0, blue: 0.0), nextBilling: "May 20"),
        RecurringSubscription(name: "Equinox", plan: "Monthly", price: 95.00, iconName: "dumbbell.fill", iconColor: .white, bgColor: Color(red: 0.1, green: 0.1, blue: 0.1), nextBilling: "May 1"),
        RecurringSubscription(name: "iCloud", plan: "200GB", price: 2.99, iconName: "icloud.fill", iconColor: .white, bgColor: Color(red: 0.2, green: 0.5, blue: 1.0), nextBilling: "May 5"),
    ]
}
