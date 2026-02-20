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

    // Convenience init from original parameters
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

    var groups: [SpendingTransactionGroup] {
        didSet { save() }
    }

    var dailyBudget: Double {
        didSet { UserDefaults.standard.set(dailyBudget, forKey: budgetKey) }
    }

    private init() {
        // Load budget
        let savedBudget = UserDefaults.standard.double(forKey: "penny_daily_budget")
        self.dailyBudget = savedBudget > 0 ? savedBudget : 170.0

        // Load groups
        if let data = UserDefaults.standard.data(forKey: "penny_transaction_groups"),
           let decoded = try? JSONDecoder().decode([SpendingTransactionGroup].self, from: data) {
            self.groups = decoded
        } else {
            // First launch — seed with sample data
            self.groups = TransactionData.sampleGroups
        }
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(encoded, forKey: groupsKey)
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
}
