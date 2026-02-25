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
            let txSorted = Self.groupsWithTransactionsSortedByTime(groups)
            groups = Self.groupsSortedChronologically(txSorted)
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
        self.groups = Self.groupsSortedChronologically(
            Self.groupsWithTransactionsSortedByTime(loadedGroups)
        )

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
                    let lhsSort = timeSortKey(lhs.element.time)
                    let rhsSort = timeSortKey(rhs.element.time)

                    if lhsSort.rank != rhsSort.rank {
                        return lhsSort.rank < rhsSort.rank
                    }

                    if let lMinute = lhsSort.minuteOfDay,
                       let rMinute = rhsSort.minuteOfDay,
                       lMinute != rMinute {
                        return lMinute > rMinute // latest real clock time first
                    }

                    return lhs.offset < rhs.offset // stable order for non-time placeholders
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

    private static func timeSortKey(_ time: String) -> (rank: Int, minuteOfDay: Int?) {
        if let minute = parsedMinutesSinceMidnight(time) {
            return (0, minute) // exact clock times first
        }
        if time.caseInsensitiveCompare("Auto-Pay") == .orderedSame {
            return (2, nil) // recurring placeholders last within a day
        }
        return (1, nil) // other placeholders like "Added"
    }

    private static func groupsSortedChronologically(_ groups: [SpendingTransactionGroup]) -> [SpendingTransactionGroup] {
        let now = Date()
        return groups
            .enumerated()
            .sorted { lhs, rhs in
                let lhsDate = resolvedDate(forGroupTitle: lhs.element.title, now: now)
                let rhsDate = resolvedDate(forGroupTitle: rhs.element.title, now: now)

                switch (lhsDate, rhsDate) {
                case let (l?, r?):
                    if l != r { return l > r } // newest day first
                case (_?, nil):
                    return true
                case (nil, _?):
                    return false
                case (nil, nil):
                    break
                }

                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }

    private static func resolvedDate(forGroupTitle title: String, now: Date) -> Date? {
        let calendar = Calendar.current

        if title == "Today" { return calendar.startOfDay(for: now) }
        if title == "Yesterday" {
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))
        }

        // Explicit date label used by this app: "EEEE, MMM d"
        let explicitFormatter = DateFormatter()
        explicitFormatter.locale = Locale(identifier: "en_US_POSIX")
        explicitFormatter.dateFormat = "EEEE, MMM d"
        if let parsed = explicitFormatter.date(from: title) {
            let month = calendar.component(.month, from: parsed)
            let day = calendar.component(.day, from: parsed)
            let currentYear = calendar.component(.year, from: now)

            var components = DateComponents()
            components.year = currentYear
            components.month = month
            components.day = day

            if let candidate = calendar.date(from: components) {
                if candidate > now, let previousYear = calendar.date(byAdding: .year, value: -1, to: candidate) {
                    return previousYear
                }
                return candidate
            }
        }

        // Relative weekday labels like "Last Sunday" or "Monday"
        let weekdayMap: [String: Int] = [
            "Sunday": 1, "Monday": 2, "Tuesday": 3, "Wednesday": 4,
            "Thursday": 5, "Friday": 6, "Saturday": 7
        ]
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let isLastPrefix = normalized.hasPrefix("Last ")
        let weekdayName = isLastPrefix
            ? String(normalized.dropFirst("Last ".count))
            : normalized

        if let targetWeekday = weekdayMap[weekdayName] {
            let todayWeekday = calendar.component(.weekday, from: now)
            var daysBack = (todayWeekday - targetWeekday + 7) % 7
            if isLastPrefix || daysBack == 0 { daysBack += 7 }
            return calendar.date(byAdding: .day, value: -daysBack, to: calendar.startOfDay(for: now))
        }

        return nil
    }

    // MARK: - Add Subscription + Auto-log Transaction
    func addSubscription(
        _ sub: RecurringSubscription,
        logInitialTransaction: Bool = true,
        initialTransactionDate: Date = Date()
    ) {
        // Add to recurring list
        subscriptions.append(sub)

        guard logInitialTransaction else { return }

        // Auto-log as a transaction on the selected start date
        addRecurringTransaction(
            for: sub,
            on: initialTransactionDate,
            timeString: recurringTimeString(for: initialTransactionDate)
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
            groups.append(SpendingTransactionGroup(title: dayLabel, transactions: [transaction]))
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
    private struct SeedTemplate {
        let title: String
        let subtitle: String
        let icon: String
        let category: SpendingCategory
        let amountRange: ClosedRange<Double>
        let canBeImpulse: Bool
        let canAutoPay: Bool
    }

    private static let seedTemplates: [SeedTemplate] = [
        SeedTemplate(title: "Blue Bottle", subtitle: "Coffee & Pastry", icon: "cup.and.saucer.fill", category: .lifestyle, amountRange: 6...18, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Philz Coffee", subtitle: "Coffee", icon: "cup.and.saucer.fill", category: .lifestyle, amountRange: 5...14, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Chipotle", subtitle: "Dining", icon: "fork.knife", category: .dining, amountRange: 11...26, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Sweetgreen", subtitle: "Salad Bowl", icon: "fork.knife", category: .dining, amountRange: 12...24, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "DoorDash", subtitle: "Takeout", icon: "takeoutbag.and.cup.and.straw.fill", category: .dining, amountRange: 17...52, canBeImpulse: true, canAutoPay: false),
        SeedTemplate(title: "Uber Trip", subtitle: "Transport", icon: "car.fill", category: .transport, amountRange: 10...46, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "BART Reload", subtitle: "Transit", icon: "tram.fill", category: .transport, amountRange: 5...35, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Shell Gas", subtitle: "Fuel", icon: "fuelpump.fill", category: .transport, amountRange: 28...84, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Trader Joe's", subtitle: "Groceries", icon: "cart.fill", category: .groceries, amountRange: 28...98, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Whole Foods", subtitle: "Groceries", icon: "cart.fill", category: .groceries, amountRange: 36...126, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Costco", subtitle: "Groceries", icon: "cart.fill", category: .groceries, amountRange: 44...188, canBeImpulse: false, canAutoPay: false),
        SeedTemplate(title: "Target", subtitle: "Shopping", icon: "bag.fill", category: .shopping, amountRange: 18...135, canBeImpulse: true, canAutoPay: false),
        SeedTemplate(title: "Amazon", subtitle: "Shopping", icon: "bag.fill", category: .shopping, amountRange: 12...176, canBeImpulse: true, canAutoPay: false),
        SeedTemplate(title: "Apple Store", subtitle: "Shopping", icon: "bag.fill", category: .shopping, amountRange: 19...229, canBeImpulse: true, canAutoPay: false),
        SeedTemplate(title: "AMC Theatres", subtitle: "Entertainment", icon: "film.fill", category: .entertainment, amountRange: 14...48, canBeImpulse: true, canAutoPay: false),
        SeedTemplate(title: "Steam Store", subtitle: "Gaming", icon: "gamecontroller.fill", category: .entertainment, amountRange: 9...70, canBeImpulse: true, canAutoPay: false),
        SeedTemplate(title: "Spotify", subtitle: "Premium", icon: "music.note", category: .subscriptions, amountRange: 9...19, canBeImpulse: false, canAutoPay: true),
        SeedTemplate(title: "Netflix", subtitle: "Premium Plan", icon: "tv.fill", category: .subscriptions, amountRange: 15...28, canBeImpulse: false, canAutoPay: true),
        SeedTemplate(title: "iCloud", subtitle: "Storage", icon: "icloud.fill", category: .subscriptions, amountRange: 2...12, canBeImpulse: false, canAutoPay: true),
        SeedTemplate(title: "PG&E Electric", subtitle: "Utilities", icon: "bolt.fill", category: .utilities, amountRange: 58...156, canBeImpulse: false, canAutoPay: true),
        SeedTemplate(title: "SF Water", subtitle: "Utilities", icon: "drop.fill", category: .utilities, amountRange: 24...88, canBeImpulse: false, canAutoPay: true),
        SeedTemplate(title: "Equinox", subtitle: "Membership", icon: "dumbbell.fill", category: .fitness, amountRange: 90...220, canBeImpulse: false, canAutoPay: true),
        SeedTemplate(title: "ClassPass", subtitle: "Fitness", icon: "figure.run", category: .fitness, amountRange: 39...109, canBeImpulse: false, canAutoPay: true),
    ]

    static var sampleGroups: [SpendingTransactionGroup] {
        generateInitialGroups()
    }

    private static func generateInitialGroups(days: Int = 21) -> [SpendingTransactionGroup] {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        var groups: [SpendingTransactionGroup] = []

        for dayOffset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: todayStart) else { continue }
            let title = dayLabel(for: date)

            let txCount: Int
            switch dayOffset {
            case 0...2: txCount = Int.random(in: 4...7)
            case 3...9: txCount = Int.random(in: 3...6)
            default: txCount = Int.random(in: 2...5)
            }

            var dayTransactions: [SpendingTransaction] = []
            var usedTemplateTitles: Set<String> = []

            for _ in 0..<txCount {
                let template = randomTemplate(excluding: usedTemplateTitles)
                usedTemplateTitles.insert(template.title)

                let amount = Double.random(in: template.amountRange)
                let rounded = (amount * 100).rounded() / 100
                let categoryColor = template.category.color
                let useAutoPay = template.canAutoPay && randomChance(0.30)

                let transaction = SpendingTransaction(
                    icon: template.icon,
                    title: template.title,
                    subtitle: template.subtitle,
                    time: useAutoPay ? "Auto-Pay" : randomTimeString(),
                    amount: "-$\(String(format: "%.2f", rounded))",
                    isImpulse: template.canBeImpulse ? randomChance(0.35) : false,
                    iconColor: categoryColor.opacity(0.90),
                    bgColor: categoryColor.opacity(0.10),
                    borderColor: categoryColor.opacity(0.20),
                    category: template.category
                )
                dayTransactions.append(transaction)
            }

            groups.append(
                SpendingTransactionGroup(
                    title: title,
                    transactions: groupsWithTransactionsSortedByTime([
                        SpendingTransactionGroup(title: title, transactions: dayTransactions)
                    ]).first?.transactions ?? dayTransactions
                )
            )
        }

        return groupsSortedChronologically(groups)
    }

    private static func randomTemplate(excluding usedTitles: Set<String>) -> SeedTemplate {
        let available = seedTemplates.filter { !usedTitles.contains($0.title) }
        return (available.isEmpty ? seedTemplates : available).randomElement() ?? seedTemplates[0]
    }

    private static func randomTimeString() -> String {
        let hour = Int.random(in: 7...22)
        let minute = Int.random(in: 0...59)
        let date = Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: Date()
        ) ?? Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private static func randomChance(_ probability: Double) -> Bool {
        Double.random(in: 0...1) < probability
    }

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
