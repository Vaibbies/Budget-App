import Foundation
import SwiftUI

enum TransactionRulesEngine {
    struct Context {
        let merchantRules: [MerchantRule]
        let allTransactions: [SpendingTransaction]
        let defaultAccountId: UUID?
        let normalizeMerchant: (String) -> String
    }

    static func normalizeMerchant(_ merchant: String) -> String {
        merchant
            .uppercased()
            .replacingOccurrences(of: #"^(SQ \*|TST\*|PAYPAL \*|APPLE\.COM/BILL )"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+\d{3,}$"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"[^A-Z0-9& ]"#, with: "", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }

    static func applyMerchantRules(
        to transaction: SpendingTransaction,
        context: Context
    ) -> SpendingTransaction {
        guard let matchedRule = context.merchantRules.first(where: { rule in
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
            accountId: transaction.accountId ?? context.defaultAccountId,
            kind: transaction.kind,
            merchantRaw: transaction.merchantRaw ?? transaction.title,
            merchantNormalized: matchedRule.merchantDisplayName ?? context.normalizeMerchant(transaction.merchantRaw ?? transaction.title),
            notes: transaction.notes,
            tags: transaction.tags,
            attachments: transaction.attachments,
            isExcludedFromBudget: transaction.isExcludedFromBudget,
            isRecurringCandidate: transaction.isRecurringCandidate || matchedRule.recurringHint,
            splitGroupId: transaction.splitGroupId,
            splitLabel: transaction.splitLabel
        )
    }

    static func normalizeAndApplyRules(
        to transaction: SpendingTransaction,
        context: Context
    ) -> SpendingTransaction {
        let normalizedMerchant = context.normalizeMerchant(transaction.merchantRaw ?? transaction.title)
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
            accountId: transaction.accountId ?? context.defaultAccountId,
            kind: transaction.kind,
            merchantRaw: transaction.merchantRaw ?? transaction.title,
            merchantNormalized: normalizedMerchant,
            notes: transaction.notes,
            tags: transaction.tags,
            attachments: transaction.attachments,
            isExcludedFromBudget: transaction.isExcludedFromBudget,
            isRecurringCandidate: transaction.isRecurringCandidate || detectRecurringCandidate(for: normalizedMerchant, allTransactions: context.allTransactions, normalizeMerchant: context.normalizeMerchant),
            splitGroupId: transaction.splitGroupId,
            splitLabel: transaction.splitLabel
        )
        return applyMerchantRules(to: normalized, context: context)
    }

    static func upsertRule(
        into merchantRules: [MerchantRule],
        matchPattern: String,
        categoryOverride: SpendingCategory?,
        merchantDisplayName: String?,
        recurringHint: Bool
    ) -> [MerchantRule] {
        let normalizedPattern = matchPattern.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedPattern.isEmpty else { return merchantRules }

        let updatedRule = MerchantRule(
            id: merchantRules.first(where: {
                $0.matchPattern.caseInsensitiveCompare(normalizedPattern) == .orderedSame
            })?.id ?? UUID(),
            matchPattern: normalizedPattern,
            categoryOverride: categoryOverride,
            merchantDisplayName: merchantDisplayName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            recurringHint: recurringHint
        )

        var updatedRules = merchantRules
        if let index = updatedRules.firstIndex(where: {
            $0.matchPattern.caseInsensitiveCompare(normalizedPattern) == .orderedSame
        }) {
            updatedRules[index] = updatedRule
        } else {
            updatedRules.append(updatedRule)
        }
        return updatedRules
    }

    static func detectRecurringCandidate(
        for merchant: String,
        allTransactions: [SpendingTransaction],
        normalizeMerchant: (String) -> String
    ) -> Bool {
        let recurringMatches = allTransactions.filter {
            ($0.merchantNormalized ?? normalizeMerchant($0.title)) == merchant
        }
        return recurringMatches.count >= 2
    }

    static func detectRecurringCandidates(
        allTransactions: [SpendingTransaction],
        normalizeMerchant: (String) -> String
    ) -> [String] {
        Dictionary(grouping: allTransactions) {
            $0.merchantNormalized ?? normalizeMerchant($0.title)
        }
        .filter { _, txns in txns.count >= 2 }
        .keys
        .sorted()
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
