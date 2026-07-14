import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    static let preview = AppContainer(data: TransactionData.shared)

    let data: TransactionData
    let platform: PennyPlatform
    let session: AppSessionStore
    let mutations: TransactionMutationService
    let spending: SpendingStore
    let bank: BankStore
    let recurring: RecurringStore
    let maintenance: AppMaintenanceStore

    init(
        data: TransactionData,
        platform: PennyPlatform? = nil,
        session: AppSessionStore? = nil,
        mutations: TransactionMutationService? = nil,
        spending: SpendingStore? = nil,
        bank: BankStore? = nil,
        recurring: RecurringStore? = nil,
        maintenance: AppMaintenanceStore? = nil
    ) {
        self.data = data
        let resolvedPlatform = platform ?? PennyPlatform(data: data)
        self.platform = resolvedPlatform
        self.session = session ?? AppSessionStore(data: data)
        let resolvedMutations = mutations ?? TransactionMutationService(data: data)
        self.mutations = resolvedMutations
        let resolvedSpending = spending ?? SpendingStore(data: data, mutations: resolvedMutations)
        let resolvedRecurring = recurring ?? RecurringStore(data: data, mutations: resolvedMutations)
        self.spending = resolvedSpending
        self.bank = bank ?? BankStore(data: data, mutations: resolvedMutations)
        self.recurring = resolvedRecurring
        self.maintenance = maintenance ?? AppMaintenanceStore(
            spending: resolvedSpending,
            recurring: resolvedRecurring
        )
    }

    convenience init() {
        self.init(data: TransactionData.shared)
    }
}

@MainActor
@Observable
final class AppSessionStore {
    enum StartupState: Equatable {
        case onboarding
        case activating(AppDataMode)
        case active
    }

    private let data: any AppSessionDataStore
    private let defaults: UserDefaults

    var startupState: StartupState
    var selectedMode: AppDataMode {
        data.appMode
    }

    init(
        data: any AppSessionDataStore,
        defaults: UserDefaults = .standard
    ) {
        self.data = data
        self.defaults = defaults
        self.startupState = defaults.bool(forKey: TransactionData.hasCompletedOnboardingKey) ? .active : .onboarding
    }

    var hasCompletedOnboarding: Bool {
        startupState == .active
    }

    func completeOnboarding(with mode: AppDataMode) {
        startupState = .activating(mode)
        Task { @MainActor in
            await Task.yield()
            data.activateMode(mode)
            defaults.set(true, forKey: TransactionData.hasCompletedOnboardingKey)
            startupState = .active
        }
    }

    func resetToOnboarding() {
        defaults.set(false, forKey: TransactionData.hasCompletedOnboardingKey)
        startupState = .onboarding
    }
}
