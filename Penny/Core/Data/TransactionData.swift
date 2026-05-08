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

enum TransactionKind: String, CaseIterable, Codable {
    case spending = "Spending"
    case income = "Income"
    case transfer = "Transfer"
    case refund = "Refund"

    var editorTitle: String {
        switch self {
        case .spending: return "Expense"
        case .income: return "Income"
        case .transfer: return "Transfer"
        case .refund: return "Refund"
        }
    }

    var actionTitle: String {
        switch self {
        case .spending: return "Log Expense"
        case .income: return "Log Income"
        case .transfer: return "Log Transfer"
        case .refund: return "Log Refund"
        }
    }

    var saveTitle: String {
        switch self {
        case .spending: return "Save Expense"
        case .income: return "Save Income"
        case .transfer: return "Save Transfer"
        case .refund: return "Save Refund"
        }
    }

    var signedAmountColor: Color {
        switch self {
        case .spending:
            return .white
        case .income:
            return Color(red: 0.29, green: 0.87, blue: 0.50)
        case .transfer:
            return Color(red: 0.38, green: 0.65, blue: 0.98)
        case .refund:
            return Color(red: 0.98, green: 0.85, blue: 0.35)
        }
    }

    var usesImpulseFlag: Bool {
        self == .spending
    }

    func signedAmountString(for amount: Double) -> String {
        let formatted = String(format: "%.2f", abs(amount))
        switch self {
        case .spending, .transfer:
            return "-$\(formatted)"
        case .income, .refund:
            return "+$\(formatted)"
        }
    }

    func summaryAmount(_ amount: Double) -> Double {
        switch self {
        case .spending, .transfer:
            return -abs(amount)
        case .income, .refund:
            return abs(amount)
        }
    }
}

enum AccountType: String, CaseIterable, Codable {
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    case investment = "Investment"
    case loan = "Loan"
    case cash = "Cash"
}

enum InvestmentAssetClass: String, CaseIterable, Codable, Identifiable {
    case stock = "Stock"
    case etf = "ETF"
    case mutualFund = "Mutual Fund"
    case bond = "Bond"
    case crypto = "Crypto"
    case cash = "Cash"
    case alternative = "Alternative"

    var id: String { rawValue }
}

enum BudgetMode: String, CaseIterable, Codable {
    case daily = "Daily"
    case monthly = "Monthly"
}

enum AppDataMode: String, CaseIterable, Codable, Identifiable {
    case demo = "Demo"
    case real = "Real"

    var id: String { rawValue }
}

enum RecurringStatus: String, CaseIterable, Codable, Identifiable {
    case active = "Active"
    case paused = "Paused"
    case archived = "Archived"

    var id: String { rawValue }
}

struct ManualForecastItem: Identifiable, Codable {
    enum Kind: String, CaseIterable, Codable, Identifiable {
        case income = "Income"
        case bill = "Bill"

        var id: String { rawValue }
    }

    let id: UUID
    var title: String
    var amount: Double
    var date: Date
    var kind: Kind
    var note: String?

    init(
        id: UUID = UUID(),
        title: String,
        amount: Double,
        date: Date,
        kind: Kind,
        note: String? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.kind = kind
        self.note = note
    }
}

struct Account: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: AccountType
    let institution: String
    let balance: Double
    let lastUpdated: Date
    let isHidden: Bool

    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        institution: String,
        balance: Double,
        lastUpdated: Date = Date(),
        isHidden: Bool = false
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.institution = institution
        self.balance = balance
        self.lastUpdated = lastUpdated
        self.isHidden = isHidden
    }

    enum CodingKeys: String, CodingKey {
        case id, name, type, institution, balance, lastUpdated, isHidden
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        type = try container.decodeIfPresent(AccountType.self, forKey: .type) ?? .checking
        institution = try container.decodeIfPresent(String.self, forKey: .institution) ?? ""

        if let numericBalance = try container.decodeIfPresent(Double.self, forKey: .balance) {
            balance = numericBalance
        } else if let stringBalance = try container.decodeIfPresent(String.self, forKey: .balance) {
            let cleaned = stringBalance
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            balance = Double(cleaned) ?? 0
        } else {
            balance = 0
        }

        lastUpdated = try container.decodeIfPresent(Date.self, forKey: .lastUpdated) ?? Date()
        isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(institution, forKey: .institution)
        try container.encode(balance, forKey: .balance)
        try container.encode(lastUpdated, forKey: .lastUpdated)
        try container.encode(isHidden, forKey: .isHidden)
    }
}

struct InvestmentHolding: Identifiable, Codable {
    let id: UUID
    let accountId: UUID
    var symbol: String
    var name: String
    var assetClass: InvestmentAssetClass
    var shares: Double
    var averageCostPerShare: Double
    var currentPricePerShare: Double
    var lastUpdated: Date

    init(
        id: UUID = UUID(),
        accountId: UUID,
        symbol: String,
        name: String,
        assetClass: InvestmentAssetClass,
        shares: Double,
        averageCostPerShare: Double,
        currentPricePerShare: Double,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.accountId = accountId
        self.symbol = symbol
        self.name = name
        self.assetClass = assetClass
        self.shares = shares
        self.averageCostPerShare = averageCostPerShare
        self.currentPricePerShare = currentPricePerShare
        self.lastUpdated = lastUpdated
    }

    var marketValue: Double {
        shares * currentPricePerShare
    }

    var costBasis: Double {
        shares * averageCostPerShare
    }

    var gainLoss: Double {
        marketValue - costBasis
    }

    var gainLossPercent: Double {
        guard costBasis != 0 else { return 0 }
        return gainLoss / costBasis
    }
}

struct PortfolioAllocationSlice: Identifiable {
    let id = UUID()
    let assetClass: InvestmentAssetClass
    let marketValue: Double
    let percentage: Double
}

struct InvestmentPerformanceSummary {
    let marketValue: Double
    let costBasis: Double
    let gainLoss: Double
    let gainLossPercent: Double
    let holdingsCount: Int
}

struct BudgetCategory: Identifiable, Codable {
    let id: UUID
    let category: SpendingCategory
    var monthlyBudget: Double
    var isExcluded: Bool
    var allowsRollover: Bool

    init(
        id: UUID = UUID(),
        category: SpendingCategory,
        monthlyBudget: Double,
        isExcluded: Bool = false,
        allowsRollover: Bool = false
    ) {
        self.id = id
        self.category = category
        self.monthlyBudget = monthlyBudget
        self.isExcluded = isExcluded
        self.allowsRollover = allowsRollover
    }
}

struct MerchantRule: Identifiable, Codable {
    let id: UUID
    let matchPattern: String
    let categoryOverride: SpendingCategory?
    let merchantDisplayName: String?
    let recurringHint: Bool

    init(
        id: UUID = UUID(),
        matchPattern: String,
        categoryOverride: SpendingCategory? = nil,
        merchantDisplayName: String? = nil,
        recurringHint: Bool = false
    ) {
        self.id = id
        self.matchPattern = matchPattern
        self.categoryOverride = categoryOverride
        self.merchantDisplayName = merchantDisplayName
        self.recurringHint = recurringHint
    }
}

struct SavingsGoal: Identifiable, Codable {
    let id: UUID
    let name: String
    let targetAmount: Double
    var currentAmount: Double
    let linkedAccountId: UUID?
    let linkedCategory: SpendingCategory?

    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double,
        linkedAccountId: UUID? = nil,
        linkedCategory: SpendingCategory? = nil
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.linkedAccountId = linkedAccountId
        self.linkedCategory = linkedCategory
    }
}

struct TransactionAttachment: Identifiable, Codable, Equatable {
    enum Kind: String, Codable {
        case image
        case document
    }

    let id: UUID
    let fileName: String
    let storedFileName: String
    let kind: Kind
    let addedAt: Date

    init(
        id: UUID = UUID(),
        fileName: String,
        storedFileName: String,
        kind: Kind,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.fileName = fileName
        self.storedFileName = storedFileName
        self.kind = kind
        self.addedAt = addedAt
    }
}

struct MonthlyComparison {
    let current: Double
    let previous: Double

    var delta: Double { current - previous }
    var percentChange: Double {
        guard previous != 0 else { return current == 0 ? 0 : 1 }
        return delta / previous
    }
}

struct SplitTransactionAllocation: Identifiable, Codable, Equatable {
    let id: UUID
    var category: SpendingCategory
    var amount: Double
    var label: String

    init(
        id: UUID = UUID(),
        category: SpendingCategory,
        amount: Double,
        label: String = ""
    ) {
        self.id = id
        self.category = category
        self.amount = amount
        self.label = label
    }
}

struct TransactionImportSummary {
    let importedCount: Int
    let duplicateCount: Int
}

struct CashFlowForecastEvent: Identifiable {
    enum EventKind {
        case income
        case bill
    }

    let id: UUID
    let title: String
    let date: Date
    let amount: Double
    let kind: EventKind
    let subtitle: String
}

struct CashFlowForecast {
    let startingCash: Double
    let events: [CashFlowForecastEvent]
    let projectedEndOfMonthCash: Double
    let expectedIncome: Double
    let expectedBills: Double

    var next30DayNet: Double {
        expectedIncome - expectedBills
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
    let accountId: UUID?
    let kind: TransactionKind
    let merchantRaw: String?
    let merchantNormalized: String?
    let notes: String?
    let tags: [String]
    let attachments: [TransactionAttachment]
    let isExcludedFromBudget: Bool
    let isRecurringCandidate: Bool
    let splitGroupId: UUID?
    let splitLabel: String?

    init(
        id: UUID = UUID(),
        icon: String, title: String, subtitle: String,
        time: String, amount: String, isImpulse: Bool,
        iconColor: Color, bgColor: Color, borderColor: Color,
        category: SpendingCategory,
        accountId: UUID? = nil,
        kind: TransactionKind = .spending,
        merchantRaw: String? = nil,
        merchantNormalized: String? = nil,
        notes: String? = nil,
        tags: [String] = [],
        attachments: [TransactionAttachment] = [],
        isExcludedFromBudget: Bool = false,
        isRecurringCandidate: Bool = false,
        splitGroupId: UUID? = nil,
        splitLabel: String? = nil
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
        self.accountId = accountId
        self.kind = kind
        self.merchantRaw = merchantRaw ?? title
        self.merchantNormalized = merchantNormalized ?? title
        self.notes = notes
        self.tags = tags
        self.attachments = attachments
        self.isExcludedFromBudget = isExcludedFromBudget
        self.isRecurringCandidate = isRecurringCandidate
        self.splitGroupId = splitGroupId
        self.splitLabel = splitLabel
    }

    enum CodingKeys: String, CodingKey {
        case id, icon, title, subtitle, time, amount, isImpulse
        case iconColorHex, bgColorHex, borderColorHex, category
        case accountId, kind, merchantRaw, merchantNormalized, notes, tags, attachments
        case isExcludedFromBudget, isRecurringCandidate
        case splitGroupId, splitLabel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        icon = try container.decode(String.self, forKey: .icon)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        time = try container.decode(String.self, forKey: .time)
        amount = try container.decode(String.self, forKey: .amount)
        isImpulse = try container.decode(Bool.self, forKey: .isImpulse)
        iconColorHex = try container.decode(String.self, forKey: .iconColorHex)
        bgColorHex = try container.decode(String.self, forKey: .bgColorHex)
        borderColorHex = try container.decode(String.self, forKey: .borderColorHex)
        category = try container.decode(SpendingCategory.self, forKey: .category)
        accountId = try container.decodeIfPresent(UUID.self, forKey: .accountId)
        kind = try container.decodeIfPresent(TransactionKind.self, forKey: .kind) ?? .spending
        merchantRaw = try container.decodeIfPresent(String.self, forKey: .merchantRaw) ?? title
        merchantNormalized = try container.decodeIfPresent(String.self, forKey: .merchantNormalized) ?? title
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        attachments = try container.decodeIfPresent([TransactionAttachment].self, forKey: .attachments) ?? []
        isExcludedFromBudget = try container.decodeIfPresent(Bool.self, forKey: .isExcludedFromBudget) ?? false
        isRecurringCandidate = try container.decodeIfPresent(Bool.self, forKey: .isRecurringCandidate) ?? false
        splitGroupId = try container.decodeIfPresent(UUID.self, forKey: .splitGroupId)
        splitLabel = try container.decodeIfPresent(String.self, forKey: .splitLabel)
    }

    var iconColor: Color { Color(hex: iconColorHex) ?? .orange }
    var bgColor: Color { Color(hex: bgColorHex) ?? .clear }
    var borderColor: Color { Color(hex: borderColorHex) ?? .clear }

    var amountValue: Double {
        let cleaned = amount
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(cleaned) ?? 0
    }

    var amountSignedValue: Double {
        let cleaned = amount
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(cleaned) ?? 0
    }

    var isSplitChild: Bool {
        splitGroupId != nil
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
    let merchantMatchPattern: String?
    let expectedAmountMin: Double?
    let expectedAmountMax: Double?
    let linkedTransactionIds: [UUID]
    let status: RecurringStatus

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
        nextBillingEpoch: TimeInterval? = nil,
        merchantMatchPattern: String? = nil,
        expectedAmountMin: Double? = nil,
        expectedAmountMax: Double? = nil,
        linkedTransactionIds: [UUID] = [],
        status: RecurringStatus = .active
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
        self.merchantMatchPattern = merchantMatchPattern
        self.expectedAmountMin = expectedAmountMin
        self.expectedAmountMax = expectedAmountMax
        self.linkedTransactionIds = linkedTransactionIds
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case id, name, plan, price, iconName, iconColorHex, bgColorHex
        case nextBilling, frequencyDays, frequencyKey, nextBillingEpoch
        case merchantMatchPattern, expectedAmountMin, expectedAmountMax, linkedTransactionIds, status
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        plan = try container.decodeIfPresent(String.self, forKey: .plan)
        price = try container.decode(Double.self, forKey: .price)
        iconName = try container.decode(String.self, forKey: .iconName)
        iconColorHex = try container.decode(String.self, forKey: .iconColorHex)
        bgColorHex = try container.decode(String.self, forKey: .bgColorHex)
        nextBilling = try container.decode(String.self, forKey: .nextBilling)
        frequencyDays = try container.decodeIfPresent(Int.self, forKey: .frequencyDays)
        frequencyKey = try container.decodeIfPresent(String.self, forKey: .frequencyKey)
        nextBillingEpoch = try container.decodeIfPresent(TimeInterval.self, forKey: .nextBillingEpoch)
        merchantMatchPattern = try container.decodeIfPresent(String.self, forKey: .merchantMatchPattern)
        expectedAmountMin = try container.decodeIfPresent(Double.self, forKey: .expectedAmountMin)
        expectedAmountMax = try container.decodeIfPresent(Double.self, forKey: .expectedAmountMax)
        linkedTransactionIds = try container.decodeIfPresent([UUID].self, forKey: .linkedTransactionIds) ?? []
        status = try container.decodeIfPresent(RecurringStatus.self, forKey: .status) ?? .active
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

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

// MARK: - Shared Data
@Observable
class TransactionData {
    static let shared = TransactionData()

    static let appModeKey = "penny.app.mode"
    static let hasCompletedOnboardingKey = "penny.app.didCompleteOnboarding"

    private let groupsKey = "penny_transaction_groups"
    private let budgetModeKey = "penny_budget_mode"
    private let budgetValueKey = "penny_budget_value"
    private let legacyDailyBudgetKey = "penny_daily_budget"
    private let legacyMonthlyBudgetKey = "penny_monthly_budget"
    private let subscriptionsKey = "penny_recurring_subscriptions"
    private let accountsKey = "penny_accounts"
    private let investmentHoldingsKey = "penny_investment_holdings"
    private let merchantRulesKey = "penny_merchant_rules"
    private let manualForecastItemsKey = "penny_manual_forecast_items"
    private let manualV1ResetKey = "penny_manual_v1_reset_complete"
    private let defaultAccountId = UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID()
    private var isNormalizingGroups = false
    private var isSyncingRecurring = false

    var appMode: AppDataMode {
        didSet { UserDefaults.standard.set(appMode.rawValue, forKey: Self.appModeKey) }
    }

    var accounts: [Account] {
        didSet { saveAccounts() }
    }
    var investmentHoldings: [InvestmentHolding] {
        didSet { saveInvestmentHoldings() }
    }
    var budgetCategories: [BudgetCategory]
    var merchantRules: [MerchantRule] {
        didSet { saveMerchantRules() }
    }
    var savingsGoals: [SavingsGoal]

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

    var manualForecastItems: [ManualForecastItem] {
        didSet { saveManualForecastItems() }
    }

    var budgetMode: BudgetMode {
        didSet { UserDefaults.standard.set(budgetMode.rawValue, forKey: budgetModeKey) }
    }

    var budgetBaseValue: Double {
        didSet { UserDefaults.standard.set(budgetBaseValue, forKey: budgetValueKey) }
    }

    private init() {
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: manualV1ResetKey) {
            defaults.removeObject(forKey: groupsKey)
            defaults.removeObject(forKey: subscriptionsKey)
            defaults.removeObject(forKey: accountsKey)
            defaults.set(BudgetMode.daily.rawValue, forKey: budgetModeKey)
            defaults.set(0, forKey: budgetValueKey)
            defaults.set(true, forKey: manualV1ResetKey)
        }

        let savedBudgetMode = defaults.string(forKey: budgetModeKey).flatMap(BudgetMode.init(rawValue:))
        let savedBudgetValue = defaults.double(forKey: budgetValueKey)
        let legacyDailyBudget = defaults.double(forKey: legacyDailyBudgetKey)
        let legacyMonthlyBudget = defaults.double(forKey: legacyMonthlyBudgetKey)
        self.appMode = defaults.string(forKey: Self.appModeKey).flatMap(AppDataMode.init(rawValue:)) ?? .real

        if let savedBudgetMode, savedBudgetValue > 0 {
            self.budgetMode = savedBudgetMode
            self.budgetBaseValue = savedBudgetValue
        } else if legacyMonthlyBudget > 0 {
            self.budgetMode = .monthly
            self.budgetBaseValue = legacyMonthlyBudget
        } else if legacyDailyBudget > 0 {
            self.budgetMode = .daily
            self.budgetBaseValue = legacyDailyBudget
        } else {
            self.budgetMode = .daily
            self.budgetBaseValue = 0.0
        }
        if let data = defaults.data(forKey: accountsKey),
           let decoded = try? JSONDecoder().decode([Account].self, from: data) {
            self.accounts = decoded
        } else {
            self.accounts = []
        }
        if let data = defaults.data(forKey: investmentHoldingsKey),
           let decoded = try? JSONDecoder().decode([InvestmentHolding].self, from: data) {
            self.investmentHoldings = decoded
        } else {
            self.investmentHoldings = []
        }
        self.budgetCategories = TransactionData.emptyBudgetCategories
        if let data = defaults.data(forKey: merchantRulesKey),
           let decoded = try? JSONDecoder().decode([MerchantRule].self, from: data) {
            self.merchantRules = decoded
        } else {
            self.merchantRules = TransactionData.sampleMerchantRules
        }
        self.savingsGoals = []

        let loadedGroups: [SpendingTransactionGroup]
        if let data = defaults.data(forKey: groupsKey),
           let decoded = try? JSONDecoder().decode([SpendingTransactionGroup].self, from: data) {
            loadedGroups = decoded
        } else {
            loadedGroups = TransactionData.sampleGroups
        }
        self.groups = Self.groupsSortedChronologically(
            Self.groupsWithTransactionsSortedByTime(loadedGroups)
        )

        // ✅ per screenshot: if nothing saved yet, start EMPTY (not sampleSubscriptions)
        if let data = defaults.data(forKey: subscriptionsKey),
           let decoded = try? JSONDecoder().decode([RecurringSubscription].self, from: data) {
            self.subscriptions = decoded
        } else {
            self.subscriptions = [] // empty instead of sampleSubscriptions
        }

        if let data = defaults.data(forKey: manualForecastItemsKey),
           let decoded = try? JSONDecoder().decode([ManualForecastItem].self, from: data) {
            self.manualForecastItems = decoded.sorted { $0.date < $1.date }
        } else {
            self.manualForecastItems = []
        }

        groups = groups.map { group in
            SpendingTransactionGroup(
                id: group.id,
                title: group.title,
                transactions: group.transactions.map { normalizeAndApplyRules(to: $0) }
            )
        }

        if appMode == .demo && groups.isEmpty && accounts.isEmpty && subscriptions.isEmpty && investmentHoldings.isEmpty {
            loadDemoMode()
        }

        syncRecurringTransactions()
    }

    var daysInCurrentMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: Date())?.count ?? 30
    }

    var configuredBudgetValue: Double {
        budgetBaseValue
    }

    var dailyBudget: Double {
        guard budgetBaseValue > 0 else { return 0 }
        switch budgetMode {
        case .daily:
            return budgetBaseValue
        case .monthly:
            return budgetBaseValue / Double(daysInCurrentMonth)
        }
    }

    var derivedMonthlyBudget: Double {
        guard budgetBaseValue > 0 else { return 0 }
        switch budgetMode {
        case .daily:
            return budgetBaseValue * Double(daysInCurrentMonth)
        case .monthly:
            return budgetBaseValue
        }
    }

    func setBudget(mode: BudgetMode, value: Double) {
        budgetMode = mode
        budgetBaseValue = max(value, 0)
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

    private func saveAccounts() {
        if let encoded = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encoded, forKey: accountsKey)
            UserDefaults.standard.synchronize()
        }
    }

    private func saveInvestmentHoldings() {
        if let encoded = try? JSONEncoder().encode(investmentHoldings) {
            UserDefaults.standard.set(encoded, forKey: investmentHoldingsKey)
        }
    }

    private func saveManualForecastItems() {
        if let encoded = try? JSONEncoder().encode(manualForecastItems.sorted { $0.date < $1.date }) {
            UserDefaults.standard.set(encoded, forKey: manualForecastItemsKey)
        }
    }

    private func saveMerchantRules() {
        if let encoded = try? JSONEncoder().encode(merchantRules) {
            UserDefaults.standard.set(encoded, forKey: merchantRulesKey)
        }
    }

    func normalizeMerchant(_ merchant: String) -> String {
        merchant
            .uppercased()
            .replacingOccurrences(of: #"^(SQ \*|TST\*|PAYPAL \*|APPLE\.COM/BILL )"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+\d{3,}$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[^A-Z0-9& ]"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }

    func applyMerchantRules(to transaction: SpendingTransaction) -> SpendingTransaction {
        guard let matchedRule = merchantRules.first(where: { rule in
            transaction.title.localizedCaseInsensitiveContains(rule.matchPattern) ||
            (transaction.merchantRaw?.localizedCaseInsensitiveContains(rule.matchPattern) ?? false)
        }) else {
            return transaction
        }

        return SpendingTransaction(
            id: transaction.id,
            icon: transaction.icon,
            title: matchedRule.merchantDisplayName ?? transaction.title,
            subtitle: (matchedRule.categoryOverride ?? transaction.category).rawValue,
            time: transaction.time,
            amount: transaction.amount,
            isImpulse: transaction.isImpulse,
            iconColor: (matchedRule.categoryOverride ?? transaction.category).color,
            bgColor: (matchedRule.categoryOverride ?? transaction.category).color.opacity(0.1),
            borderColor: (matchedRule.categoryOverride ?? transaction.category).color.opacity(0.2),
            category: matchedRule.categoryOverride ?? transaction.category,
            accountId: transaction.accountId ?? defaultSpendingAccount?.id,
            kind: transaction.kind,
            merchantRaw: transaction.merchantRaw ?? transaction.title,
            merchantNormalized: matchedRule.merchantDisplayName ?? normalizeMerchant(transaction.merchantRaw ?? transaction.title),
            notes: transaction.notes,
            tags: transaction.tags,
            attachments: transaction.attachments,
            isExcludedFromBudget: transaction.isExcludedFromBudget,
            isRecurringCandidate: transaction.isRecurringCandidate || matchedRule.recurringHint,
            splitGroupId: transaction.splitGroupId,
            splitLabel: transaction.splitLabel
        )
    }

    func normalizeAndApplyRules(to transaction: SpendingTransaction) -> SpendingTransaction {
        let normalizedMerchant = normalizeMerchant(transaction.merchantRaw ?? transaction.title)
        let normalized = SpendingTransaction(
            id: transaction.id,
            icon: transaction.icon,
            title: transaction.title,
            subtitle: transaction.subtitle,
            time: transaction.time,
            amount: transaction.amount,
            isImpulse: transaction.isImpulse,
            iconColor: transaction.iconColor,
            bgColor: transaction.bgColor,
            borderColor: transaction.borderColor,
            category: transaction.category,
            accountId: transaction.accountId ?? defaultSpendingAccount?.id,
            kind: transaction.kind,
            merchantRaw: transaction.merchantRaw ?? transaction.title,
            merchantNormalized: normalizedMerchant,
            notes: transaction.notes,
            tags: transaction.tags,
            attachments: transaction.attachments,
            isExcludedFromBudget: transaction.isExcludedFromBudget,
            isRecurringCandidate: transaction.isRecurringCandidate || detectRecurringCandidate(for: normalizedMerchant),
            splitGroupId: transaction.splitGroupId,
            splitLabel: transaction.splitLabel
        )
        return applyMerchantRules(to: normalized)
    }

    func upsertMerchantRule(
        matchPattern: String,
        categoryOverride: SpendingCategory?,
        merchantDisplayName: String?,
        recurringHint: Bool
    ) {
        let normalizedPattern = matchPattern.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedPattern.isEmpty else { return }

        let updatedRule = MerchantRule(
            id: merchantRules.first(where: {
                $0.matchPattern.caseInsensitiveCompare(normalizedPattern) == .orderedSame
            })?.id ?? UUID(),
            matchPattern: normalizedPattern,
            categoryOverride: categoryOverride,
            merchantDisplayName: merchantDisplayName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            recurringHint: recurringHint
        )

        if let index = merchantRules.firstIndex(where: {
            $0.matchPattern.caseInsensitiveCompare(normalizedPattern) == .orderedSame
        }) {
            merchantRules[index] = updatedRule
        } else {
            merchantRules.append(updatedRule)
        }

        reapplyMerchantRules()
    }

    func reapplyMerchantRules() {
        groups = groups.map { group in
            SpendingTransactionGroup(
                id: group.id,
                title: group.title,
                transactions: group.transactions.map { normalizeAndApplyRules(to: $0) }
            )
        }
    }

    func detectRecurringCandidate(for merchant: String) -> Bool {
        let recurringMatches = allTransactions.filter {
            ($0.merchantNormalized ?? normalizeMerchant($0.title)) == merchant
        }
        return recurringMatches.count >= 2
    }

    func detectRecurringCandidates() -> [String] {
        Dictionary(grouping: allTransactions) {
            $0.merchantNormalized ?? normalizeMerchant($0.title)
        }
        .filter { _, txns in txns.count >= 2 }
        .keys
        .sorted()
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

    static func resolvedDateForUI(_ title: String, now: Date = Date()) -> Date? {
        resolvedDate(forGroupTitle: title, now: now)
    }

    func isGroupInToday(_ group: SpendingTransactionGroup, now: Date = Date()) -> Bool {
        let today = Calendar.current.startOfDay(for: now)
        guard let groupDate = Self.resolvedDate(forGroupTitle: group.title, now: now) else {
            return group.title == "Today"
        }
        return Calendar.current.isDate(Calendar.current.startOfDay(for: groupDate), inSameDayAs: today)
    }

    var todayGroups: [SpendingTransactionGroup] {
        groups.filter { isGroupInToday($0) }
    }

    var todayTransactions: [SpendingTransaction] {
        todayGroups.flatMap(\.transactions)
    }

    @discardableResult
    func removeTransaction(id: UUID) -> Bool {
        for groupIndex in groups.indices {
            if let txIndex = groups[groupIndex].transactions.firstIndex(where: { $0.id == id }) {
                var updatedTransactions = groups[groupIndex].transactions
                updatedTransactions.remove(at: txIndex)

                if updatedTransactions.isEmpty {
                    groups.remove(at: groupIndex)
                } else {
                    groups[groupIndex] = SpendingTransactionGroup(
                        id: groups[groupIndex].id,
                        title: groups[groupIndex].title,
                        transactions: updatedTransactions
                    )
                }

                return true
            }
        }

        return false
    }

    @discardableResult
    func removeSplitGroup(id: UUID) -> Int {
        var removedCount = 0
        for groupIndex in groups.indices.reversed() {
            let remaining = groups[groupIndex].transactions.filter { $0.splitGroupId != id }
            removedCount += groups[groupIndex].transactions.count - remaining.count

            if remaining.isEmpty {
                groups.remove(at: groupIndex)
            } else if remaining.count != groups[groupIndex].transactions.count {
                groups[groupIndex] = SpendingTransactionGroup(
                    id: groups[groupIndex].id,
                    title: groups[groupIndex].title,
                    transactions: remaining
                )
            }
        }
        return removedCount
    }

    func addTransaction(_ transaction: SpendingTransaction, on date: Date) {
        let dayLabel = Self.dayLabel(for: date)

        if let index = groups.firstIndex(where: { $0.title == dayLabel }) {
            var updated = groups[index].transactions
            updated.insert(normalizeAndApplyRules(to: transaction), at: 0)
            groups[index] = SpendingTransactionGroup(
                id: groups[index].id,
                title: groups[index].title,
                transactions: updated
            )
            return
        }

        let insertIndex = groups.firstIndex(where: { group in
            guard group.title != "Today" && group.title != "Yesterday" else { return false }
            if let groupDate = Self.resolvedDate(forGroupTitle: group.title, now: date) {
                return groupDate < date
            }
            return false
        }) ?? groups.endIndex

        groups.insert(
            SpendingTransactionGroup(
                title: dayLabel,
                transactions: [normalizeAndApplyRules(to: transaction)]
            ),
            at: insertIndex
        )
    }

    func updateTransaction(
        _ transaction: SpendingTransaction,
        originalTransactionId: UUID,
        originalGroupTitle: String,
        originalGroupDate: Date,
        newDate: Date
    ) {
        let newDayLabel: String
        if Calendar.current.isDate(newDate, inSameDayAs: originalGroupDate) {
            newDayLabel = originalGroupTitle
        } else {
            newDayLabel = Self.dayLabel(for: newDate)
        }

        let originalGroupIndex = groups.firstIndex(where: { $0.title == originalGroupTitle })
        let originalInsertIndex = originalGroupIndex.flatMap { groupIndex in
            groups[groupIndex].transactions.firstIndex(where: { $0.id == originalTransactionId })
        } ?? 0

        _ = removeTransaction(id: originalTransactionId)

        let normalized = normalizeAndApplyRules(to: transaction)
        if let existingIndex = groups.firstIndex(where: { $0.title == newDayLabel }) {
            var txns = groups[existingIndex].transactions
            let insertAt = newDayLabel == originalGroupTitle ? min(originalInsertIndex, txns.count) : 0
            txns.insert(normalized, at: insertAt)
            groups[existingIndex] = SpendingTransactionGroup(
                id: groups[existingIndex].id,
                title: groups[existingIndex].title,
                transactions: txns
            )
        } else {
            let insertIndex = groups.firstIndex(where: { group in
                guard group.title != "Today" && group.title != "Yesterday" else { return false }
                if let groupDate = Self.resolvedDate(forGroupTitle: group.title, now: newDate) {
                    return groupDate < newDate
                }
                return false
            }) ?? groups.endIndex

            groups.insert(
                SpendingTransactionGroup(title: newDayLabel, transactions: [normalized]),
                at: insertIndex
            )
        }
    }

    func replaceTransactionWithSplit(
        original transaction: SpendingTransaction,
        originalGroupTitle: String,
        originalGroupDate: Date,
        newDate: Date,
        merchantName: String,
        kind: TransactionKind,
        accountId: UUID?,
        isImpulse: Bool,
        allocations: [SplitTransactionAllocation],
        notes: String? = nil
    ) {
        let rawTitle = merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? transaction.title
            : merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let splitGroupId = transaction.splitGroupId ?? UUID()

        if let splitGroupId = transaction.splitGroupId {
            _ = removeSplitGroup(id: splitGroupId)
        } else {
            _ = removeTransaction(id: transaction.id)
        }

        for allocation in allocations where allocation.amount > 0 {
            let splitTitle = allocation.label.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = splitTitle.isEmpty ? rawTitle : "\(rawTitle) • \(splitTitle)"

            let splitTransaction = normalizeAndApplyRules(to: SpendingTransaction(
                icon: allocation.category.icon,
                title: title,
                subtitle: allocation.category.rawValue,
                time: transaction.time,
                amount: kind.signedAmountString(for: allocation.amount),
                isImpulse: kind.usesImpulseFlag ? isImpulse : false,
                iconColor: allocation.category.color,
                bgColor: allocation.category.color.opacity(0.1),
                borderColor: allocation.category.color.opacity(0.2),
                category: allocation.category,
                accountId: accountId ?? defaultSpendingAccount?.id,
                kind: kind,
                merchantRaw: rawTitle,
                merchantNormalized: normalizeMerchant(rawTitle),
                notes: notes,
                tags: Array(Set(transaction.tags + ["split"])).sorted(),
                attachments: transaction.attachments,
                isExcludedFromBudget: transaction.isExcludedFromBudget,
                isRecurringCandidate: transaction.isRecurringCandidate,
                splitGroupId: splitGroupId,
                splitLabel: allocation.label.nilIfEmpty
            ))

            addTransaction(splitTransaction, on: newDate)
        }
    }

    func addSplitTransactions(
        merchantName: String,
        kind: TransactionKind,
        accountId: UUID?,
        isImpulse: Bool,
        date: Date,
        time: String,
        allocations: [SplitTransactionAllocation],
        notes: String? = nil
    ) {
        let rawTitle = merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let splitGroupId = UUID()

        for allocation in allocations where allocation.amount > 0 {
            let splitTitle = allocation.label.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = splitTitle.isEmpty ? rawTitle : "\(rawTitle) • \(splitTitle)"

            let splitTransaction = normalizeAndApplyRules(to: SpendingTransaction(
                icon: allocation.category.icon,
                title: title,
                subtitle: allocation.category.rawValue,
                time: time,
                amount: kind.signedAmountString(for: allocation.amount),
                isImpulse: kind.usesImpulseFlag ? isImpulse : false,
                iconColor: allocation.category.color,
                bgColor: allocation.category.color.opacity(0.1),
                borderColor: allocation.category.color.opacity(0.2),
                category: allocation.category,
                accountId: accountId ?? defaultSpendingAccount?.id,
                kind: kind,
                merchantRaw: rawTitle,
                merchantNormalized: normalizeMerchant(rawTitle),
                notes: notes,
                tags: ["split"],
                attachments: [],
                splitGroupId: splitGroupId,
                splitLabel: allocation.label.nilIfEmpty
            ))

            addTransaction(splitTransaction, on: date)
        }
    }

    func splitTransactions(for splitGroupId: UUID) -> [SpendingTransaction] {
        allTransactions.filter { $0.splitGroupId == splitGroupId }
    }

    func transaction(for id: UUID) -> SpendingTransaction? {
        allTransactions.first(where: { $0.id == id })
    }

    func updateTransactionDetails(
        transactionId: UUID,
        notes: String?,
        tags: [String],
        isImpulse: Bool,
        attachments: [TransactionAttachment]
    ) {
        guard let transaction = transaction(for: transactionId) else { return }

        let normalizedNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        let normalizedTags = Array(
            Set(
                tags
                    .map {
                        $0
                            .replacingOccurrences(of: "#", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .filter { !$0.isEmpty }
            )
        ).sorted()

        let targetIds: Set<UUID>
        if let splitGroupId = transaction.splitGroupId {
            targetIds = Set(splitTransactions(for: splitGroupId).map(\.id))
        } else {
            targetIds = [transactionId]
        }

        for groupIndex in groups.indices {
            var updatedTransactions = groups[groupIndex].transactions
            var didChange = false

            for txIndex in updatedTransactions.indices where targetIds.contains(updatedTransactions[txIndex].id) {
                let existing = updatedTransactions[txIndex]
                updatedTransactions[txIndex] = SpendingTransaction(
                    id: existing.id,
                    icon: existing.icon,
                    title: existing.title,
                    subtitle: existing.subtitle,
                    time: existing.time,
                    amount: existing.amount,
                    isImpulse: existing.kind.usesImpulseFlag ? isImpulse : false,
                    iconColor: existing.iconColor,
                    bgColor: existing.bgColor,
                    borderColor: existing.borderColor,
                    category: existing.category,
                    accountId: existing.accountId,
                    kind: existing.kind,
                    merchantRaw: existing.merchantRaw,
                    merchantNormalized: existing.merchantNormalized,
                    notes: normalizedNotes,
                    tags: normalizedTags,
                    attachments: attachments,
                    isExcludedFromBudget: existing.isExcludedFromBudget,
                    isRecurringCandidate: existing.isRecurringCandidate,
                    splitGroupId: existing.splitGroupId,
                    splitLabel: existing.splitLabel
                )
                didChange = true
            }

            if didChange {
                groups[groupIndex] = SpendingTransactionGroup(
                    id: groups[groupIndex].id,
                    title: groups[groupIndex].title,
                    transactions: updatedTransactions
                )
            }
        }
    }

    func isDuplicateTransaction(
        date: Date,
        merchant: String,
        signedAmount: Double,
        accountId: UUID?
    ) -> Bool {
        let normalizedMerchant = normalizeMerchant(merchant)
        let targetDay = Calendar.current.startOfDay(for: date)

        return allTransactions.contains { transaction in
            let sameAccount = transaction.accountId == accountId
            let sameMerchant = (transaction.merchantNormalized ?? normalizeMerchant(transaction.title)) == normalizedMerchant
            let sameAmount = abs(transaction.amountSignedValue - signedAmount) < 0.01
            let sameDay = Self.resolvedDate(forGroupTitle: groupTitle(for: transaction.id), now: date)
                .map { Calendar.current.isDate(Calendar.current.startOfDay(for: $0), inSameDayAs: targetDay) } ?? false

            return sameAccount && sameMerchant && sameAmount && sameDay
        }
    }

    func importCSVTransactions(from csv: String, defaultAccountId: UUID? = nil) -> TransactionImportSummary {
        let rows = csv
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard rows.count > 1 else {
            return TransactionImportSummary(importedCount: 0, duplicateCount: 0)
        }

        let headers = parseCSVRow(rows[0]).map { $0.lowercased() }
        var importedCount = 0
        var duplicateCount = 0

        for row in rows.dropFirst() {
            let values = parseCSVRow(row)
            guard values.count == headers.count else { continue }
            let record = Dictionary(uniqueKeysWithValues: zip(headers, values))

            guard
                let dateString = record["date"] ?? record["transaction date"] ?? record["posted date"],
                let merchant = record["merchant"] ?? record["description"] ?? record["name"],
                let amountString = record["amount"]
            else {
                continue
            }

            guard let parsedDate = parseImportDate(dateString) else { continue }
            let cleanedAmount = amountString
                .replacingOccurrences(of: "$", with: "")
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard let rawAmount = Double(cleanedAmount) else { continue }

            let kind = parseImportKind(record["type"], amount: rawAmount)
            let absoluteAmount = abs(rawAmount)
            let signedAmount = kind.summaryAmount(absoluteAmount)
            let normalizedMerchant = normalizeMerchant(merchant)
            let category = parseImportCategory(record["category"])
            let accountId = accountIdForImportedRecord(record["account"], defaultAccountId: defaultAccountId)

            if isDuplicateTransaction(
                date: parsedDate,
                merchant: normalizedMerchant,
                signedAmount: signedAmount,
                accountId: accountId
            ) {
                duplicateCount += 1
                continue
            }

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let transaction = normalizeAndApplyRules(to: SpendingTransaction(
                icon: category.icon,
                title: merchant,
                subtitle: category.rawValue,
                time: timeFormatter.string(from: parsedDate),
                amount: kind.signedAmountString(for: absoluteAmount),
                isImpulse: false,
                iconColor: category.color,
                bgColor: category.color.opacity(0.1),
                borderColor: category.color.opacity(0.2),
                category: category,
                accountId: accountId,
                kind: kind,
                merchantRaw: merchant,
                merchantNormalized: normalizedMerchant,
                tags: ["imported"]
            ))

            addTransaction(transaction, on: parsedDate)
            importedCount += 1
        }

        return TransactionImportSummary(importedCount: importedCount, duplicateCount: duplicateCount)
    }

    private func parseCSVRow(_ row: String) -> [String] {
        var result: [String] = []
        var current = ""
        var isInsideQuotes = false

        for character in row {
            switch character {
            case "\"":
                isInsideQuotes.toggle()
            case "," where !isInsideQuotes:
                result.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
                current = ""
            default:
                current.append(character)
            }
        }

        result.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
        return result
    }

    private func parseImportDate(_ value: String) -> Date? {
        let formats = ["yyyy-MM-dd", "MM/dd/yyyy", "M/d/yyyy", "MMM d, yyyy"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: value.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return date
            }
        }
        return nil
    }

    private func parseImportKind(_ rawValue: String?, amount: Double) -> TransactionKind {
        let normalized = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        if normalized.contains("income") || normalized.contains("deposit") {
            return .income
        }
        if normalized.contains("refund") || normalized.contains("credit") {
            return .refund
        }
        if normalized.contains("transfer") {
            return .transfer
        }
        return .spending
    }

    private func parseImportCategory(_ rawValue: String?) -> SpendingCategory {
        guard let normalized = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !normalized.isEmpty else {
            return .other
        }
        return SpendingCategory.allCases.first(where: { $0.rawValue.lowercased() == normalized }) ?? .other
    }

    private func accountIdForImportedRecord(_ rawValue: String?, defaultAccountId: UUID?) -> UUID? {
        guard let name = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return defaultAccountId ?? self.defaultSpendingAccount?.id
        }
        return visibleAccounts.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame })?.id
            ?? defaultAccountId
            ?? self.defaultSpendingAccount?.id
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

    func updateRecurringStatus(_ id: UUID, status: RecurringStatus) {
        guard let index = subscriptions.firstIndex(where: { $0.id == id }) else { return }
        let existing = subscriptions[index]
        subscriptions[index] = RecurringSubscription(
            id: existing.id,
            name: existing.name,
            plan: existing.plan,
            price: existing.price,
            iconName: existing.iconName,
            iconColor: existing.iconColor,
            bgColor: existing.bgColor,
            nextBilling: existing.nextBilling,
            frequencyDays: existing.frequencyDays,
            frequencyKey: existing.frequencyKey,
            nextBillingEpoch: existing.nextBillingEpoch,
            merchantMatchPattern: existing.merchantMatchPattern,
            expectedAmountMin: existing.expectedAmountMin,
            expectedAmountMax: existing.expectedAmountMax,
            linkedTransactionIds: existing.linkedTransactionIds,
            status: status
        )
    }

    func addManualForecastItem(
        title: String,
        amount: Double,
        date: Date,
        kind: ManualForecastItem.Kind,
        note: String? = nil
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, amount > 0 else { return }
        manualForecastItems.append(
            ManualForecastItem(
                title: trimmedTitle,
                amount: amount,
                date: date,
                kind: kind,
                note: note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            )
        )
        manualForecastItems.sort { $0.date < $1.date }
    }

    func deleteManualForecastItem(id: UUID) {
        manualForecastItems.removeAll { $0.id == id }
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
            guard updated[index].status == .active else { continue }
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
                    nextBillingEpoch: nextDate.timeIntervalSince1970,
                    merchantMatchPattern: updated[index].merchantMatchPattern,
                    expectedAmountMin: updated[index].expectedAmountMin,
                    expectedAmountMax: updated[index].expectedAmountMax,
                    linkedTransactionIds: updated[index].linkedTransactionIds,
                    status: updated[index].status
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
            category: .subscriptions,
            accountId: defaultSpendingAccount?.id,
            kind: .spending,
            merchantRaw: sub.name,
            merchantNormalized: normalizeMerchant(sub.merchantMatchPattern ?? sub.name),
            tags: ["recurring"],
            isRecurringCandidate: true
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
    var defaultSpendingAccount: Account? {
        accounts.first(where: { $0.id == defaultAccountId })
        ?? accounts.first(where: { $0.type == .checking || $0.type == .savings || $0.type == .cash })
        ?? accounts.first
    }

    func holdings(forAccount accountId: UUID) -> [InvestmentHolding] {
        investmentHoldings
            .filter { $0.accountId == accountId }
            .sorted { lhs, rhs in
                if lhs.marketValue != rhs.marketValue {
                    return lhs.marketValue > rhs.marketValue
                }
                return lhs.symbol < rhs.symbol
            }
    }

    func investmentPerformance(forAccount accountId: UUID? = nil) -> InvestmentPerformanceSummary {
        let scopedHoldings: [InvestmentHolding]
        if let accountId {
            scopedHoldings = holdings(forAccount: accountId)
        } else {
            scopedHoldings = investmentHoldings
        }

        let marketValue = scopedHoldings.reduce(0) { $0 + $1.marketValue }
        let costBasis = scopedHoldings.reduce(0) { $0 + $1.costBasis }
        let gainLoss = marketValue - costBasis
        let gainLossPercent = costBasis == 0 ? 0 : gainLoss / costBasis

        return InvestmentPerformanceSummary(
            marketValue: marketValue,
            costBasis: costBasis,
            gainLoss: gainLoss,
            gainLossPercent: gainLossPercent,
            holdingsCount: scopedHoldings.count
        )
    }

    func portfolioAllocation(forAccount accountId: UUID? = nil) -> [PortfolioAllocationSlice] {
        let scopedHoldings: [InvestmentHolding]
        if let accountId {
            scopedHoldings = holdings(forAccount: accountId)
        } else {
            scopedHoldings = investmentHoldings
        }

        let total = scopedHoldings.reduce(0) { $0 + $1.marketValue }
        guard total > 0 else { return [] }

        let grouped = Dictionary(grouping: scopedHoldings, by: \.assetClass)
        return grouped
            .map { assetClass, holdings in
                let marketValue = holdings.reduce(0) { $0 + $1.marketValue }
                return PortfolioAllocationSlice(
                    assetClass: assetClass,
                    marketValue: marketValue,
                    percentage: marketValue / total
                )
            }
            .sorted { $0.marketValue > $1.marketValue }
    }

    func effectiveBalance(for account: Account) -> Double {
        guard account.type == .investment else { return account.balance }
        let performance = investmentPerformance(forAccount: account.id)
        return performance.holdingsCount > 0 ? performance.marketValue : account.balance
    }

    var investmentAccounts: [Account] {
        visibleAccounts.filter { $0.type == .investment }
    }

    func account(for id: UUID?) -> Account? {
        guard let id else { return nil }
        return accounts.first(where: { $0.id == id })
    }

    func accountName(for id: UUID?) -> String? {
        account(for: id)?.name
    }

    func transactions(forAccount id: UUID?, inMonth date: Date = Date()) -> [SpendingTransaction] {
        transactions(forMonth: date, accountId: id)
    }

    func monthlySpend(forAccount id: UUID?, inMonth date: Date = Date()) -> Double {
        transactions(forAccount: id, inMonth: date)
            .filter { $0.kind == .spending && !$0.isExcludedFromBudget && !excludedCategories.contains($0.category) }
            .reduce(0) { $0 + $1.amountValue }
    }

    func monthlyIncome(forAccount id: UUID?, inMonth date: Date = Date()) -> Double {
        transactions(forAccount: id, inMonth: date)
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amountSignedValue }
    }

    func monthlyNet(forAccount id: UUID?, inMonth date: Date = Date()) -> Double {
        monthlyIncome(forAccount: id, inMonth: date) - monthlySpend(forAccount: id, inMonth: date)
    }

    var visibleAccounts: [Account] {
        accounts.filter { !$0.isHidden }
    }

    var liquidCashBalance: Double {
        visibleAccounts
            .filter { $0.type == .checking || $0.type == .savings || $0.type == .cash }
            .reduce(0) { $0 + effectiveBalance(for: $1) }
    }

    var investedBalance: Double {
        let holdingsBacked = investmentPerformance().marketValue
        if holdingsBacked > 0 {
            return holdingsBacked
        }

        return visibleAccounts
            .filter { $0.type == .investment }
            .reduce(0) { $0 + effectiveBalance(for: $1) }
    }

    var totalDebtBalance: Double {
        visibleAccounts
            .filter { $0.type == .creditCard || $0.type == .loan }
            .reduce(0) { $0 + abs(effectiveBalance(for: $1)) }
    }

    var totalAssetsBalance: Double {
        visibleAccounts
            .filter { effectiveBalance(for: $0) >= 0 }
            .reduce(0) { $0 + effectiveBalance(for: $1) }
    }

    var totalLiabilitiesBalance: Double {
        visibleAccounts
            .filter { effectiveBalance(for: $0) < 0 }
            .reduce(0) { $0 + abs(effectiveBalance(for: $1)) }
    }

    var netWorthBalance: Double {
        totalAssetsBalance - totalLiabilitiesBalance
    }

    var allTransactions: [SpendingTransaction] {
        groups.flatMap { $0.transactions }
    }

    var budgetableTransactions: [SpendingTransaction] {
        allTransactions.filter {
            $0.kind == .spending && !$0.isExcludedFromBudget && !excludedCategories.contains($0.category)
        }
    }

    var incomeTransactions: [SpendingTransaction] {
        allTransactions.filter { $0.kind == .income }
    }

    var transferTransactions: [SpendingTransaction] {
        allTransactions.filter { $0.kind == .transfer }
    }

    var excludedCategories: Set<SpendingCategory> {
        Set(budgetCategories.filter(\.isExcluded).map(\.category))
    }

    func transactions(
        forMonth date: Date = Date(),
        category: SpendingCategory? = nil,
        accountId: UUID? = nil,
        kind: TransactionKind? = nil
    ) -> [SpendingTransaction] {
        allTransactions.filter { transaction in
            let matchesMonth = Self.resolvedDate(forGroupTitle: groupTitle(for: transaction.id), now: date)
                .map { Calendar.current.isDate($0, equalTo: date, toGranularity: .month) } ?? false
            let matchesCategory = category.map { transaction.category == $0 } ?? true
            let matchesAccount = accountId.map { transaction.accountId == $0 } ?? true
            let matchesKind = kind.map { transaction.kind == $0 } ?? true
            return matchesMonth && matchesCategory && matchesAccount && matchesKind
        }
    }

    private func groupTitle(for transactionId: UUID) -> String {
        groups.first(where: { group in
            group.transactions.contains(where: { $0.id == transactionId })
        })?.title ?? "Today"
    }

    private func transactionDate(for transaction: SpendingTransaction, referenceDate: Date = Date()) -> Date? {
        Self.resolvedDate(forGroupTitle: groupTitle(for: transaction.id), now: referenceDate)
    }

    func groupTitle(forTransactionId transactionId: UUID) -> String? {
        groups.first(where: { group in
            group.transactions.contains(where: { $0.id == transactionId })
        })?.title
    }

    func date(forTransactionId transactionId: UUID, referenceDate: Date = Date()) -> Date? {
        guard let title = groupTitle(forTransactionId: transactionId) else { return nil }
        return Self.resolvedDate(forGroupTitle: title, now: referenceDate)
    }

    func merchantHistory(for transaction: SpendingTransaction, limit: Int = 8) -> [SpendingTransaction] {
        let merchantKey = transaction.merchantNormalized ?? normalizeMerchant(transaction.merchantRaw ?? transaction.title)
        return allTransactions
            .filter { candidate in
                candidate.id != transaction.id &&
                (candidate.merchantNormalized ?? normalizeMerchant(candidate.merchantRaw ?? candidate.title)) == merchantKey
            }
            .sorted {
                let lhs = date(forTransactionId: $0.id) ?? .distantPast
                let rhs = date(forTransactionId: $1.id) ?? .distantPast
                return lhs > rhs
            }
            .prefix(limit)
            .map { $0 }
    }

    var totalSpent: Double {
        budgetableTransactions.reduce(0) { $0 + $1.amountValue }
    }

    var transactionCount: Int {
        budgetableTransactions.count
    }

    var monthToDateTransactions: [SpendingTransaction] {
        transactions(forMonth: Date())
    }

    var monthlySpent: Double {
        monthToDateTransactions
            .filter { $0.kind == .spending && !$0.isExcludedFromBudget && !excludedCategories.contains($0.category) }
            .reduce(0) { $0 + $1.amountValue }
    }

    var monthlyIncome: Double {
        monthToDateTransactions
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amountSignedValue }
    }

    var monthlyNet: Double {
        monthlyIncome - monthlySpent
    }

    func spendingByCategory(forMonth date: Date = Date()) -> [SpendingCategory: Double] {
        transactions(forMonth: date).reduce(into: [SpendingCategory: Double]()) { result, transaction in
            guard transaction.kind == .spending else { return }
            guard !transaction.isExcludedFromBudget else { return }
            guard !excludedCategories.contains(transaction.category) else { return }
            result[transaction.category, default: 0] += transaction.amountValue
        }
    }

    func monthToDateComparison(referenceDate: Date = Date()) -> MonthlyComparison {
        let calendar = Calendar.current
        let previousDate = calendar.date(byAdding: .month, value: -1, to: referenceDate) ?? referenceDate
        let currentTotal = spendingByCategory(forMonth: referenceDate).values.reduce(0, +)
        let previousTotal = spendingByCategory(forMonth: previousDate).values.reduce(0, +)
        return MonthlyComparison(current: currentTotal, previous: previousTotal)
    }

    var upcomingRecurringTotal: Double {
        let calendar = Calendar.current
        let now = Date()
        return subscriptions.reduce(0) { running, subscription in
            guard subscription.status == .active else { return running }
            guard let epoch = subscription.nextBillingEpoch else { return running }
            let nextDate = Date(timeIntervalSince1970: epoch)
            guard calendar.isDate(nextDate, equalTo: now, toGranularity: .month) || nextDate > now else {
                return running
            }
            return running + subscription.price
        }
    }

    var cashFlowForecast: CashFlowForecast {
        cashFlowForecast(referenceDate: Date(), horizonDays: 30)
    }

    func cashFlowForecast(referenceDate: Date = Date(), horizonDays: Int = 30) -> CashFlowForecast {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: referenceDate)
        let monthEnd = calendar.dateInterval(of: .month, for: referenceDate)?.end ?? referenceDate
        let horizonEnd = calendar.date(byAdding: .day, value: horizonDays, to: startOfToday) ?? referenceDate
        let eventCutoff = min(monthEnd, horizonEnd)

        let billEvents: [CashFlowForecastEvent] = subscriptions.compactMap { subscription in
            guard subscription.status == .active else { return nil }
            guard let epoch = subscription.nextBillingEpoch else { return nil }
            let date = Date(timeIntervalSince1970: epoch)
            let day = calendar.startOfDay(for: date)
            guard day >= startOfToday && day <= eventCutoff else { return nil }
            return CashFlowForecastEvent(
                id: subscription.id,
                title: subscription.name,
                date: day,
                amount: subscription.price,
                kind: .bill,
                subtitle: subscription.plan ?? "Recurring bill"
            )
        }

        let manualEvents: [CashFlowForecastEvent] = manualForecastItems.compactMap { item in
            let day = calendar.startOfDay(for: item.date)
            guard day >= startOfToday && day <= eventCutoff else { return nil }
            return CashFlowForecastEvent(
                id: item.id,
                title: item.title,
                date: day,
                amount: item.amount,
                kind: item.kind == .income ? .income : .bill,
                subtitle: item.note ?? (item.kind == .income ? "Manual income" : "Manual bill")
            )
        }

        let incomeEvents = inferredIncomeForecastEvents(referenceDate: referenceDate, cutoff: eventCutoff)
        let events = (billEvents + manualEvents + incomeEvents).sorted { lhs, rhs in
            if lhs.date != rhs.date { return lhs.date < rhs.date }
            if lhs.kind != rhs.kind { return lhs.kind == .income }
            return lhs.title < rhs.title
        }

        let expectedIncome = events.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
        let expectedBills = events.filter { $0.kind == .bill }.reduce(0) { $0 + $1.amount }
        let projectedEndOfMonthCash = liquidCashBalance + expectedIncome - expectedBills

        return CashFlowForecast(
            startingCash: liquidCashBalance,
            events: events,
            projectedEndOfMonthCash: projectedEndOfMonthCash,
            expectedIncome: expectedIncome,
            expectedBills: expectedBills
        )
    }

    private func inferredIncomeForecastEvents(referenceDate: Date, cutoff: Date) -> [CashFlowForecastEvent] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: incomeTransactions) {
            ($0.merchantNormalized ?? normalizeMerchant($0.title)).lowercased()
        }

        return groups.compactMap { merchant, transactions in
            let datedTransactions = transactions.compactMap { transaction -> (Date, SpendingTransaction)? in
                guard let date = transactionDate(for: transaction, referenceDate: referenceDate) else { return nil }
                return (calendar.startOfDay(for: date), transaction)
            }
            .sorted { $0.0 < $1.0 }

            guard datedTransactions.count >= 2 else { return nil }

            let intervals = zip(datedTransactions, datedTransactions.dropFirst()).compactMap { lhs, rhs in
                let days = calendar.dateComponents([.day], from: lhs.0, to: rhs.0).day ?? 0
                return days > 0 ? days : nil
            }

            guard !intervals.isEmpty else { return nil }
            let averageInterval = Int((Double(intervals.reduce(0, +)) / Double(intervals.count)).rounded())
            guard averageInterval >= 7 && averageInterval <= 35 else { return nil }

            guard let last = datedTransactions.last else { return nil }
            guard let nextDate = calendar.date(byAdding: .day, value: averageInterval, to: last.0) else { return nil }
            let nextDay = calendar.startOfDay(for: nextDate)
            let startOfToday = calendar.startOfDay(for: referenceDate)
            guard nextDay >= startOfToday && nextDay <= cutoff else { return nil }

            let averageAmount = datedTransactions.reduce(0.0) { $0 + abs($1.1.amountSignedValue) } / Double(datedTransactions.count)
            let title = last.1.title.isEmpty ? merchant.capitalized : last.1.title

            return CashFlowForecastEvent(
                id: UUID(),
                title: title,
                date: nextDay,
                amount: averageAmount,
                kind: .income,
                subtitle: "Expected income"
            )
        }
    }

    var totalMonthlyBudget: Double {
        let categoryTotal = budgetCategories
            .filter { !$0.isExcluded }
            .reduce(0) { $0 + $1.monthlyBudget }
        return derivedMonthlyBudget > 0 ? derivedMonthlyBudget : categoryTotal
    }

    var safeToSpendThisMonth: Double {
        guard liquidCashBalance > 0 else { return 0 }

        let remainingBudget = max(totalMonthlyBudget - monthlySpent, 0)
        let cashConstrainedCapacity: Double

        cashConstrainedCapacity = max(cashFlowForecast.projectedEndOfMonthCash, 0)

        return min(remainingBudget, cashConstrainedCapacity)
    }

    var totalGoalTarget: Double {
        savingsGoals.reduce(0) { $0 + $1.targetAmount }
    }

    var totalGoalProgress: Double {
        savingsGoals.reduce(0) { $0 + $1.currentAmount }
    }

    var categoryTotals: [CategoryData] {
        spendingByCategory()
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
        todayTransactions.reduce(0) { $0 + $1.amountValue }
    }

    var dailyRemaining: Double {
        let remainingBudget = max(dailyBudget - dailySpent, 0)

        if liquidCashBalance > 0 {
            return min(remainingBudget, max(liquidCashBalance - dailySpent, 0))
        }

        return remainingBudget
    }

    func upsertAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            accounts.insert(account, at: 0)
        }
        saveAccounts()
    }

    func deleteAccount(id: UUID) {
        accounts.removeAll { $0.id == id }
        investmentHoldings.removeAll { $0.accountId == id }
        saveAccounts()
    }

    func upsertInvestmentHolding(_ holding: InvestmentHolding) {
        if let index = investmentHoldings.firstIndex(where: { $0.id == holding.id }) {
            investmentHoldings[index] = holding
        } else {
            investmentHoldings.append(holding)
        }
    }

    func deleteInvestmentHolding(id: UUID) {
        investmentHoldings.removeAll { $0.id == id }
    }

    func normalizedBalance(for type: AccountType, enteredBalance: Double) -> Double {
        switch type {
        case .creditCard, .loan:
            return -abs(enteredBalance)
        case .checking, .savings, .investment, .cash:
            return enteredBalance
        }
    }

    func activateMode(_ mode: AppDataMode) {
        appMode = mode
        UserDefaults.standard.set(true, forKey: Self.hasCompletedOnboardingKey)

        switch mode {
        case .demo:
            loadDemoMode()
        case .real:
            loadRealMode()
        }
    }

    private func loadDemoMode() {
        budgetMode = .monthly
        budgetBaseValue = 4650
        accounts = Self.sampleAccounts
        investmentHoldings = Self.sampleInvestmentHoldings
        budgetCategories = Self.sampleBudgetCategories
        savingsGoals = Self.sampleSavingsGoals
        merchantRules = Self.sampleMerchantRules
        groups = Self.sampleGroups
        subscriptions = Self.sampleSubscriptions
        manualForecastItems = Self.sampleManualForecastItems
    }

    private func loadRealMode() {
        budgetMode = .daily
        budgetBaseValue = 0
        accounts = []
        investmentHoldings = []
        budgetCategories = Self.emptyBudgetCategories
        savingsGoals = []
        merchantRules = Self.sampleMerchantRules
        groups = []
        subscriptions = []
        manualForecastItems = []
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

    private static let demoCheckingId = UUID(uuidString: "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa") ?? UUID()
    private static let demoSavingsId = UUID(uuidString: "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb") ?? UUID()
    private static let demoCreditId = UUID(uuidString: "cccccccc-cccc-cccc-cccc-cccccccccccc") ?? UUID()
    private static let demoInvestmentId = UUID(uuidString: "dddddddd-dddd-dddd-dddd-dddddddddddd") ?? UUID()

    static var sampleAccounts: [Account] {
        [
            Account(
                id: demoCheckingId,
                name: "Everyday Checking",
                type: .checking,
                institution: "Chase",
                balance: 4215.48
            ),
            Account(
                id: demoSavingsId,
                name: "Rainy Day Savings",
                type: .savings,
                institution: "Ally",
                balance: 12840.12
            ),
            Account(
                id: demoCreditId,
                name: "Freedom Unlimited",
                type: .creditCard,
                institution: "Chase",
                balance: -874.33
            ),
            Account(
                id: demoInvestmentId,
                name: "Brokerage",
                type: .investment,
                institution: "Fidelity",
                balance: 0
            ),
        ]
    }

    static var emptyBudgetCategories: [BudgetCategory] = [
        BudgetCategory(category: .dining, monthlyBudget: 0),
        BudgetCategory(category: .transport, monthlyBudget: 0),
        BudgetCategory(category: .shopping, monthlyBudget: 0),
        BudgetCategory(category: .entertainment, monthlyBudget: 0),
        BudgetCategory(category: .groceries, monthlyBudget: 0),
        BudgetCategory(category: .utilities, monthlyBudget: 0),
        BudgetCategory(category: .fitness, monthlyBudget: 0),
        BudgetCategory(category: .subscriptions, monthlyBudget: 0),
        BudgetCategory(category: .lifestyle, monthlyBudget: 0),
        BudgetCategory(category: .other, monthlyBudget: 0),
    ]

    static var sampleBudgetCategories: [BudgetCategory] = [
        BudgetCategory(category: .dining, monthlyBudget: 700),
        BudgetCategory(category: .transport, monthlyBudget: 420),
        BudgetCategory(category: .shopping, monthlyBudget: 650),
        BudgetCategory(category: .entertainment, monthlyBudget: 240),
        BudgetCategory(category: .groceries, monthlyBudget: 820),
        BudgetCategory(category: .utilities, monthlyBudget: 310),
        BudgetCategory(category: .fitness, monthlyBudget: 160),
        BudgetCategory(category: .subscriptions, monthlyBudget: 95),
        BudgetCategory(category: .lifestyle, monthlyBudget: 540),
        BudgetCategory(category: .other, monthlyBudget: 715),
    ]

    static var sampleMerchantRules: [MerchantRule] = [
        MerchantRule(matchPattern: "spotify", categoryOverride: .subscriptions, merchantDisplayName: "Spotify", recurringHint: true),
        MerchantRule(matchPattern: "netflix", categoryOverride: .subscriptions, merchantDisplayName: "Netflix", recurringHint: true),
        MerchantRule(matchPattern: "uber", categoryOverride: .transport, merchantDisplayName: "Uber", recurringHint: false),
        MerchantRule(matchPattern: "trader joe", categoryOverride: .groceries, merchantDisplayName: "Trader Joe's", recurringHint: false),
        MerchantRule(matchPattern: "blue bottle", categoryOverride: .lifestyle, merchantDisplayName: "Blue Bottle", recurringHint: false),
    ]

    static var sampleSavingsGoals: [SavingsGoal] {
        [
            SavingsGoal(
                name: "Tokyo Trip",
                targetAmount: 6000,
                currentAmount: 2450,
                linkedAccountId: demoSavingsId
            ),
            SavingsGoal(
                name: "Emergency Fund",
                targetAmount: 15000,
                currentAmount: 12840.12,
                linkedAccountId: demoSavingsId
            ),
        ]
    }

    static var sampleGroups: [SpendingTransactionGroup] {
        generateInitialGroups()
    }

    static var sampleInvestmentHoldings: [InvestmentHolding] {
        [
            InvestmentHolding(
                accountId: demoInvestmentId,
                symbol: "VOO",
                name: "Vanguard S&P 500 ETF",
                assetClass: .etf,
                shares: 18.2,
                averageCostPerShare: 470.15,
                currentPricePerShare: 505.40
            ),
            InvestmentHolding(
                accountId: demoInvestmentId,
                symbol: "AAPL",
                name: "Apple",
                assetClass: .stock,
                shares: 11,
                averageCostPerShare: 181.22,
                currentPricePerShare: 196.85
            ),
            InvestmentHolding(
                accountId: demoInvestmentId,
                symbol: "VXUS",
                name: "Vanguard Total International Stock ETF",
                assetClass: .etf,
                shares: 24.4,
                averageCostPerShare: 58.32,
                currentPricePerShare: 62.14
            ),
        ]
    }

    static var sampleManualForecastItems: [ManualForecastItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return [
            ManualForecastItem(
                title: "Freelance Deposit",
                amount: 1200,
                date: calendar.date(byAdding: .day, value: 4, to: today) ?? today,
                kind: .income,
                note: "Design retainer"
            ),
            ManualForecastItem(
                title: "Quarterly Insurance",
                amount: 280,
                date: calendar.date(byAdding: .day, value: 9, to: today) ?? today,
                kind: .bill,
                note: "Car insurance"
            ),
        ]
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
                    category: template.category,
                    accountId: demoCheckingId,
                    kind: .spending,
                    merchantRaw: template.title,
                    merchantNormalized: template.title,
                    tags: useAutoPay ? ["recurring"] : [],
                    isRecurringCandidate: useAutoPay
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
    static var sampleSubscriptions: [RecurringSubscription] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dates = [5, 8, 12, 16, 21, 25].map { calendar.date(byAdding: .day, value: $0, to: today) ?? today }

        return [
            RecurringSubscription(name: "Netflix", plan: "Premium Plan", price: 19.99, iconName: "netflix", iconColor: .white, bgColor: .black, nextBilling: billingDisplayString(for: dates[0]), frequencyKey: "monthly", nextBillingEpoch: dates[0].timeIntervalSince1970, merchantMatchPattern: "Netflix", expectedAmountMin: 18.99, expectedAmountMax: 21.99),
            RecurringSubscription(name: "Spotify", plan: nil, price: 10.99, iconName: "spotify", iconColor: .black, bgColor: Color(red: 0.11, green: 0.72, blue: 0.33), nextBilling: billingDisplayString(for: dates[1]), frequencyKey: "monthly", nextBillingEpoch: dates[1].timeIntervalSince1970, merchantMatchPattern: "Spotify", expectedAmountMin: 9.99, expectedAmountMax: 12.99),
            RecurringSubscription(name: "Notion", plan: nil, price: 8.00, iconName: "notion", iconColor: .black, bgColor: .white, nextBilling: billingDisplayString(for: dates[2]), frequencyKey: "monthly", nextBillingEpoch: dates[2].timeIntervalSince1970, merchantMatchPattern: "Notion", expectedAmountMin: 8.00, expectedAmountMax: 8.00),
            RecurringSubscription(name: "YouTube", plan: "Premium", price: 13.99, iconName: "youtube", iconColor: .white, bgColor: Color(red: 1.0, green: 0.0, blue: 0.0), nextBilling: billingDisplayString(for: dates[3]), frequencyKey: "monthly", nextBillingEpoch: dates[3].timeIntervalSince1970, merchantMatchPattern: "YouTube", expectedAmountMin: 12.99, expectedAmountMax: 14.99),
            RecurringSubscription(name: "Equinox", plan: "Monthly", price: 95.00, iconName: "dumbbell.fill", iconColor: .white, bgColor: Color(red: 0.1, green: 0.1, blue: 0.1), nextBilling: billingDisplayString(for: dates[4]), frequencyKey: "monthly", nextBillingEpoch: dates[4].timeIntervalSince1970, merchantMatchPattern: "Equinox", expectedAmountMin: 95.00, expectedAmountMax: 95.00),
            RecurringSubscription(name: "iCloud", plan: "200GB", price: 2.99, iconName: "icloud.fill", iconColor: .white, bgColor: Color(red: 0.2, green: 0.5, blue: 1.0), nextBilling: billingDisplayString(for: dates[5]), frequencyKey: "monthly", nextBillingEpoch: dates[5].timeIntervalSince1970, merchantMatchPattern: "iCloud", expectedAmountMin: 2.99, expectedAmountMax: 2.99),
        ]
    }
}
