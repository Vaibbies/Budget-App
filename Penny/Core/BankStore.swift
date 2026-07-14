import Foundation
import Observation

struct BankSummarySnapshot {
    let netWorthBalance: Double
    let totalAssetsBalance: Double
    let totalLiabilitiesBalance: Double
    let configuredBudgetValue: Double
    let budgetMode: BudgetMode
    let dailySpent: Double
    let dailyRemaining: Double
    let dailyBudget: Double
    let totalMonthlyBudget: Double
    let liquidCashBalance: Double
    let investedBalance: Double
    let totalDebtBalance: Double
    let safeToSpendThisMonth: Double
    let monthlyNet: Double
    let totalGoalProgress: Double
}

struct BankAccountSnapshot: Identifiable {
    let account: Account
    let effectiveBalance: Double
    let monthSpend: Double
    let monthIncome: Double
    let monthNet: Double
    let transactionCount: Int
    let investmentSummary: InvestmentPerformanceSummary

    var id: UUID { account.id }

    var hasActivity: Bool {
        if account.type == .investment {
            return investmentSummary.holdingsCount > 0
        }
        return transactionCount > 0 || monthSpend > 0 || monthIncome > 0
    }
}

@MainActor
@Observable
final class BankStore {
    private let accountsRepository: any AccountsRepository
    private let transactionsRepository: any TransactionsRepository
    private let budgetRepository: any BudgetRepository
    private let forecastRepository: any ForecastRepository
    private let investmentsRepository: any InvestmentsRepository
    private let accountsService: AccountsService
    private let budgetService: BudgetSettingsService
    private let investmentsService: InvestmentsService

    init(
        accountsRepository: any AccountsRepository,
        transactionsRepository: any TransactionsRepository,
        budgetRepository: any BudgetRepository,
        forecastRepository: any ForecastRepository,
        investmentsRepository: any InvestmentsRepository,
        accountsService: AccountsService,
        budgetService: BudgetSettingsService,
        investmentsService: InvestmentsService
    ) {
        self.accountsRepository = accountsRepository
        self.transactionsRepository = transactionsRepository
        self.budgetRepository = budgetRepository
        self.forecastRepository = forecastRepository
        self.investmentsRepository = investmentsRepository
        self.accountsService = accountsService
        self.budgetService = budgetService
        self.investmentsService = investmentsService
    }

    var visibleAccounts: [Account] { accountsRepository.visibleAccounts }
    var investmentAccounts: [Account] { investmentsRepository.investmentAccounts }
    var investmentHoldings: [InvestmentHolding] { investmentsRepository.investmentHoldings }
    var savingsGoals: [SavingsGoal] { investmentsRepository.savingsGoals }
    var cashFlowForecast: CashFlowForecast { forecastRepository.cashFlowForecast }
    var daysInCurrentMonth: Int { budgetRepository.daysInCurrentMonth }

    var summary: BankSummarySnapshot {
        BankSummarySnapshot(
            netWorthBalance: investmentsRepository.netWorthBalance,
            totalAssetsBalance: investmentsRepository.totalAssetsBalance,
            totalLiabilitiesBalance: investmentsRepository.totalLiabilitiesBalance,
            configuredBudgetValue: budgetRepository.configuredBudgetValue,
            budgetMode: budgetRepository.budgetMode,
            dailySpent: transactionsRepository.dailySpent,
            dailyRemaining: transactionsRepository.dailyRemaining,
            dailyBudget: budgetRepository.dailyBudget,
            totalMonthlyBudget: budgetRepository.totalMonthlyBudget,
            liquidCashBalance: investmentsRepository.liquidCashBalance,
            investedBalance: investmentsRepository.investedBalance,
            totalDebtBalance: investmentsRepository.totalDebtBalance,
            safeToSpendThisMonth: budgetRepository.safeToSpendThisMonth,
            monthlyNet: investmentsRepository.monthlyNet,
            totalGoalProgress: investmentsRepository.totalGoalProgress
        )
    }

    var hasInvestmentData: Bool {
        !investmentAccounts.isEmpty || !investmentHoldings.isEmpty
    }

    var overallInvestmentPerformance: InvestmentPerformanceSummary {
        investmentsRepository.investmentPerformance(forAccount: nil)
    }

    var overallPortfolioAllocation: [PortfolioAllocationSlice] {
        investmentsRepository.portfolioAllocation(forAccount: nil)
    }

    var accountSnapshots: [BankAccountSnapshot] {
        visibleAccounts.map(accountSnapshot(for:))
    }

    func accountSnapshot(for account: Account) -> BankAccountSnapshot {
        BankAccountSnapshot(
            account: account,
            effectiveBalance: investmentsRepository.effectiveBalance(for: account),
            monthSpend: transactionsRepository.monthlySpend(forAccount: account.id, inMonth: Date()),
            monthIncome: transactionsRepository.monthlyIncome(forAccount: account.id, inMonth: Date()),
            monthNet: transactionsRepository.monthlyNet(forAccount: account.id, inMonth: Date()),
            transactionCount: transactionsRepository.transactions(forAccount: account.id, inMonth: Date()).count,
            investmentSummary: investmentsRepository.investmentPerformance(forAccount: account.id)
        )
    }

    func holdings(forAccount accountId: UUID) -> [InvestmentHolding] {
        investmentsRepository.holdings(forAccount: accountId)
    }

    func investmentPerformance(forAccount accountId: UUID) -> InvestmentPerformanceSummary {
        investmentsRepository.investmentPerformance(forAccount: accountId)
    }

    func portfolioAllocation(forAccount accountId: UUID) -> [PortfolioAllocationSlice] {
        investmentsRepository.portfolioAllocation(forAccount: accountId)
    }

    func normalizedBalance(for type: AccountType, enteredBalance: Double) -> Double {
        accountsRepository.normalizedBalance(for: type, enteredBalance: enteredBalance)
    }

    func upsertAccount(_ account: Account) {
        accountsService.upsertAccount(account)
    }

    func deleteAccount(id: UUID) {
        accountsService.deleteAccount(id: id)
    }

    func setBudget(mode: BudgetMode, value: Double) {
        budgetService.setBudget(mode: mode, value: value)
    }

    func upsertInvestmentHolding(_ holding: InvestmentHolding) {
        investmentsService.upsertHolding(holding)
    }

    func deleteInvestmentHolding(id: UUID) {
        investmentsService.deleteHolding(id: id)
    }
}
