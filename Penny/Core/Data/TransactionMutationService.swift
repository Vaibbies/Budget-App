import Foundation

@MainActor
final class TransactionMutationService {
    private let data: any TransactionMutationBacking

    init(data: any TransactionMutationBacking) {
        self.data = data
    }

    @discardableResult
    func removeTransaction(id: UUID) -> Bool {
        data.removeTransaction(id: id)
    }

    func importCSVTransactions(from csv: String, defaultAccountId: UUID? = nil) -> TransactionImportSummary {
        data.importCSVTransactions(from: csv, defaultAccountId: defaultAccountId)
    }

    func addTransaction(_ transaction: SpendingTransaction, on date: Date) {
        data.addTransaction(transaction, on: date)
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
        data.addSplitTransactions(
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

    func updateTransactionDetails(
        transactionId: UUID,
        notes: String?,
        tags: [String],
        isImpulse: Bool,
        attachments: [TransactionAttachment]
    ) {
        data.updateTransactionDetails(
            transactionId: transactionId,
            notes: notes,
            tags: tags,
            isImpulse: isImpulse,
            attachments: attachments
        )
    }

    func updateTransaction(
        _ transaction: SpendingTransaction,
        originalTransactionId: UUID,
        originalGroupTitle: String,
        originalGroupDate: Date,
        newDate: Date
    ) {
        data.updateTransaction(
            transaction,
            originalTransactionId: originalTransactionId,
            originalGroupTitle: originalGroupTitle,
            originalGroupDate: originalGroupDate,
            newDate: newDate
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
        data.replaceTransactionWithSplit(
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

    func deleteManualForecastItem(id: UUID) {
        data.deleteManualForecastItem(id: id)
    }

    func addManualForecastItem(
        title: String,
        amount: Double,
        date: Date,
        kind: ManualForecastItem.Kind,
        note: String?
    ) {
        data.addManualForecastItem(
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
        data.upsertMerchantRule(
            matchPattern: matchPattern,
            categoryOverride: categoryOverride,
            merchantDisplayName: merchantDisplayName,
            recurringHint: recurringHint
        )
    }

    func addSubscription(
        _ sub: RecurringSubscription,
        logInitialTransaction: Bool = true,
        initialTransactionDate: Date = Date()
    ) {
        data.addSubscription(
            sub,
            logInitialTransaction: logInitialTransaction,
            initialTransactionDate: initialTransactionDate
        )
    }

    func updateRecurringStatus(_ id: UUID, status: RecurringStatus) {
        data.updateRecurringStatus(id, status: status)
    }

    func removeSubscription(id: UUID) {
        data.removeSubscription(id: id)
    }

    func syncRecurringTransactions() {
        data.syncRecurringTransactions()
    }

    func upsertAccount(_ account: Account) {
        data.upsertAccount(account)
    }

    func deleteAccount(id: UUID) {
        data.deleteAccount(id: id)
    }

    func setBudget(mode: BudgetMode, value: Double) {
        data.setBudget(mode: mode, value: value)
    }

    func upsertInvestmentHolding(_ holding: InvestmentHolding) {
        data.upsertInvestmentHolding(holding)
    }

    func deleteInvestmentHolding(id: UUID) {
        data.deleteInvestmentHolding(id: id)
    }
}
