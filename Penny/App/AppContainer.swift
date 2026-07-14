import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    let data: TransactionData
    let accountsRepository: any AccountsRepository
    let transactionsRepository: any TransactionsRepository
    let budgetRepository: any BudgetRepository
    let forecastRepository: any ForecastRepository
    let recurringRepository: any RecurringRepository
    let investmentsRepository: any InvestmentsRepository
    let categorizationRepository: any CategorizationRepository
    let platform: PennyPlatform
    let session: AppSessionStore
    let transactionsService: TransactionsService
    let forecastService: ForecastService
    let merchantRulesService: MerchantRulesService
    let recurringService: RecurringManagementService
    let accountsService: AccountsService
    let budgetService: BudgetSettingsService
    let investmentsService: InvestmentsService
    let spending: SpendingStore
    let bank: BankStore
    let recurring: RecurringStore
    let maintenance: AppMaintenanceStore

    init(
        data: TransactionData,
        accountsRepository: (any AccountsRepository)? = nil,
        transactionsRepository: (any TransactionsRepository)? = nil,
        budgetRepository: (any BudgetRepository)? = nil,
        forecastRepository: (any ForecastRepository)? = nil,
        recurringRepository: (any RecurringRepository)? = nil,
        investmentsRepository: (any InvestmentsRepository)? = nil,
        categorizationRepository: (any CategorizationRepository)? = nil,
        platform: PennyPlatform? = nil,
        session: AppSessionStore? = nil,
        transactionsService: TransactionsService? = nil,
        forecastService: ForecastService? = nil,
        merchantRulesService: MerchantRulesService? = nil,
        recurringService: RecurringManagementService? = nil,
        accountsService: AccountsService? = nil,
        budgetService: BudgetSettingsService? = nil,
        investmentsService: InvestmentsService? = nil,
        spending: SpendingStore? = nil,
        bank: BankStore? = nil,
        recurring: RecurringStore? = nil,
        maintenance: AppMaintenanceStore? = nil
    ) {
        self.data = data
        let resolvedAccountsRepository = accountsRepository ?? LocalAccountsRepository(data: data)
        let resolvedTransactionsRepository = transactionsRepository ?? LocalTransactionsRepository(data: data)
        let resolvedBudgetRepository = budgetRepository ?? LocalBudgetRepository(data: data)
        let resolvedForecastRepository = forecastRepository ?? LocalForecastRepository(data: data)
        let resolvedRecurringRepository = recurringRepository ?? LocalRecurringRepository(data: data)
        let resolvedInvestmentsRepository = investmentsRepository ?? LocalInvestmentsRepository(data: data)
        let resolvedCategorizationRepository = categorizationRepository ?? LocalCategorizationRepository(data: data)
        self.accountsRepository = resolvedAccountsRepository
        self.transactionsRepository = resolvedTransactionsRepository
        self.budgetRepository = resolvedBudgetRepository
        self.forecastRepository = resolvedForecastRepository
        self.recurringRepository = resolvedRecurringRepository
        self.investmentsRepository = resolvedInvestmentsRepository
        self.categorizationRepository = resolvedCategorizationRepository

        let resolvedTransactionsService = transactionsService ?? TransactionsService(data: data)
        let resolvedForecastService = forecastService ?? ForecastService(data: data)
        let resolvedMerchantRulesService = merchantRulesService ?? MerchantRulesService(data: data)
        let resolvedRecurringService = recurringService ?? RecurringManagementService(data: data)
        let resolvedAccountsService = accountsService ?? AccountsService(data: data)
        let resolvedBudgetService = budgetService ?? BudgetSettingsService(data: data)
        let resolvedInvestmentsService = investmentsService ?? InvestmentsService(data: data)
        self.transactionsService = resolvedTransactionsService
        self.forecastService = resolvedForecastService
        self.merchantRulesService = resolvedMerchantRulesService
        self.recurringService = resolvedRecurringService
        self.accountsService = resolvedAccountsService
        self.budgetService = resolvedBudgetService
        self.investmentsService = resolvedInvestmentsService

        let resolvedPlatform = platform ?? PennyPlatform(
            userHouseholdService: LocalUserHouseholdService(),
            accountTransactionService: LocalAccountTransactionService(
                accountsRepository: resolvedAccountsRepository,
                transactionsRepository: resolvedTransactionsRepository,
                investmentsRepository: resolvedInvestmentsRepository
            ),
            budgetingService: LocalBudgetingService(
                budgetRepository: resolvedBudgetRepository,
                transactionsRepository: resolvedTransactionsRepository
            ),
            recurringService: LocalRecurringService(recurringRepository: resolvedRecurringRepository),
            categorizationService: LocalCategorizationRulesService(categorizationRepository: resolvedCategorizationRepository),
            investmentService: LocalInvestmentService(investmentsRepository: resolvedInvestmentsRepository),
            notificationService: LocalNotificationService(),
            aiAssistantService: LocalAIAssistantService()
        )
        self.platform = resolvedPlatform
        self.session = session ?? AppSessionStore(data: data)
        let resolvedSpending = spending ?? SpendingStore(
            accountsRepository: resolvedAccountsRepository,
            transactionsRepository: resolvedTransactionsRepository,
            recurringRepository: resolvedRecurringRepository,
            forecastRepository: resolvedForecastRepository,
            budgetRepository: resolvedBudgetRepository,
            investmentsRepository: resolvedInvestmentsRepository,
            transactionsService: resolvedTransactionsService,
            recurringService: resolvedRecurringService,
            forecastService: resolvedForecastService,
            merchantRulesService: resolvedMerchantRulesService
        )
        let resolvedRecurring = recurring ?? RecurringStore(
            repository: resolvedRecurringRepository,
            recurringService: resolvedRecurringService
        )
        self.spending = resolvedSpending
        self.bank = bank ?? BankStore(
            accountsRepository: resolvedAccountsRepository,
            transactionsRepository: resolvedTransactionsRepository,
            budgetRepository: resolvedBudgetRepository,
            forecastRepository: resolvedForecastRepository,
            investmentsRepository: resolvedInvestmentsRepository,
            accountsService: resolvedAccountsService,
            budgetService: resolvedBudgetService,
            investmentsService: resolvedInvestmentsService
        )
        self.recurring = resolvedRecurring
        self.maintenance = maintenance ?? AppMaintenanceStore(
            spending: resolvedSpending,
            recurring: resolvedRecurring
        )
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
