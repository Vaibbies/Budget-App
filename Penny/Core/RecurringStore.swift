import Foundation
import Observation

@MainActor
@Observable
final class RecurringStore {
    private let data: any RecurringDataStore
    private let mutations: TransactionMutationService

    init(
        data: any RecurringDataStore,
        mutations: TransactionMutationService
    ) {
        self.data = data
        self.mutations = mutations
    }

    var subscriptions: [RecurringSubscription] { data.subscriptions }

    var activeSubscriptions: [RecurringSubscription] {
        data.subscriptions.filter { $0.status == .active }
    }

    func subscriptions(status: RecurringStatus) -> [RecurringSubscription] {
        data.subscriptions.filter { $0.status == status }
    }

    func addSubscription(
        _ sub: RecurringSubscription,
        logInitialTransaction: Bool = true,
        initialTransactionDate: Date = Date()
    ) {
        mutations.addSubscription(
            sub,
            logInitialTransaction: logInitialTransaction,
            initialTransactionDate: initialTransactionDate
        )
    }

    func updateStatus(_ id: UUID, status: RecurringStatus) {
        mutations.updateRecurringStatus(id, status: status)
    }

    func removeSubscription(id: UUID) {
        mutations.removeSubscription(id: id)
    }

    func syncRecurringTransactions() {
        mutations.syncRecurringTransactions()
    }
}
