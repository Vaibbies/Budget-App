import Foundation
import SwiftUI

struct TransactionDerivedMetrics {
    let dayKey: Date
    let monthKey: Date
    let previousMonthKey: Date
    let allTransactions: [SpendingTransaction]
    let budgetableTransactions: [SpendingTransaction]
    let incomeTransactions: [SpendingTransaction]
    let transferTransactions: [SpendingTransaction]
    let excludedCategories: Set<SpendingCategory>
    let todayTransactions: [SpendingTransaction]
    let monthToDateTransactions: [SpendingTransaction]
    let groupTitleByTransactionId: [UUID: String]
    let dateByTransactionId: [UUID: Date]
    let currentMonthCategorySpend: [SpendingCategory: Double]
    let previousMonthCategorySpend: [SpendingCategory: Double]
    let totalSpent: Double
    let transactionCount: Int
    let monthlySpent: Double
    let monthlyIncome: Double
    let cashFlowForecast: CashFlowForecast
    let totalMonthlyBudget: Double
    let safeToSpendThisMonth: Double
    let categoryTotals: [CategoryData]
    let topCategories: [CategoryData]
    let recentTransactions: [SpendingTransaction]
    let dailySpent: Double
    let dailyRemaining: Double
}

enum TransactionAnalyticsEngine {
    struct Input {
        let referenceDate: Date
        let groups: [SpendingTransactionGroup]
        let budgetCategories: [BudgetCategory]
        let visibleAccounts: [Account]
        let effectiveBalance: (Account) -> Double
        let dailyBudget: Double
        let derivedMonthlyBudget: Double
        let subscriptions: [RecurringSubscription]
        let manualForecastItems: [ManualForecastItem]
        let resolveGroupDate: (String, Date) -> Date?
        let normalizeMerchant: (String) -> String
    }

    struct ForecastInput {
        let referenceDate: Date
        let horizonDays: Int
        let startingCash: Double
        let subscriptions: [RecurringSubscription]
        let manualForecastItems: [ManualForecastItem]
        let incomeTransactions: [SpendingTransaction]
        let transactionDates: [UUID: Date]
        let normalizeMerchant: (String) -> String
    }

    static func deriveMetrics(_ input: Input) -> TransactionDerivedMetrics {
        let calendar = Calendar.current
        let dayKey = calendar.startOfDay(for: input.referenceDate)
        let monthKey = calendar.dateInterval(of: .month, for: input.referenceDate)?.start ?? dayKey
        let previousMonthKey = calendar.date(byAdding: .month, value: -1, to: monthKey) ?? monthKey

        let excludedCategories = Set(input.budgetCategories.filter(\.isExcluded).map(\.category))
        let visibleLiquidCashBalance = input.visibleAccounts
            .filter { $0.type == .checking || $0.type == .savings || $0.type == .cash }
            .reduce(0.0) { $0 + input.effectiveBalance($1) }

        var allTransactions: [SpendingTransaction] = []
        var groupTitleByTransactionId: [UUID: String] = [:]
        var dateByTransactionId: [UUID: Date] = [:]
        var todayTransactions: [SpendingTransaction] = []
        var monthToDateTransactions: [SpendingTransaction] = []
        var previousMonthTransactions: [SpendingTransaction] = []

        for group in input.groups {
            let resolvedDate = input.resolveGroupDate(group.title, input.referenceDate)

            for transaction in group.transactions {
                allTransactions.append(transaction)
                groupTitleByTransactionId[transaction.id] = group.title

                guard let resolvedDate else { continue }
                let normalizedDate = calendar.startOfDay(for: resolvedDate)
                dateByTransactionId[transaction.id] = normalizedDate

                if calendar.isDate(normalizedDate, inSameDayAs: dayKey) {
                    todayTransactions.append(transaction)
                }

                if calendar.isDate(normalizedDate, equalTo: monthKey, toGranularity: .month) {
                    monthToDateTransactions.append(transaction)
                } else if calendar.isDate(normalizedDate, equalTo: previousMonthKey, toGranularity: .month) {
                    previousMonthTransactions.append(transaction)
                }
            }
        }

        let budgetableTransactions = allTransactions.filter {
            $0.kind == .spending && !$0.isExcludedFromBudget && !excludedCategories.contains($0.category)
        }
        let incomeTransactions = allTransactions.filter { $0.kind == .income }
        let transferTransactions = allTransactions.filter { $0.kind == .transfer }

        let currentMonthCategorySpend = monthToDateTransactions.reduce(into: [SpendingCategory: Double]()) { result, transaction in
            guard transaction.kind == .spending else { return }
            guard !transaction.isExcludedFromBudget else { return }
            guard !excludedCategories.contains(transaction.category) else { return }
            result[transaction.category, default: 0] += transaction.amountValue
        }

        let previousMonthCategorySpend = previousMonthTransactions.reduce(into: [SpendingCategory: Double]()) { result, transaction in
            guard transaction.kind == .spending else { return }
            guard !transaction.isExcludedFromBudget else { return }
            guard !excludedCategories.contains(transaction.category) else { return }
            result[transaction.category, default: 0] += transaction.amountValue
        }

        let totalSpent = budgetableTransactions.reduce(0) { $0 + $1.amountValue }
        let transactionCount = budgetableTransactions.count
        let monthlySpent = currentMonthCategorySpend.values.reduce(0, +)
        let monthlyIncome = monthToDateTransactions
            .filter { $0.kind == .income }
            .reduce(0) { $0 + $1.amountSignedValue }

        let totalMonthlyBudget: Double = {
            let categoryTotal = input.budgetCategories
                .filter { !$0.isExcluded }
                .reduce(0) { $0 + $1.monthlyBudget }
            return input.derivedMonthlyBudget > 0 ? input.derivedMonthlyBudget : categoryTotal
        }()

        let cashFlowForecast = buildCashFlowForecast(
            ForecastInput(
                referenceDate: input.referenceDate,
                horizonDays: 30,
                startingCash: visibleLiquidCashBalance,
                subscriptions: input.subscriptions,
                manualForecastItems: input.manualForecastItems,
                incomeTransactions: incomeTransactions,
                transactionDates: dateByTransactionId,
                normalizeMerchant: input.normalizeMerchant
            )
        )

        let safeToSpendThisMonth: Double = {
            guard visibleLiquidCashBalance > 0 else { return 0 }
            let remainingBudget = max(totalMonthlyBudget - monthlySpent, 0)
            let cashConstrainedCapacity = max(cashFlowForecast.projectedEndOfMonthCash, 0)
            return min(remainingBudget, cashConstrainedCapacity)
        }()

        let categoryTotals = currentMonthCategorySpend
            .sorted { $0.value > $1.value }
            .map { CategoryData(name: $0.key.rawValue, color: $0.key.color, amount: $0.value, total: totalSpent) }

        let dailySpent = todayTransactions.reduce(0) { $0 + $1.amountValue }
        let dailyRemaining: Double = {
            let remainingBudget = max(input.dailyBudget - dailySpent, 0)
            if visibleLiquidCashBalance > 0 {
                return min(remainingBudget, max(visibleLiquidCashBalance - dailySpent, 0))
            }
            return remainingBudget
        }()

        return TransactionDerivedMetrics(
            dayKey: dayKey,
            monthKey: monthKey,
            previousMonthKey: previousMonthKey,
            allTransactions: allTransactions,
            budgetableTransactions: budgetableTransactions,
            incomeTransactions: incomeTransactions,
            transferTransactions: transferTransactions,
            excludedCategories: excludedCategories,
            todayTransactions: todayTransactions,
            monthToDateTransactions: monthToDateTransactions,
            groupTitleByTransactionId: groupTitleByTransactionId,
            dateByTransactionId: dateByTransactionId,
            currentMonthCategorySpend: currentMonthCategorySpend,
            previousMonthCategorySpend: previousMonthCategorySpend,
            totalSpent: totalSpent,
            transactionCount: transactionCount,
            monthlySpent: monthlySpent,
            monthlyIncome: monthlyIncome,
            cashFlowForecast: cashFlowForecast,
            totalMonthlyBudget: totalMonthlyBudget,
            safeToSpendThisMonth: safeToSpendThisMonth,
            categoryTotals: categoryTotals,
            topCategories: Array(categoryTotals.prefix(4)),
            recentTransactions: Array(allTransactions.prefix(3)),
            dailySpent: dailySpent,
            dailyRemaining: dailyRemaining
        )
    }

    static func buildCashFlowForecast(_ input: ForecastInput) -> CashFlowForecast {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: input.referenceDate)
        let monthEnd = calendar.dateInterval(of: .month, for: input.referenceDate)?.end ?? input.referenceDate
        let horizonEnd = calendar.date(byAdding: .day, value: input.horizonDays, to: startOfToday) ?? input.referenceDate
        let eventCutoff = min(monthEnd, horizonEnd)

        let billEvents: [CashFlowForecastEvent] = input.subscriptions.compactMap { subscription in
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

        let manualEvents: [CashFlowForecastEvent] = input.manualForecastItems.compactMap { item in
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

        let incomeEvents = inferredIncomeForecastEvents(
            referenceDate: input.referenceDate,
            cutoff: eventCutoff,
            incomeTransactions: input.incomeTransactions,
            transactionDates: input.transactionDates,
            normalizeMerchant: input.normalizeMerchant
        )
        let events = (billEvents + manualEvents + incomeEvents).sorted { lhs, rhs in
            if lhs.date != rhs.date { return lhs.date < rhs.date }
            if lhs.kind != rhs.kind { return lhs.kind == .income }
            return lhs.title < rhs.title
        }

        let expectedIncome = events.filter { $0.kind == .income }.reduce(0) { $0 + $1.amount }
        let expectedBills = events.filter { $0.kind == .bill }.reduce(0) { $0 + $1.amount }
        let projectedEndOfMonthCash = input.startingCash + expectedIncome - expectedBills

        return CashFlowForecast(
            startingCash: input.startingCash,
            events: events,
            projectedEndOfMonthCash: projectedEndOfMonthCash,
            expectedIncome: expectedIncome,
            expectedBills: expectedBills
        )
    }

    private static func inferredIncomeForecastEvents(
        referenceDate: Date,
        cutoff: Date,
        incomeTransactions: [SpendingTransaction],
        transactionDates: [UUID: Date],
        normalizeMerchant: (String) -> String
    ) -> [CashFlowForecastEvent] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: incomeTransactions) {
            ($0.merchantNormalized ?? normalizeMerchant($0.title)).lowercased()
        }

        return groups.compactMap { merchant, transactions in
            let datedTransactions = transactions.compactMap { transaction -> (Date, SpendingTransaction)? in
                guard let date = transactionDates[transaction.id] else { return nil }
                return (date, transaction)
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
}
