import Foundation

struct TransactionDataBootstrapState {
    let appMode: AppDataMode
    let budgetMode: BudgetMode
    let budgetBaseValue: Double
    let accounts: [Account]
    let investmentHoldings: [InvestmentHolding]
    let merchantRules: [MerchantRule]
    let groups: [SpendingTransactionGroup]
    let subscriptions: [RecurringSubscription]
    let manualForecastItems: [ManualForecastItem]
}

final class TransactionDataPersistence {
    static let appModeKey = "penny.app.mode"
    static let hasCompletedOnboardingKey = "penny.app.didCompleteOnboarding"

    private let groupsKey = "penny_transaction_groups"
    private let budgetModeKey = "penny_budget_mode"
    private let budgetValueKey = "penny_budget_value"
    private let legacyDailyBudgetKey = "penny_daily_budget"
    private let legacyMonthlyBudgetKey = "penny_monthly_budget"
    private let subscriptionsKey = "penny_recurring_subscriptions"
    private let accountsKey = "penny_accounts"
    private let investmentHoldingsKey = "penny_investment_holdings"
    private let merchantRulesKey = "penny_merchant_rules"
    private let manualForecastItemsKey = "penny_manual_forecast_items"
    private let manualV1ResetKey = "penny_manual_v1_reset_complete"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadBootstrapState() -> TransactionDataBootstrapState {
        migrateInitialManualResetIfNeeded()

        let savedBudgetMode = defaults.string(forKey: budgetModeKey).flatMap(BudgetMode.init(rawValue:))
        let savedBudgetValue = defaults.double(forKey: budgetValueKey)
        let legacyDailyBudget = defaults.double(forKey: legacyDailyBudgetKey)
        let legacyMonthlyBudget = defaults.double(forKey: legacyMonthlyBudgetKey)

        let budgetMode: BudgetMode
        let budgetBaseValue: Double

        if let savedBudgetMode, savedBudgetValue > 0 {
            budgetMode = savedBudgetMode
            budgetBaseValue = savedBudgetValue
        } else if legacyMonthlyBudget > 0 {
            budgetMode = .monthly
            budgetBaseValue = legacyMonthlyBudget
        } else if legacyDailyBudget > 0 {
            budgetMode = .daily
            budgetBaseValue = legacyDailyBudget
        } else {
            budgetMode = .daily
            budgetBaseValue = 0
        }

        return TransactionDataBootstrapState(
            appMode: defaults.string(forKey: Self.appModeKey).flatMap(AppDataMode.init(rawValue:)) ?? .real,
            budgetMode: budgetMode,
            budgetBaseValue: budgetBaseValue,
            accounts: load([Account].self, forKey: accountsKey) ?? [],
            investmentHoldings: load([InvestmentHolding].self, forKey: investmentHoldingsKey) ?? [],
            merchantRules: load([MerchantRule].self, forKey: merchantRulesKey) ?? TransactionData.sampleMerchantRules,
            groups: load([SpendingTransactionGroup].self, forKey: groupsKey) ?? [],
            subscriptions: load([RecurringSubscription].self, forKey: subscriptionsKey) ?? [],
            manualForecastItems: (load([ManualForecastItem].self, forKey: manualForecastItemsKey) ?? []).sorted { $0.date < $1.date }
        )
    }

    func saveAppMode(_ appMode: AppDataMode) {
        defaults.set(appMode.rawValue, forKey: Self.appModeKey)
    }

    func saveBudgetMode(_ budgetMode: BudgetMode) {
        defaults.set(budgetMode.rawValue, forKey: budgetModeKey)
    }

    func saveBudgetBaseValue(_ budgetBaseValue: Double) {
        defaults.set(budgetBaseValue, forKey: budgetValueKey)
    }

    func saveGroups(_ groups: [SpendingTransactionGroup]) {
        save(groups, forKey: groupsKey)
    }

    func saveSubscriptions(_ subscriptions: [RecurringSubscription]) {
        save(subscriptions, forKey: subscriptionsKey)
    }

    func saveAccounts(_ accounts: [Account]) {
        save(accounts, forKey: accountsKey)
    }

    func saveInvestmentHoldings(_ investmentHoldings: [InvestmentHolding]) {
        save(investmentHoldings, forKey: investmentHoldingsKey)
    }

    func saveManualForecastItems(_ manualForecastItems: [ManualForecastItem]) {
        save(manualForecastItems.sorted { $0.date < $1.date }, forKey: manualForecastItemsKey)
    }

    func saveMerchantRules(_ merchantRules: [MerchantRule]) {
        save(merchantRules, forKey: merchantRulesKey)
    }

    func markOnboardingComplete() {
        defaults.set(true, forKey: Self.hasCompletedOnboardingKey)
    }

    private func migrateInitialManualResetIfNeeded() {
        guard !defaults.bool(forKey: manualV1ResetKey) else { return }

        defaults.removeObject(forKey: groupsKey)
        defaults.removeObject(forKey: subscriptionsKey)
        defaults.removeObject(forKey: accountsKey)
        defaults.set(BudgetMode.daily.rawValue, forKey: budgetModeKey)
        defaults.set(0, forKey: budgetValueKey)
        defaults.set(true, forKey: manualV1ResetKey)
    }

    private func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let encoded = try? encoder.encode(value) else { return }
        defaults.set(encoded, forKey: key)
    }
}
