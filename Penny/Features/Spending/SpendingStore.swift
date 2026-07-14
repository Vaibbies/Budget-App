import Foundation
import Observation

@MainActor
@Observable
final class SpendingStore {
    private let accountsRepository: any AccountsRepository
    private let transactionsRepository: any TransactionsRepository
    private let recurringRepository: any RecurringRepository
    private let forecastRepository: any ForecastRepository
    private let budgetRepository: any BudgetRepository
    private let investmentsRepository: any InvestmentsRepository
    private let transactionsService: TransactionsService
    private let recurringService: RecurringManagementService
    private let forecastService: ForecastService
    private let merchantRulesService: MerchantRulesService

    init(
        accountsRepository: any AccountsRepository,
        transactionsRepository: any TransactionsRepository,
        recurringRepository: any RecurringRepository,
        forecastRepository: any ForecastRepository,
        budgetRepository: any BudgetRepository,
        investmentsRepository: any InvestmentsRepository,
        transactionsService: TransactionsService,
        recurringService: RecurringManagementService,
        forecastService: ForecastService,
        merchantRulesService: MerchantRulesService
    ) {
        self.accountsRepository = accountsRepository
        self.transactionsRepository = transactionsRepository
        self.recurringRepository = recurringRepository
        self.forecastRepository = forecastRepository
        self.budgetRepository = budgetRepository
        self.investmentsRepository = investmentsRepository
        self.transactionsService = transactionsService
        self.recurringService = recurringService
        self.forecastService = forecastService
        self.merchantRulesService = merchantRulesService
    }

    var groups: [SpendingTransactionGroup] { transactionsRepository.groups }
    var allTransactions: [SpendingTransaction] { transactionsRepository.allTransactions }
    var accounts: [Account] { accountsRepository.accounts }
    var subscriptions: [RecurringSubscription] { recurringRepository.subscriptions }
    var savingsGoals: [SavingsGoal] { investmentsRepository.savingsGoals }
    var visibleAccounts: [Account] { accountsRepository.visibleAccounts }
    var recentTransactions: [SpendingTransaction] { transactionsRepository.recentTransactions }
    var dailySpent: Double { transactionsRepository.dailySpent }
    var dailyRemaining: Double { transactionsRepository.dailyRemaining }
    var totalSpent: Double { transactionsRepository.totalSpent }
    var transactionCount: Int { transactionsRepository.transactionCount }
    var topCategories: [CategoryData] { transactionsRepository.topCategories }
    var categoryTotals: [CategoryData] { transactionsRepository.categoryTotals }
    var monthlySpent: Double { transactionsRepository.monthlySpent }
    var monthlyIncome: Double { transactionsRepository.monthlyIncome }
    var monthlyNet: Double { transactionsRepository.monthlyNet }
    var totalMonthlyBudget: Double { budgetRepository.totalMonthlyBudget }
    var safeToSpendThisMonth: Double { budgetRepository.safeToSpendThisMonth }
    var cashFlowForecast: CashFlowForecast { forecastRepository.cashFlowForecast }
    var manualForecastItems: [ManualForecastItem] { forecastRepository.manualForecastItems }
    var defaultSpendingAccount: Account? { accountsRepository.defaultSpendingAccount }
    var dailyBudget: Double { budgetRepository.dailyBudget }

    var notificationSnapshot: NotificationRefreshSnapshot {
        NotificationRefreshSnapshot(
            subscriptions: recurringRepository.subscriptions,
            manualForecastItems: forecastRepository.manualForecastItems,
            dailySpent: transactionsRepository.dailySpent,
            dailyRemaining: transactionsRepository.dailyRemaining,
            dailyBudget: budgetRepository.dailyBudget,
            totalMonthlyBudget: budgetRepository.totalMonthlyBudget,
            safeToSpendThisMonth: budgetRepository.safeToSpendThisMonth,
            topCategories: transactionsRepository.topCategories
        )
    }

    func monthToDateComparison(referenceDate: Date = Date()) -> MonthlyComparison {
        transactionsRepository.monthToDateComparison(referenceDate: referenceDate)
    }

    func isGroupInToday(_ group: SpendingTransactionGroup, now: Date = Date()) -> Bool {
        transactionsRepository.isGroupInToday(group, now: now)
    }

    @discardableResult
    func removeTransaction(id: UUID) -> Bool {
        transactionsService.removeTransaction(id: id)
    }

    func importCSVTransactions(from csv: String, defaultAccountId: UUID? = nil) -> TransactionImportSummary {
        transactionsService.importCSVTransactions(from: csv, defaultAccountId: defaultAccountId)
    }

    func accountName(for id: UUID?) -> String? {
        accountsRepository.accountName(for: id)
    }

    func syncRecurringTransactions() {
        recurringService.syncRecurringTransactions()
    }

    func splitTransactions(for splitGroupId: UUID) -> [SpendingTransaction] {
        transactionsRepository.splitTransactions(for: splitGroupId)
    }

    func normalizeAndApplyRules(to transaction: SpendingTransaction) -> SpendingTransaction {
        transactionsRepository.normalizeAndApplyRules(to: transaction)
    }

    func normalizeMerchant(_ merchant: String) -> String {
        transactionsRepository.normalizeMerchant(merchant)
    }

    func addTransaction(_ transaction: SpendingTransaction, on date: Date) {
        transactionsService.addTransaction(transaction, on: date)
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
        transactionsService.addSplitTransactions(
            merchantName: merchantName,
            kind: kind,
            accountId: accountId,
            isImpulse: isImpulse,
            date: date,
            time: time,
            allocations: allocations,
            notes: notes
        )
    }

    func transaction(for id: UUID) -> SpendingTransaction? {
        transactionsRepository.transaction(for: id)
    }

    func merchantHistory(for transaction: SpendingTransaction, limit: Int = 8) -> [SpendingTransaction] {
        transactionsRepository.merchantHistory(for: transaction, limit: limit)
    }

    func date(forTransactionId transactionId: UUID, referenceDate: Date = Date()) -> Date? {
        transactionsRepository.date(forTransactionId: transactionId, referenceDate: referenceDate)
    }

    func updateTransactionDetails(
        transactionId: UUID,
        notes: String?,
        tags: [String],
        isImpulse: Bool,
        attachments: [TransactionAttachment]
    ) {
        transactionsService.updateTransactionDetails(
            transactionId: transactionId,
            notes: notes,
            tags: tags,
            isImpulse: isImpulse,
            attachments: attachments
        )
    }

    func deleteManualForecastItem(id: UUID) {
        forecastService.deleteManualForecastItem(id: id)
    }

    func addManualForecastItem(
        title: String,
        amount: Double,
        date: Date,
        kind: ManualForecastItem.Kind,
        note: String?
    ) {
        forecastService.addManualForecastItem(
            title: title,
            amount: amount,
            date: date,
            kind: kind,
            note: note
        )
    }

    func upsertMerchantRule(
        matchPattern: String,
        categoryOverride: SpendingCategory?,
        merchantDisplayName: String?,
        recurringHint: Bool
    ) {
        merchantRulesService.upsertMerchantRule(
            matchPattern: matchPattern,
            categoryOverride: categoryOverride,
            merchantDisplayName: merchantDisplayName,
            recurringHint: recurringHint
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
        transactionsService.replaceTransactionWithSplit(
            original: transaction,
            originalGroupTitle: originalGroupTitle,
            originalGroupDate: originalGroupDate,
            newDate: newDate,
            merchantName: merchantName,
            kind: kind,
            accountId: accountId,
            isImpulse: isImpulse,
            allocations: allocations,
            notes: notes
        )
    }

    func updateTransaction(
        _ transaction: SpendingTransaction,
        originalTransactionId: UUID,
        originalGroupTitle: String,
        originalGroupDate: Date,
        newDate: Date
    ) {
        transactionsService.updateTransaction(
            transaction,
            originalTransactionId: originalTransactionId,
            originalGroupTitle: originalGroupTitle,
            originalGroupDate: originalGroupDate,
            newDate: newDate
        )
    }
}
