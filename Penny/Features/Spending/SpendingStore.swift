import Foundation
import Observation

@MainActor
@Observable
final class SpendingStore {
    private let data: TransactionData
    private let mutations: TransactionMutationService

    init(
        data: TransactionData,
        mutations: TransactionMutationService? = nil
    ) {
        self.data = data
        self.mutations = mutations ?? TransactionMutationService(data: data)
    }

    var groups: [SpendingTransactionGroup] { data.groups }
    var allTransactions: [SpendingTransaction] { data.allTransactions }
    var accounts: [Account] { data.accounts }
    var subscriptions: [RecurringSubscription] { data.subscriptions }
    var savingsGoals: [SavingsGoal] { data.savingsGoals }
    var visibleAccounts: [Account] { data.visibleAccounts }
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
    var totalMonthlyBudget: Double { data.totalMonthlyBudget }
    var safeToSpendThisMonth: Double { data.safeToSpendThisMonth }
    var cashFlowForecast: CashFlowForecast { data.cashFlowForecast }
    var manualForecastItems: [ManualForecastItem] { data.manualForecastItems }
    var defaultSpendingAccount: Account? { data.defaultSpendingAccount }
    var dailyBudget: Double { data.dailyBudget }

    var notificationSnapshot: NotificationRefreshSnapshot {
        NotificationRefreshSnapshot(
            subscriptions: data.subscriptions,
            manualForecastItems: data.manualForecastItems,
            dailySpent: data.dailySpent,
            dailyRemaining: data.dailyRemaining,
            dailyBudget: data.dailyBudget,
            totalMonthlyBudget: data.totalMonthlyBudget,
            safeToSpendThisMonth: data.safeToSpendThisMonth,
            topCategories: data.topCategories
        )
    }

    func monthToDateComparison(referenceDate: Date = Date()) -> MonthlyComparison {
        data.monthToDateComparison(referenceDate: referenceDate)
    }

    func isGroupInToday(_ group: SpendingTransactionGroup, now: Date = Date()) -> Bool {
        data.isGroupInToday(group, now: now)
    }

    @discardableResult
    func removeTransaction(id: UUID) -> Bool {
        mutations.removeTransaction(id: id)
    }

    func importCSVTransactions(from csv: String, defaultAccountId: UUID? = nil) -> TransactionImportSummary {
        mutations.importCSVTransactions(from: csv, defaultAccountId: defaultAccountId)
    }

    func accountName(for id: UUID?) -> String? {
        data.accountName(for: id)
    }

    func syncRecurringTransactions() {
        mutations.syncRecurringTransactions()
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

    func addTransaction(_ transaction: SpendingTransaction, on date: Date) {
        mutations.addTransaction(transaction, on: date)
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
        mutations.addSplitTransactions(
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
        data.transaction(for: id)
    }

    func merchantHistory(for transaction: SpendingTransaction, limit: Int = 8) -> [SpendingTransaction] {
        data.merchantHistory(for: transaction, limit: limit)
    }

    func date(forTransactionId transactionId: UUID, referenceDate: Date = Date()) -> Date? {
        data.date(forTransactionId: transactionId, referenceDate: referenceDate)
    }

    func updateTransactionDetails(
        transactionId: UUID,
        notes: String?,
        tags: [String],
        isImpulse: Bool,
        attachments: [TransactionAttachment]
    ) {
        mutations.updateTransactionDetails(
            transactionId: transactionId,
            notes: notes,
            tags: tags,
            isImpulse: isImpulse,
            attachments: attachments
        )
    }

    func deleteManualForecastItem(id: UUID) {
        mutations.deleteManualForecastItem(id: id)
    }

    func addManualForecastItem(
        title: String,
        amount: Double,
        date: Date,
        kind: ManualForecastItem.Kind,
        note: String?
    ) {
        mutations.addManualForecastItem(
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
        mutations.upsertMerchantRule(
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
        mutations.replaceTransactionWithSplit(
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
        mutations.updateTransaction(
            transaction,
            originalTransactionId: originalTransactionId,
            originalGroupTitle: originalGroupTitle,
            originalGroupDate: originalGroupDate,
            newDate: newDate
        )
    }
}
