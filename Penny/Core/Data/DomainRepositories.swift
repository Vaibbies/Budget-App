import Foundation

@MainActor
protocol AccountsRepository: AnyObject {
    var accounts: [Account] { get }
    var visibleAccounts: [Account] { get }
    var defaultSpendingAccount: Account? { get }
    func accountName(for id: UUID?) -> String?
    func normalizedBalance(for type: AccountType, enteredBalance: Double) -> Double
}

@MainActor
protocol TransactionsRepository: AnyObject {
    var groups: [SpendingTransactionGroup] { get }
    var allTransactions: [SpendingTransaction] { get }
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
    func monthToDateComparison(referenceDate: Date) -> MonthlyComparison
    func isGroupInToday(_ group: SpendingTransactionGroup, now: Date) -> Bool
    func splitTransactions(for splitGroupId: UUID) -> [SpendingTransaction]
    func normalizeAndApplyRules(to transaction: SpendingTransaction) -> SpendingTransaction
    func normalizeMerchant(_ merchant: String) -> String
    func transaction(for id: UUID) -> SpendingTransaction?
    func merchantHistory(for transaction: SpendingTransaction, limit: Int) -> [SpendingTransaction]
    func date(forTransactionId transactionId: UUID, referenceDate: Date) -> Date?
    func monthlySpend(forAccount id: UUID?, inMonth date: Date) -> Double
    func monthlyIncome(forAccount id: UUID?, inMonth date: Date) -> Double
    func monthlyNet(forAccount id: UUID?, inMonth date: Date) -> Double
    func transactions(forAccount id: UUID?, inMonth date: Date) -> [SpendingTransaction]
}

@MainActor
protocol BudgetRepository: AnyObject {
    var configuredBudgetValue: Double { get }
    var budgetMode: BudgetMode { get }
    var dailyBudget: Double { get }
    var totalMonthlyBudget: Double { get }
    var safeToSpendThisMonth: Double { get }
    var daysInCurrentMonth: Int { get }
    var derivedMonthlyBudget: Double { get }
}

@MainActor
protocol ForecastRepository: AnyObject {
    var cashFlowForecast: CashFlowForecast { get }
    var manualForecastItems: [ManualForecastItem] { get }
}

@MainActor
protocol RecurringRepository: AnyObject {
    var subscriptions: [RecurringSubscription] { get }
}

@MainActor
protocol InvestmentsRepository: AnyObject {
    var investmentAccounts: [Account] { get }
    var investmentHoldings: [InvestmentHolding] { get }
    var savingsGoals: [SavingsGoal] { get }
    var netWorthBalance: Double { get }
    var totalAssetsBalance: Double { get }
    var totalLiabilitiesBalance: Double { get }
    var liquidCashBalance: Double { get }
    var investedBalance: Double { get }
    var totalDebtBalance: Double { get }
    var monthlyNet: Double { get }
    var totalGoalProgress: Double { get }
    func investmentPerformance(forAccount accountId: UUID?) -> InvestmentPerformanceSummary
    func portfolioAllocation(forAccount accountId: UUID?) -> [PortfolioAllocationSlice]
    func effectiveBalance(for account: Account) -> Double
    func holdings(forAccount accountId: UUID) -> [InvestmentHolding]
}

@MainActor
protocol CategorizationRepository: AnyObject {
    var merchantRules: [MerchantRule] { get }
    func detectRecurringCandidates() -> [String]
}

@MainActor
final class LocalAccountsRepository: AccountsRepository {
    private let data: TransactionData

    init(data: TransactionData) {
        self.data = data
    }

    var accounts: [Account] { data.accounts }
    var visibleAccounts: [Account] { data.visibleAccounts }
    var defaultSpendingAccount: Account? { data.defaultSpendingAccount }

    func accountName(for id: UUID?) -> String? {
        data.accountName(for: id)
    }

    func normalizedBalance(for type: AccountType, enteredBalance: Double) -> Double {
        data.normalizedBalance(for: type, enteredBalance: enteredBalance)
    }
}

@MainActor
final class LocalTransactionsRepository: TransactionsRepository {
    private let data: TransactionData

    init(data: TransactionData) {
        self.data = data
    }

    var groups: [SpendingTransactionGroup] { data.groups }
    var allTransactions: [SpendingTransaction] { data.allTransactions }
    var recentTransactions: [SpendingTransaction] { data.recentTransactions }
    var dailySpent: Double { data.dailySpent }
    var dailyRemaining: Double { data.dailyRemaining }
    var totalSpent: Double { data.totalSpent }
    var transactionCount: Int { data.transactionCount }
    var topCategories: [CategoryData] { data.topCategories }
    var categoryTotals: [CategoryData] { data.categoryTotals }
    var monthlySpent: Double { data.monthlySpent }
    var monthlyIncome: Double { data.monthlyIncome }
    var monthlyNet: Double { data.monthlyNet }

    func monthToDateComparison(referenceDate: Date) -> MonthlyComparison {
        data.monthToDateComparison(referenceDate: referenceDate)
    }

    func isGroupInToday(_ group: SpendingTransactionGroup, now: Date) -> Bool {
        data.isGroupInToday(group, now: now)
    }

    func splitTransactions(for splitGroupId: UUID) -> [SpendingTransaction] {
        data.splitTransactions(for: splitGroupId)
    }

    func normalizeAndApplyRules(to transaction: SpendingTransaction) -> SpendingTransaction {
        data.normalizeAndApplyRules(to: transaction)
    }

    func normalizeMerchant(_ merchant: String) -> String {
        data.normalizeMerchant(merchant)
    }

    func transaction(for id: UUID) -> SpendingTransaction? {
        data.transaction(for: id)
    }

    func merchantHistory(for transaction: SpendingTransaction, limit: Int) -> [SpendingTransaction] {
        data.merchantHistory(for: transaction, limit: limit)
    }

    func date(forTransactionId transactionId: UUID, referenceDate: Date) -> Date? {
        data.date(forTransactionId: transactionId, referenceDate: referenceDate)
    }

    func monthlySpend(forAccount id: UUID?, inMonth date: Date) -> Double {
        data.monthlySpend(forAccount: id, inMonth: date)
    }

    func monthlyIncome(forAccount id: UUID?, inMonth date: Date) -> Double {
        data.monthlyIncome(forAccount: id, inMonth: date)
    }

    func monthlyNet(forAccount id: UUID?, inMonth date: Date) -> Double {
        data.monthlyNet(forAccount: id, inMonth: date)
    }

    func transactions(forAccount id: UUID?, inMonth date: Date) -> [SpendingTransaction] {
        data.transactions(forAccount: id, inMonth: date)
    }
}

@MainActor
final class LocalBudgetRepository: BudgetRepository {
    private let data: TransactionData

    init(data: TransactionData) {
        self.data = data
    }

    var configuredBudgetValue: Double { data.configuredBudgetValue }
    var budgetMode: BudgetMode { data.budgetMode }
    var dailyBudget: Double { data.dailyBudget }
    var totalMonthlyBudget: Double { data.totalMonthlyBudget }
    var safeToSpendThisMonth: Double { data.safeToSpendThisMonth }
    var daysInCurrentMonth: Int { data.daysInCurrentMonth }
    var derivedMonthlyBudget: Double {
        budgetMode == .daily ? configuredBudgetValue * Double(daysInCurrentMonth) : configuredBudgetValue
    }
}

@MainActor
final class LocalForecastRepository: ForecastRepository {
    private let data: TransactionData

    init(data: TransactionData) {
        self.data = data
    }

    var cashFlowForecast: CashFlowForecast { data.cashFlowForecast }
    var manualForecastItems: [ManualForecastItem] { data.manualForecastItems }
}

@MainActor
final class LocalRecurringRepository: RecurringRepository {
    private let data: TransactionData

    init(data: TransactionData) {
        self.data = data
    }

    var subscriptions: [RecurringSubscription] { data.subscriptions }
}

@MainActor
final class LocalInvestmentsRepository: InvestmentsRepository {
    private let data: TransactionData

    init(data: TransactionData) {
        self.data = data
    }

    var investmentAccounts: [Account] { data.investmentAccounts }
    var investmentHoldings: [InvestmentHolding] { data.investmentHoldings }
    var savingsGoals: [SavingsGoal] { data.savingsGoals }
    var netWorthBalance: Double { data.netWorthBalance }
    var totalAssetsBalance: Double { data.totalAssetsBalance }
    var totalLiabilitiesBalance: Double { data.totalLiabilitiesBalance }
    var liquidCashBalance: Double { data.liquidCashBalance }
    var investedBalance: Double { data.investedBalance }
    var totalDebtBalance: Double { data.totalDebtBalance }
    var monthlyNet: Double { data.monthlyNet }
    var totalGoalProgress: Double { data.totalGoalProgress }

    func investmentPerformance(forAccount accountId: UUID?) -> InvestmentPerformanceSummary {
        data.investmentPerformance(forAccount: accountId)
    }

    func portfolioAllocation(forAccount accountId: UUID?) -> [PortfolioAllocationSlice] {
        data.portfolioAllocation(forAccount: accountId)
    }

    func effectiveBalance(for account: Account) -> Double {
        data.effectiveBalance(for: account)
    }

    func holdings(forAccount accountId: UUID) -> [InvestmentHolding] {
        data.holdings(forAccount: accountId)
    }
}

@MainActor
final class LocalCategorizationRepository: CategorizationRepository {
    private let data: TransactionData

    init(data: TransactionData) {
        self.data = data
    }

    var merchantRules: [MerchantRule] { data.merchantRules }

    func detectRecurringCandidates() -> [String] {
        data.detectRecurringCandidates()
    }
}
