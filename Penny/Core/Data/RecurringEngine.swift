import Foundation
import SwiftUI

struct RecurringLedgerEntry {
    let transaction: SpendingTransaction
    let date: Date
}

struct RecurringSyncResult {
    let subscriptions: [RecurringSubscription]
    let generatedEntries: [RecurringLedgerEntry]
    let didMutateSubscriptions: Bool
}

enum RecurringEngine {
    static func syncSubscriptions(
        _ subscriptions: [RecurringSubscription],
        asOf now: Date = Date(),
        defaultAccountId: UUID?,
        normalizeMerchant: (String) -> String
    ) -> RecurringSyncResult {
        guard !subscriptions.isEmpty else {
            return RecurringSyncResult(subscriptions: subscriptions, generatedEntries: [], didMutateSubscriptions: false)
        }

        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: now)
        var updated = subscriptions
        var generatedEntries: [RecurringLedgerEntry] = []
        var didMutateSubscriptions = false

        for index in updated.indices {
            let subscription = updated[index]
            guard subscription.status == .active else { continue }
            guard let epoch = subscription.nextBillingEpoch else { continue }
            guard subscription.frequencyKey != nil || ((subscription.frequencyDays ?? 0) > 0) else { continue }

            var nextDate = Date(timeIntervalSince1970: epoch)
            var addedAny = false

            while calendar.startOfDay(for: nextDate) <= todayStart {
                generatedEntries.append(
                    RecurringLedgerEntry(
                        transaction: makeTransaction(
                            for: subscription,
                            date: nextDate,
                            defaultAccountId: defaultAccountId,
                            normalizeMerchant: normalizeMerchant
                        ),
                        date: nextDate
                    )
                )
                addedAny = true
                nextDate = advanceRecurringDate(
                    current: nextDate,
                    frequencyKey: subscription.frequencyKey,
                    fallbackDays: subscription.frequencyDays
                )
            }

            if addedAny {
                didMutateSubscriptions = true
                updated[index] = RecurringSubscription(
                    id: subscription.id,
                    name: subscription.name,
                    plan: subscription.plan,
                    price: subscription.price,
                    iconName: subscription.iconName,
                    iconColor: subscription.iconColor,
                    bgColor: subscription.bgColor,
                    nextBilling: billingDisplayString(for: nextDate),
                    frequencyDays: subscription.frequencyDays,
                    frequencyKey: subscription.frequencyKey,
                    nextBillingEpoch: nextDate.timeIntervalSince1970,
                    merchantMatchPattern: subscription.merchantMatchPattern,
                    expectedAmountMin: subscription.expectedAmountMin,
                    expectedAmountMax: subscription.expectedAmountMax,
                    linkedTransactionIds: subscription.linkedTransactionIds,
                    status: subscription.status
                )
            }
        }

        return RecurringSyncResult(
            subscriptions: updated,
            generatedEntries: generatedEntries,
            didMutateSubscriptions: didMutateSubscriptions
        )
    }

    static func billingDisplayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    static func recurringTimeString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    static func dayLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }

    static func advanceRecurringDate(current: Date, frequencyKey: String?, fallbackDays: Int?) -> Date {
        let calendar = Calendar.current

        switch frequencyKey {
        case "weekly":
            return calendar.date(byAdding: .day, value: 7, to: current) ?? current
        case "monthly":
            return calendar.date(byAdding: .month, value: 1, to: current) ?? current
        case "quarterly":
            return calendar.date(byAdding: .month, value: 3, to: current) ?? current
        case "biannual":
            return calendar.date(byAdding: .month, value: 6, to: current) ?? current
        case "annual":
            return calendar.date(byAdding: .year, value: 1, to: current) ?? current
        default:
            let days = max(fallbackDays ?? 0, 1)
            return calendar.date(byAdding: .day, value: days, to: current) ?? current.addingTimeInterval(Double(days) * 86_400)
        }
    }

    static func makeTransaction(
        for subscription: RecurringSubscription,
        date: Date,
        defaultAccountId: UUID?,
        normalizeMerchant: (String) -> String
    ) -> SpendingTransaction {
        SpendingTransaction(
            icon: subscription.iconName.contains(".") ? subscription.iconName : "music.note",
            title: subscription.name,
            subtitle: subscription.plan ?? "Subscription",
            time: recurringTimeString(for: date),
            amount: "-$\(String(format: "%.2f", subscription.price))",
            isImpulse: false,
            iconColor: SpendingCategory.subscriptions.color,
            bgColor: SpendingCategory.subscriptions.color.opacity(0.1),
            borderColor: SpendingCategory.subscriptions.color.opacity(0.2),
            category: .subscriptions,
            accountId: defaultAccountId,
            kind: .spending,
            merchantRaw: subscription.name,
            merchantNormalized: normalizeMerchant(subscription.merchantMatchPattern ?? subscription.name),
            tags: ["recurring"],
            isRecurringCandidate: true
        )
    }
}
