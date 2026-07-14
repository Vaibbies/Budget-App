import Foundation
import Observation

@MainActor
@Observable
final class RecurringStore {
    private let repository: any RecurringRepository
    private let recurringService: RecurringManagementService

    init(
        repository: any RecurringRepository,
        recurringService: RecurringManagementService
    ) {
        self.repository = repository
        self.recurringService = recurringService
    }

    var subscriptions: [RecurringSubscription] { repository.subscriptions }

    var activeSubscriptions: [RecurringSubscription] {
        repository.subscriptions.filter { $0.status == .active }
    }

    func subscriptions(status: RecurringStatus) -> [RecurringSubscription] {
        repository.subscriptions.filter { $0.status == status }
    }

    func addSubscription(
        _ sub: RecurringSubscription,
        logInitialTransaction: Bool = true,
        initialTransactionDate: Date = Date()
    ) {
        recurringService.addSubscription(
            sub,
            logInitialTransaction: logInitialTransaction,
            initialTransactionDate: initialTransactionDate
        )
    }

    func updateStatus(_ id: UUID, status: RecurringStatus) {
        recurringService.updateStatus(id, status: status)
    }

    func removeSubscription(id: UUID) {
        recurringService.removeSubscription(id: id)
    }

    func syncRecurringTransactions() {
        recurringService.syncRecurringTransactions()
    }
}
