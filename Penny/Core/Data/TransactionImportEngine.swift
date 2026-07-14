import Foundation
import SwiftUI

enum TransactionImportEngine {
    struct Context {
        let defaultAccountId: UUID?
        let defaultSpendingAccountId: UUID?
        let visibleAccounts: [Account]
        let isDuplicate: (_ date: Date, _ merchant: String, _ signedAmount: Double, _ accountId: UUID?) -> Bool
        let normalizeAndApplyRules: (SpendingTransaction) -> SpendingTransaction
    }

    static func importCSVTransactions(
        from csv: String,
        context: Context
    ) -> (transactions: [(SpendingTransaction, Date)], summary: TransactionImportSummary) {
        let rows = csv
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard rows.count > 1 else {
            return ([], TransactionImportSummary(importedCount: 0, duplicateCount: 0))
        }

        let headers = parseCSVRow(rows[0]).map { $0.lowercased() }
        var importedTransactions: [(SpendingTransaction, Date)] = []
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
            let category = parseImportCategory(record["category"])
            let accountId = accountIdForImportedRecord(
                record["account"],
                defaultAccountId: context.defaultAccountId,
                defaultSpendingAccountId: context.defaultSpendingAccountId,
                visibleAccounts: context.visibleAccounts
            )

            if context.isDuplicate(parsedDate, merchant, signedAmount, accountId) {
                duplicateCount += 1
                continue
            }

            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            let transaction = context.normalizeAndApplyRules(
                SpendingTransaction(
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
                    merchantNormalized: merchant,
                    tags: ["imported"]
                )
            )

            importedTransactions.append((transaction, parsedDate))
            importedCount += 1
        }

        return (
            importedTransactions,
            TransactionImportSummary(importedCount: importedCount, duplicateCount: duplicateCount)
        )
    }

    static func parseCSVRow(_ row: String) -> [String] {
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

    static func parseImportDate(_ value: String) -> Date? {
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

    static func parseImportKind(_ rawValue: String?, amount: Double) -> TransactionKind {
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

    static func parseImportCategory(_ rawValue: String?) -> SpendingCategory {
        guard let normalized = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !normalized.isEmpty else {
            return .other
        }
        return SpendingCategory.allCases.first(where: { $0.rawValue.lowercased() == normalized }) ?? .other
    }

    static func accountIdForImportedRecord(
        _ rawValue: String?,
        defaultAccountId: UUID?,
        defaultSpendingAccountId: UUID?,
        visibleAccounts: [Account]
    ) -> UUID? {
        guard let name = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return defaultAccountId ?? defaultSpendingAccountId
        }
        return visibleAccounts.first(where: { $0.name.caseInsensitiveCompare(name) == .orderedSame })?.id
            ?? defaultAccountId
            ?? defaultSpendingAccountId
    }
}
