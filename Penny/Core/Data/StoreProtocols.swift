import Foundation

@MainActor
protocol AppSessionDataStore: AnyObject {
    var appMode: AppDataMode { get }
    func activateMode(_ mode: AppDataMode)
}

@MainActor
protocol TransactionMutationBacking: AnyObject {
    @discardableResult func removeTransaction(id: UUID) -> Bool
    func importCSVTransactions(from csv: String, defaultAccountId: UUID?) -> TransactionImportSummary
    func addTransaction(_ transaction: SpendingTransaction, on date: Date)
    func addSplitTransactions(
        merchantName: String,
        kind: TransactionKind,
        accountId: UUID?,
        isImpulse: Bool,
        date: Date,
        time: String,
        allocations: [SplitTransactionAllocation],
        notes: String?
    )
    func updateTransactionDetails(
        transactionId: UUID,
        notes: String?,
        tags: [String],
        isImpulse: Bool,
        attachments: [TransactionAttachment]
    )
    func updateTransaction(
        _ transaction: SpendingTransaction,
        originalTransactionId: UUID,
        originalGroupTitle: String,
        originalGroupDate: Date,
        newDate: Date
    )
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
        notes: String?
    )
    func deleteManualForecastItem(id: UUID)
    func addManualForecastItem(
        title: String,
        amount: Double,
        date: Date,
        kind: ManualForecastItem.Kind,
        note: String?
    )
    func upsertMerchantRule(
        matchPattern: String,
        categoryOverride: SpendingCategory?,
        merchantDisplayName: String?,
        recurringHint: Bool
    )
    func addSubscription(
        _ sub: RecurringSubscription,
        logInitialTransaction: Bool,
        initialTransactionDate: Date
    )
    func updateRecurringStatus(_ id: UUID, status: RecurringStatus)
    func removeSubscription(id: UUID)
    func syncRecurringTransactions()
    func upsertAccount(_ account: Account)
    func deleteAccount(id: UUID)
    func setBudget(mode: BudgetMode, value: Double)
    func upsertInvestmentHolding(_ holding: InvestmentHolding)
    func deleteInvestmentHolding(id: UUID)
}

@MainActor
protocol SpendingDataStore: AnyObject {
    var groups: [SpendingTransactionGroup] { get }
    var allTransactions: [SpendingTransaction] { get }
    var accounts: [Account] { get }
    var subscriptions: [RecurringSubscription] { get }
    var savingsGoals: [SavingsGoal] { get }
    var visibleAccounts: [Account] { get }
    var recentTransactions: [SpendingTransaction] { get }
    var dailySpent: Double { get }
    var dailyRemaining: Double { get }
    var totalSpent: Double { get }
    var transactionCount: Int { get }
    var topCategories: [CategoryData] { get }
    var categoryTotals: [CategoryData] { get }
    var monthlySpent: Double { get }
    var monthlyIncome: Double { get }
    var monthlyNet: Double { get }
    var totalMonthlyBudget: Double { get }
    var safeToSpendThisMonth: Double { get }
    var cashFlowForecast: CashFlowForecast { get }
    var manualForecastItems: [ManualForecastItem] { get }
    var defaultSpendingAccount: Account? { get }
    var dailyBudget: Double { get }
    func monthToDateComparison(referenceDate: Date) -> MonthlyComparison
    func isGroupInToday(_ group: SpendingTransactionGroup, now: Date) -> Bool
    func accountName(for id: UUID?) -> String?
    func splitTransactions(for splitGroupId: UUID) -> [SpendingTransaction]
    func normalizeAndApplyRules(to transaction: SpendingTransaction) -> SpendingTransaction
    func normalizeMerchant(_ merchant: String) -> String
    func transaction(for id: UUID) -> SpendingTransaction?
    func merchantHistory(for transaction: SpendingTransaction, limit: Int) -> [SpendingTransaction]
    func date(forTransactionId transactionId: UUID, referenceDate: Date) -> Date?
}

@MainActor
protocol RecurringDataStore: AnyObject {
    var subscriptions: [RecurringSubscription] { get }
}

@MainActor
protocol BankDataStore: AnyObject {
    var visibleAccounts: [Account] { get }
    var investmentAccounts: [Account] { get }
    var investmentHoldings: [InvestmentHolding] { get }
    var savingsGoals: [SavingsGoal] { get }
    var cashFlowForecast: CashFlowForecast { get }
    var daysInCurrentMonth: Int { get }
    var netWorthBalance: Double { get }
    var totalAssetsBalance: Double { get }
    var totalLiabilitiesBalance: Double { get }
    var configuredBudgetValue: Double { get }
    var budgetMode: BudgetMode { get }
    var dailySpent: Double { get }
    var dailyRemaining: Double { get }
    var dailyBudget: Double { get }
    var totalMonthlyBudget: Double { get }
    var liquidCashBalance: Double { get }
    var investedBalance: Double { get }
    var totalDebtBalance: Double { get }
    var safeToSpendThisMonth: Double { get }
    var monthlyNet: Double { get }
    var totalGoalProgress: Double { get }
    func investmentPerformance(forAccount accountId: UUID?) -> InvestmentPerformanceSummary
    func portfolioAllocation(forAccount accountId: UUID?) -> [PortfolioAllocationSlice]
    func effectiveBalance(for account: Account) -> Double
    func monthlySpend(forAccount id: UUID?, inMonth date: Date) -> Double
    func monthlyIncome(forAccount id: UUID?, inMonth date: Date) -> Double
    func monthlyNet(forAccount id: UUID?, inMonth date: Date) -> Double
    func transactions(forAccount id: UUID?, inMonth date: Date) -> [SpendingTransaction]
    func holdings(forAccount accountId: UUID) -> [InvestmentHolding]
    func normalizedBalance(for type: AccountType, enteredBalance: Double) -> Double
}

@MainActor
protocol PlatformDataStore: AnyObject {
    var accounts: [Account] { get }
    var visibleAccounts: [Account] { get }
    var merchantRules: [MerchantRule] { get }
    var subscriptions: [RecurringSubscription] { get }
    var investmentAccounts: [Account] { get }
    var budgetMode: BudgetMode { get }
    var configuredBudgetValue: Double { get }
    var dailyBudget: Double { get }
    var derivedMonthlyBudget: Double { get }
    var totalMonthlyBudget: Double { get }
    var monthlySpent: Double { get }
    var safeToSpendThisMonth: Double { get }
    func detectRecurringCandidates() -> [String]
    func investmentPerformance(forAccount accountId: UUID?) -> InvestmentPerformanceSummary
    func portfolioAllocation(forAccount accountId: UUID?) -> [PortfolioAllocationSlice]
    func effectiveBalance(for account: Account) -> Double
    func monthlySpend(forAccount id: UUID?, inMonth date: Date) -> Double
    func monthlyIncome(forAccount id: UUID?, inMonth date: Date) -> Double
    func transactions(forAccount id: UUID?, inMonth date: Date) -> [SpendingTransaction]
}
