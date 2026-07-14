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
class TransactionData: AppSessionDataStore, TransactionMutationBacking, SpendingDataStore, RecurringDataStore, BankDataStore, PlatformDataStore {
    static let shared = TransactionData()

    static let appModeKey = TransactionDataPersistence.appModeKey
    static let hasCompletedOnboardingKey = TransactionDataPersistence.hasCompletedOnboardingKey

    private let defaultAccountId = UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID()
    private let persistence: TransactionDataPersistence
    private var isNormalizingGroups = false
    private var isSyncingRecurring = false
    private var isBatchUpdating = false
    private var derivedMetricsCache: TransactionDerivedMetrics?

    var appMode: AppDataMode {
        didSet {
            invalidateDerivedMetrics()
            persistence.saveAppMode(appMode)
        }
    }

    var accounts: [Account] {
        didSet {
            invalidateDerivedMetrics()
            if !isBatchUpdating { saveAccounts() }
        }
    }
    var investmentHoldings: [InvestmentHolding] {
        didSet {
            invalidateDerivedMetrics()
            if !isBatchUpdating { saveInvestmentHoldings() }
        }
    }
    var budgetCategories: [BudgetCategory]
    var merchantRules: [MerchantRule] {
        didSet {
            if !isBatchUpdating { saveMerchantRules() }
        }
    }
    var savingsGoals: [SavingsGoal]

    var groups: [SpendingTransactionGroup] {
        didSet {
            invalidateDerivedMetrics()
            if isBatchUpdating { return }
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
        didSet {
            invalidateDerivedMetrics()
            if !isBatchUpdating { saveSubscriptions() }
        }
    }

    var manualForecastItems: [ManualForecastItem] {
        didSet {
            invalidateDerivedMetrics()
            if !isBatchUpdating { saveManualForecastItems() }
        }
    }

    var budgetMode: BudgetMode {
        didSet {
            invalidateDerivedMetrics()
            persistence.saveBudgetMode(budgetMode)
        }
    }

    var budgetBaseValue: Double {
        didSet {
            invalidateDerivedMetrics()
            persistence.saveBudgetBaseValue(budgetBaseValue)
        }
    }

    private init() {
        let persistence = TransactionDataPersistence()
        let bootstrap = persistence.loadBootstrapState()
        self.persistence = persistence

        self.appMode = bootstrap.appMode
        self.budgetMode = bootstrap.budgetMode
        self.budgetBaseValue = bootstrap.budgetBaseValue
        self.accounts = bootstrap.accounts
        self.investmentHoldings = bootstrap.investmentHoldings
        self.budgetCategories = TransactionData.emptyBudgetCategories
        self.merchantRules = bootstrap.merchantRules
        self.savingsGoals = []
        self.groups = Self.groupsSortedChronologically(
            Self.groupsWithTransactionsSortedByTime(bootstrap.groups)
        )
        self.subscriptions = bootstrap.subscriptions
        self.manualForecastItems = bootstrap.manualForecastItems

        if !groups.isEmpty {
            groups = groups.map { group in
                SpendingTransactionGroup(
                    id: group.id,
                    title: group.title,
                    transactions: group.transactions.map { normalizeAndApplyRules(to: $0) }
                )
            }
        }

        if appMode == .demo && groups.isEmpty && accounts.isEmpty && subscriptions.isEmpty && investmentHoldings.isEmpty {
            loadDemoMode()
        }

        if !subscriptions.isEmpty {
            syncRecurringTransactions()
        }
    }

    private func invalidateDerivedMetrics() {
        derivedMetricsCache = nil
    }

    private func currentDerivedMetrics() -> TransactionDerivedMetrics {
        derivedMetrics(referenceDate: Date())
    }

    private func derivedMetrics(referenceDate: Date) -> TransactionDerivedMetrics {
        let calendar = Calendar.current
        let dayKey = calendar.startOfDay(for: referenceDate)
        let monthKey = calendar.dateInterval(of: .month, for: referenceDate)?.start ?? dayKey

        if calendar.isDate(dayKey, inSameDayAs: Date()),
           let cache = derivedMetricsCache,
           cache.dayKey == dayKey,
           cache.monthKey == monthKey {
            return cache
        }

        let cache = TransactionAnalyticsEngine.deriveMetrics(
            .init(
                referenceDate: referenceDate,
                groups: groups,
                budgetCategories: budgetCategories,
                visibleAccounts: visibleAccounts,
                effectiveBalance: { [self] account in effectiveBalance(for: account) },
                dailyBudget: dailyBudget,
                derivedMonthlyBudget: derivedMonthlyBudget,
                subscriptions: subscriptions,
                manualForecastItems: manualForecastItems,
                resolveGroupDate: Self.resolvedDate(forGroupTitle:now:),
                normalizeMerchant: normalizeMerchant
            )
        )

        if calendar.isDate(dayKey, inSameDayAs: Date()) {
            derivedMetricsCache = cache
        }

        return cache
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
        persistence.saveGroups(groups)
    }

    private func saveSubscriptions() {
        persistence.saveSubscriptions(subscriptions)
    }

    private func saveAccounts() {
        persistence.saveAccounts(accounts)
    }

    private func performBatchUpdate(_ updates: () -> Void) {
        isBatchUpdating = true
        updates()
        isBatchUpdating = false

        isNormalizingGroups = true
        let txSorted = Self.groupsWithTransactionsSortedByTime(groups)
        groups = Self.groupsSortedChronologically(txSorted)
        isNormalizingGroups = false

        save()
        saveAccounts()
        saveInvestmentHoldings()
        saveSubscriptions()
        saveManualForecastItems()
        saveMerchantRules()
    }

    private func saveInvestmentHoldings() {
        persistence.saveInvestmentHoldings(investmentHoldings)
    }

    private func saveManualForecastItems() {
        persistence.saveManualForecastItems(manualForecastItems)
    }

    private func saveMerchantRules() {
        persistence.saveMerchantRules(merchantRules)
    }

    func normalizeMerchant(_ merchant: String) -> String {
        TransactionRulesEngine.normalizeMerchant(merchant)
    }

    private var rulesContext: TransactionRulesEngine.Context {
        .init(
            merchantRules: merchantRules,
            allTransactions: allTransactions,
            defaultAccountId: defaultSpendingAccount?.id,
            normalizeMerchant: normalizeMerchant
        )
    }

    func applyMerchantRules(to transaction: SpendingTransaction) -> SpendingTransaction {
        TransactionRulesEngine.applyMerchantRules(to: transaction, context: rulesContext)
    }

    func normalizeAndApplyRules(to transaction: SpendingTransaction) -> SpendingTransaction {
        TransactionRulesEngine.normalizeAndApplyRules(to: transaction, context: rulesContext)
    }

    private var transactionEditingContext: TransactionEditingEngine.Context {
        TransactionEditingEngine.Context(
            defaultSpendingAccountId: defaultSpendingAccount?.id,
            normalizeAndApplyRules: { [self] in normalizeAndApplyRules(to: $0) },
            normalizeMerchant: { [self] in normalizeMerchant($0) },
            resolveGroupDate: { title, now in Self.resolvedDate(forGroupTitle: title, now: now) },
            dayLabel: { date in RecurringEngine.dayLabel(for: date) }
        )
    }

    func upsertMerchantRule(
        matchPattern: String,
        categoryOverride: SpendingCategory?,
        merchantDisplayName: String?,
        recurringHint: Bool
    ) {
        merchantRules = TransactionRulesEngine.upsertRule(
            into: merchantRules,
            matchPattern: matchPattern,
            categoryOverride: categoryOverride,
            merchantDisplayName: merchantDisplayName,
            recurringHint: recurringHint
        )
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
        TransactionRulesEngine.detectRecurringCandidate(
            for: merchant,
            allTransactions: allTransactions,
            normalizeMerchant: normalizeMerchant
        )
    }

    func detectRecurringCandidates() -> [String] {
        TransactionRulesEngine.detectRecurringCandidates(
            allTransactions: allTransactions,
            normalizeMerchant: normalizeMerchant
        )
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
        currentDerivedMetrics().todayTransactions
    }

    @discardableResult
    func removeTransaction(id: UUID) -> Bool {
        let result = TransactionEditingEngine.removeTransaction(id: id, from: groups)
        groups = result.groups
        return result.removed
    }

    @discardableResult
    func removeSplitGroup(id: UUID) -> Int {
        let result = TransactionEditingEngine.removeSplitGroup(id: id, from: groups)
        groups = result.groups
        return result.removedCount
    }

    func addTransaction(_ transaction: SpendingTransaction, on date: Date) {
        groups = TransactionEditingEngine.addTransaction(
            transaction,
            on: date,
            to: groups,
            context: transactionEditingContext
        )
    }

    func updateTransaction(
        _ transaction: SpendingTransaction,
        originalTransactionId: UUID,
        originalGroupTitle: String,
        originalGroupDate: Date,
        newDate: Date
    ) {
        groups = TransactionEditingEngine.updateTransaction(
            transaction,
            originalTransactionId: originalTransactionId,
            originalGroupTitle: originalGroupTitle,
            originalGroupDate: originalGroupDate,
            newDate: newDate,
            in: groups,
            context: transactionEditingContext
        )
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
        groups = TransactionEditingEngine.replaceTransactionWithSplit(
            original: transaction,
            newDate: newDate,
            merchantName: merchantName,
            kind: kind,
            accountId: accountId,
            isImpulse: isImpulse,
            allocations: allocations,
            notes: notes,
            in: groups,
            context: transactionEditingContext
        )
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
        groups = TransactionEditingEngine.addSplitTransactions(
            merchantName: merchantName,
            kind: kind,
            accountId: accountId,
            isImpulse: isImpulse,
            date: date,
            time: time,
            allocations: allocations,
            notes: notes,
            to: groups,
            context: transactionEditingContext
        )
    }

    func splitTransactions(for splitGroupId: UUID) -> [SpendingTransaction] {
        TransactionEditingEngine.splitTransactions(for: splitGroupId, in: groups)
    }

    func transaction(for id: UUID) -> SpendingTransaction? {
        TransactionEditingEngine.transaction(for: id, in: groups)
    }

    func updateTransactionDetails(
        transactionId: UUID,
        notes: String?,
        tags: [String],
        isImpulse: Bool,
        attachments: [TransactionAttachment]
    ) {
        groups = TransactionEditingEngine.updateTransactionDetails(
            transactionId: transactionId,
            notes: notes,
            tags: tags,
            isImpulse: isImpulse,
            attachments: attachments,
            in: groups
        )
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
        let result = TransactionImportEngine.importCSVTransactions(
            from: csv,
            context: .init(
                defaultAccountId: defaultAccountId,
                defaultSpendingAccountId: defaultSpendingAccount?.id,
                visibleAccounts: visibleAccounts,
                isDuplicate: { [self] date, merchant, signedAmount, accountId in
                    isDuplicateTransaction(date: date, merchant: merchant, signedAmount: signedAmount, accountId: accountId)
                },
                normalizeAndApplyRules: { [self] in normalizeAndApplyRules(to: $0) }
            )
        )
        for (transaction, date) in result.transactions {
            addTransaction(transaction, on: date)
        }
        return result.summary
    }

    // MARK: - Add Subscription + Auto-log Transaction
    func addSubscription(
        _ sub: RecurringSubscription,
        logInitialTransaction: Bool = true,
        initialTransactionDate: Date = Date()
    ) {
        subscriptions.append(sub)

        guard logInitialTransaction else { return }
        addRecurringTransaction(
            RecurringEngine.makeTransaction(
                for: sub,
                date: initialTransactionDate,
                defaultAccountId: defaultSpendingAccount?.id,
                normalizeMerchant: normalizeMerchant
            ),
            on: initialTransactionDate
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

    func removeSubscription(id: UUID) {
        subscriptions.removeAll { $0.id == id }
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

        let result = RecurringEngine.syncSubscriptions(
            subscriptions,
            defaultAccountId: defaultSpendingAccount?.id,
            normalizeMerchant: normalizeMerchant
        )

        for entry in result.generatedEntries {
            addRecurringTransaction(entry.transaction, on: entry.date)
        }

        if result.didMutateSubscriptions {
            subscriptions = result.subscriptions
        }
    }

    private func addRecurringTransaction(_ transaction: SpendingTransaction, on date: Date) {
        let dayLabel = RecurringEngine.dayLabel(for: date)

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

    // MARK: - Computed Analytics
    var defaultSpendingAccount: Account? {
        accounts.first(where: { $0.id == defaultAccountId })
        ?? accounts.first(where: { $0.type == .checking || $0.type == .savings || $0.type == .cash })
        ?? accounts.first
    }

    func holdings(forAccount accountId: UUID) -> [InvestmentHolding] {
        InvestmentAnalyticsEngine.holdings(forAccount: accountId, in: investmentHoldings)
    }

    func investmentPerformance(forAccount accountId: UUID? = nil) -> InvestmentPerformanceSummary {
        InvestmentAnalyticsEngine.performance(forAccount: accountId, holdings: investmentHoldings)
    }

    func portfolioAllocation(forAccount accountId: UUID? = nil) -> [PortfolioAllocationSlice] {
        InvestmentAnalyticsEngine.allocation(forAccount: accountId, holdings: investmentHoldings)
    }

    func effectiveBalance(for account: Account) -> Double {
        InvestmentAnalyticsEngine.effectiveBalance(for: account, holdings: investmentHoldings)
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
        InvestmentAnalyticsEngine.visibleAccounts(from: accounts)
    }

    var liquidCashBalance: Double {
        InvestmentAnalyticsEngine.liquidCashBalance(accounts: accounts, holdings: investmentHoldings)
    }

    var investedBalance: Double {
        InvestmentAnalyticsEngine.investedBalance(accounts: accounts, holdings: investmentHoldings)
    }

    var totalDebtBalance: Double {
        InvestmentAnalyticsEngine.totalDebtBalance(accounts: accounts, holdings: investmentHoldings)
    }

    var totalAssetsBalance: Double {
        InvestmentAnalyticsEngine.totalAssetsBalance(accounts: accounts, holdings: investmentHoldings)
    }

    var totalLiabilitiesBalance: Double {
        InvestmentAnalyticsEngine.totalLiabilitiesBalance(accounts: accounts, holdings: investmentHoldings)
    }

    var netWorthBalance: Double {
        InvestmentAnalyticsEngine.netWorthBalance(accounts: accounts, holdings: investmentHoldings)
    }

    var allTransactions: [SpendingTransaction] {
        currentDerivedMetrics().allTransactions
    }

    var budgetableTransactions: [SpendingTransaction] {
        currentDerivedMetrics().budgetableTransactions
    }

    var incomeTransactions: [SpendingTransaction] {
        currentDerivedMetrics().incomeTransactions
    }

    var transferTransactions: [SpendingTransaction] {
        currentDerivedMetrics().transferTransactions
    }

    var excludedCategories: Set<SpendingCategory> {
        currentDerivedMetrics().excludedCategories
    }

    func transactions(
        forMonth date: Date = Date(),
        category: SpendingCategory? = nil,
        accountId: UUID? = nil,
        kind: TransactionKind? = nil
    ) -> [SpendingTransaction] {
        let metrics = derivedMetrics(referenceDate: date)
        return metrics.allTransactions.filter { transaction in
            let matchesMonth = metrics.dateByTransactionId[transaction.id]
                .map { Calendar.current.isDate($0, equalTo: date, toGranularity: .month) } ?? false
            let matchesCategory = category.map { transaction.category == $0 } ?? true
            let matchesAccount = accountId.map { transaction.accountId == $0 } ?? true
            let matchesKind = kind.map { transaction.kind == $0 } ?? true
            return matchesMonth && matchesCategory && matchesAccount && matchesKind
        }
    }

    private func groupTitle(for transactionId: UUID) -> String {
        currentDerivedMetrics().groupTitleByTransactionId[transactionId] ?? "Today"
    }

    private func transactionDate(for transaction: SpendingTransaction, referenceDate: Date = Date()) -> Date? {
        derivedMetrics(referenceDate: referenceDate).dateByTransactionId[transaction.id]
    }

    func groupTitle(forTransactionId transactionId: UUID) -> String? {
        currentDerivedMetrics().groupTitleByTransactionId[transactionId]
    }

    func date(forTransactionId transactionId: UUID, referenceDate: Date = Date()) -> Date? {
        derivedMetrics(referenceDate: referenceDate).dateByTransactionId[transactionId]
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
        currentDerivedMetrics().totalSpent
    }

    var transactionCount: Int {
        currentDerivedMetrics().transactionCount
    }

    var monthToDateTransactions: [SpendingTransaction] {
        currentDerivedMetrics().monthToDateTransactions
    }

    var monthlySpent: Double {
        currentDerivedMetrics().monthlySpent
    }

    var monthlyIncome: Double {
        currentDerivedMetrics().monthlyIncome
    }

    var monthlyNet: Double {
        monthlyIncome - monthlySpent
    }

    func spendingByCategory(forMonth date: Date = Date()) -> [SpendingCategory: Double] {
        let metrics = derivedMetrics(referenceDate: date)
        if Calendar.current.isDate(date, equalTo: metrics.monthKey, toGranularity: .month) {
            return metrics.currentMonthCategorySpend
        }
        if Calendar.current.isDate(date, equalTo: metrics.previousMonthKey, toGranularity: .month) {
            return metrics.previousMonthCategorySpend
        }

        return transactions(forMonth: date).reduce(into: [SpendingCategory: Double]()) { result, transaction in
            guard transaction.kind == .spending else { return }
            guard !transaction.isExcludedFromBudget else { return }
            guard !metrics.excludedCategories.contains(transaction.category) else { return }
            result[transaction.category, default: 0] += transaction.amountValue
        }
    }

    func monthToDateComparison(referenceDate: Date = Date()) -> MonthlyComparison {
        let metrics = derivedMetrics(referenceDate: referenceDate)
        let currentTotal = metrics.currentMonthCategorySpend.values.reduce(0, +)
        let previousTotal = metrics.previousMonthCategorySpend.values.reduce(0, +)
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
        currentDerivedMetrics().cashFlowForecast
    }

    func cashFlowForecast(referenceDate: Date = Date(), horizonDays: Int = 30) -> CashFlowForecast {
        if horizonDays == 30 && Calendar.current.isDate(referenceDate, inSameDayAs: Date()) {
            return currentDerivedMetrics().cashFlowForecast
        }
        return TransactionAnalyticsEngine.buildCashFlowForecast(
            .init(
                referenceDate: referenceDate,
                horizonDays: horizonDays,
                startingCash: liquidCashBalance,
                subscriptions: subscriptions,
                manualForecastItems: manualForecastItems,
                incomeTransactions: incomeTransactions,
                transactionDates: derivedMetrics(referenceDate: referenceDate).dateByTransactionId,
                normalizeMerchant: normalizeMerchant
            )
        )
    }

    var totalMonthlyBudget: Double {
        currentDerivedMetrics().totalMonthlyBudget
    }

    var safeToSpendThisMonth: Double {
        currentDerivedMetrics().safeToSpendThisMonth
    }

    var totalGoalTarget: Double {
        savingsGoals.reduce(0) { $0 + $1.targetAmount }
    }

    var totalGoalProgress: Double {
        savingsGoals.reduce(0) { $0 + $1.currentAmount }
    }

    var categoryTotals: [CategoryData] {
        currentDerivedMetrics().categoryTotals
    }

    var topCategories: [CategoryData] {
        currentDerivedMetrics().topCategories
    }

    var recentTransactions: [SpendingTransaction] {
        currentDerivedMetrics().recentTransactions
    }

    var dailySpent: Double {
        currentDerivedMetrics().dailySpent
    }

    var dailyRemaining: Double {
        currentDerivedMetrics().dailyRemaining
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
        persistence.markOnboardingComplete()

        switch mode {
        case .demo:
            loadDemoMode()
        case .real:
            loadRealMode()
        }
    }

    private func loadDemoMode() {
        performBatchUpdate {
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
    }

    private func loadRealMode() {
        performBatchUpdate {
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
            let title = RecurringEngine.dayLabel(for: date)

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
            RecurringSubscription(name: "Netflix", plan: "Premium Plan", price: 19.99, iconName: "netflix", iconColor: .white, bgColor: .black, nextBilling: RecurringEngine.billingDisplayString(for: dates[0]), frequencyKey: "monthly", nextBillingEpoch: dates[0].timeIntervalSince1970, merchantMatchPattern: "Netflix", expectedAmountMin: 18.99, expectedAmountMax: 21.99),
            RecurringSubscription(name: "Spotify", plan: nil, price: 10.99, iconName: "spotify", iconColor: .black, bgColor: Color(red: 0.11, green: 0.72, blue: 0.33), nextBilling: RecurringEngine.billingDisplayString(for: dates[1]), frequencyKey: "monthly", nextBillingEpoch: dates[1].timeIntervalSince1970, merchantMatchPattern: "Spotify", expectedAmountMin: 9.99, expectedAmountMax: 12.99),
            RecurringSubscription(name: "Notion", plan: nil, price: 8.00, iconName: "notion", iconColor: .black, bgColor: .white, nextBilling: RecurringEngine.billingDisplayString(for: dates[2]), frequencyKey: "monthly", nextBillingEpoch: dates[2].timeIntervalSince1970, merchantMatchPattern: "Notion", expectedAmountMin: 8.00, expectedAmountMax: 8.00),
            RecurringSubscription(name: "YouTube", plan: "Premium", price: 13.99, iconName: "youtube", iconColor: .white, bgColor: Color(red: 1.0, green: 0.0, blue: 0.0), nextBilling: RecurringEngine.billingDisplayString(for: dates[3]), frequencyKey: "monthly", nextBillingEpoch: dates[3].timeIntervalSince1970, merchantMatchPattern: "YouTube", expectedAmountMin: 12.99, expectedAmountMax: 14.99),
            RecurringSubscription(name: "Equinox", plan: "Monthly", price: 95.00, iconName: "dumbbell.fill", iconColor: .white, bgColor: Color(red: 0.1, green: 0.1, blue: 0.1), nextBilling: RecurringEngine.billingDisplayString(for: dates[4]), frequencyKey: "monthly", nextBillingEpoch: dates[4].timeIntervalSince1970, merchantMatchPattern: "Equinox", expectedAmountMin: 95.00, expectedAmountMax: 95.00),
            RecurringSubscription(name: "iCloud", plan: "200GB", price: 2.99, iconName: "icloud.fill", iconColor: .white, bgColor: Color(red: 0.2, green: 0.5, blue: 1.0), nextBilling: RecurringEngine.billingDisplayString(for: dates[5]), frequencyKey: "monthly", nextBillingEpoch: dates[5].timeIntervalSince1970, merchantMatchPattern: "iCloud", expectedAmountMin: 2.99, expectedAmountMax: 2.99),
        ]
    }
}
