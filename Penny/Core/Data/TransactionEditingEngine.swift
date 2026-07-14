import Foundation
import SwiftUI

enum TransactionEditingEngine {
    struct Context {
        let defaultSpendingAccountId: UUID?
        let normalizeAndApplyRules: (SpendingTransaction) -> SpendingTransaction
        let normalizeMerchant: (String) -> String
        let resolveGroupDate: (String, Date) -> Date?
        let dayLabel: (Date) -> String
    }

    struct RemovalResult {
        let groups: [SpendingTransactionGroup]
        let removed: Bool
    }

    struct SplitRemovalResult {
        let groups: [SpendingTransactionGroup]
        let removedCount: Int
    }

    static func removeTransaction(
        id: UUID,
        from groups: [SpendingTransactionGroup]
    ) -> RemovalResult {
        var groups = groups

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

                return RemovalResult(groups: groups, removed: true)
            }
        }

        return RemovalResult(groups: groups, removed: false)
    }

    static func removeSplitGroup(
        id: UUID,
        from groups: [SpendingTransactionGroup]
    ) -> SplitRemovalResult {
        var groups = groups
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

        return SplitRemovalResult(groups: groups, removedCount: removedCount)
    }

    static func addTransaction(
        _ transaction: SpendingTransaction,
        on date: Date,
        to groups: [SpendingTransactionGroup],
        context: Context
    ) -> [SpendingTransactionGroup] {
        var groups = groups
        let dayLabel = context.dayLabel(date)

        if let index = groups.firstIndex(where: { $0.title == dayLabel }) {
            var updated = groups[index].transactions
            updated.insert(context.normalizeAndApplyRules(transaction), at: 0)
            groups[index] = SpendingTransactionGroup(
                id: groups[index].id,
                title: groups[index].title,
                transactions: updated
            )
            return groups
        }

        let insertIndex = groups.firstIndex(where: { group in
            guard group.title != "Today" && group.title != "Yesterday" else { return false }
            if let groupDate = context.resolveGroupDate(group.title, date) {
                return groupDate < date
            }
            return false
        }) ?? groups.endIndex

        groups.insert(
            SpendingTransactionGroup(
                title: dayLabel,
                transactions: [context.normalizeAndApplyRules(transaction)]
            ),
            at: insertIndex
        )

        return groups
    }

    static func updateTransaction(
        _ transaction: SpendingTransaction,
        originalTransactionId: UUID,
        originalGroupTitle: String,
        originalGroupDate: Date,
        newDate: Date,
        in groups: [SpendingTransactionGroup],
        context: Context
    ) -> [SpendingTransactionGroup] {
        var groups = groups

        let newDayLabel: String
        if Calendar.current.isDate(newDate, inSameDayAs: originalGroupDate) {
            newDayLabel = originalGroupTitle
        } else {
            newDayLabel = context.dayLabel(newDate)
        }

        let originalGroupIndex = groups.firstIndex(where: { $0.title == originalGroupTitle })
        let originalInsertIndex = originalGroupIndex.flatMap { groupIndex in
            groups[groupIndex].transactions.firstIndex(where: { $0.id == originalTransactionId })
        } ?? 0

        groups = removeTransaction(id: originalTransactionId, from: groups).groups

        let normalized = context.normalizeAndApplyRules(transaction)
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
                if let groupDate = context.resolveGroupDate(group.title, newDate) {
                    return groupDate < newDate
                }
                return false
            }) ?? groups.endIndex

            groups.insert(
                SpendingTransactionGroup(title: newDayLabel, transactions: [normalized]),
                at: insertIndex
            )
        }

        return groups
    }

    static func replaceTransactionWithSplit(
        original transaction: SpendingTransaction,
        newDate: Date,
        merchantName: String,
        kind: TransactionKind,
        accountId: UUID?,
        isImpulse: Bool,
        allocations: [SplitTransactionAllocation],
        notes: String?,
        in groups: [SpendingTransactionGroup],
        context: Context
    ) -> [SpendingTransactionGroup] {
        var groups = groups
        let rawTitle = merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? transaction.title
            : merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let splitGroupId = transaction.splitGroupId ?? UUID()

        if let existingSplitGroupId = transaction.splitGroupId {
            groups = removeSplitGroup(id: existingSplitGroupId, from: groups).groups
        } else {
            groups = removeTransaction(id: transaction.id, from: groups).groups
        }

        for allocation in allocations where allocation.amount > 0 {
            let splitTitle = allocation.label.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = splitTitle.isEmpty ? rawTitle : "\(rawTitle) • \(splitTitle)"

            let splitTransaction = SpendingTransaction(
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
                accountId: accountId ?? context.defaultSpendingAccountId,
                kind: kind,
                merchantRaw: rawTitle,
                merchantNormalized: context.normalizeMerchant(rawTitle),
                notes: notes,
                tags: Array(Set(transaction.tags + ["split"])).sorted(),
                attachments: transaction.attachments,
                isExcludedFromBudget: transaction.isExcludedFromBudget,
                isRecurringCandidate: transaction.isRecurringCandidate,
                splitGroupId: splitGroupId,
                splitLabel: splitLabel(from: allocation.label)
            )

            groups = addTransaction(splitTransaction, on: newDate, to: groups, context: context)
        }

        return groups
    }

    static func addSplitTransactions(
        merchantName: String,
        kind: TransactionKind,
        accountId: UUID?,
        isImpulse: Bool,
        date: Date,
        time: String,
        allocations: [SplitTransactionAllocation],
        notes: String?,
        to groups: [SpendingTransactionGroup],
        context: Context
    ) -> [SpendingTransactionGroup] {
        var groups = groups
        let rawTitle = merchantName.trimmingCharacters(in: .whitespacesAndNewlines)
        let splitGroupId = UUID()

        for allocation in allocations where allocation.amount > 0 {
            let splitTitle = allocation.label.trimmingCharacters(in: .whitespacesAndNewlines)
            let title = splitTitle.isEmpty ? rawTitle : "\(rawTitle) • \(splitTitle)"

            let splitTransaction = SpendingTransaction(
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
                accountId: accountId ?? context.defaultSpendingAccountId,
                kind: kind,
                merchantRaw: rawTitle,
                merchantNormalized: context.normalizeMerchant(rawTitle),
                notes: notes,
                tags: ["split"],
                attachments: [],
                splitGroupId: splitGroupId,
                splitLabel: splitLabel(from: allocation.label)
            )

            groups = addTransaction(splitTransaction, on: date, to: groups, context: context)
        }

        return groups
    }

    static func splitTransactions(
        for splitGroupId: UUID,
        in groups: [SpendingTransactionGroup]
    ) -> [SpendingTransaction] {
        groups.flatMap(\.transactions).filter { $0.splitGroupId == splitGroupId }
    }

    static func transaction(
        for id: UUID,
        in groups: [SpendingTransactionGroup]
    ) -> SpendingTransaction? {
        groups.lazy.flatMap(\.transactions).first(where: { $0.id == id })
    }

    static func updateTransactionDetails(
        transactionId: UUID,
        notes: String?,
        tags: [String],
        isImpulse: Bool,
        attachments: [TransactionAttachment],
        in groups: [SpendingTransactionGroup]
    ) -> [SpendingTransactionGroup] {
        guard let transaction = transaction(for: transactionId, in: groups) else { return groups }

        let normalizedNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sanitizedNotes = normalizedNotes?.isEmpty == true ? nil : normalizedNotes
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
            targetIds = Set(splitTransactions(for: splitGroupId, in: groups).map(\.id))
        } else {
            targetIds = [transactionId]
        }

        return groups.map { group in
            var updatedTransactions = group.transactions
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
                    notes: sanitizedNotes,
                    tags: normalizedTags,
                    attachments: attachments,
                    isExcludedFromBudget: existing.isExcludedFromBudget,
                    isRecurringCandidate: existing.isRecurringCandidate,
                    splitGroupId: existing.splitGroupId,
                    splitLabel: existing.splitLabel
                )
                didChange = true
            }

            guard didChange else { return group }
            return SpendingTransactionGroup(
                id: group.id,
                title: group.title,
                transactions: updatedTransactions
            )
        }
    }

    private static func splitLabel(from rawLabel: String) -> String? {
        let trimmed = rawLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
