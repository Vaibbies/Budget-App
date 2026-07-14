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
    private let data: any BankDataStore
    private let mutations: TransactionMutationService

    init(
        data: any BankDataStore,
        mutations: TransactionMutationService
    ) {
        self.data = data
        self.mutations = mutations
    }

    var visibleAccounts: [Account] { data.visibleAccounts }
    var investmentAccounts: [Account] { data.investmentAccounts }
    var investmentHoldings: [InvestmentHolding] { data.investmentHoldings }
    var savingsGoals: [SavingsGoal] { data.savingsGoals }
    var cashFlowForecast: CashFlowForecast { data.cashFlowForecast }
    var daysInCurrentMonth: Int { data.daysInCurrentMonth }

    var summary: BankSummarySnapshot {
        BankSummarySnapshot(
            netWorthBalance: data.netWorthBalance,
            totalAssetsBalance: data.totalAssetsBalance,
            totalLiabilitiesBalance: data.totalLiabilitiesBalance,
            configuredBudgetValue: data.configuredBudgetValue,
            budgetMode: data.budgetMode,
            dailySpent: data.dailySpent,
            dailyRemaining: data.dailyRemaining,
            dailyBudget: data.dailyBudget,
            totalMonthlyBudget: data.totalMonthlyBudget,
            liquidCashBalance: data.liquidCashBalance,
            investedBalance: data.investedBalance,
            totalDebtBalance: data.totalDebtBalance,
            safeToSpendThisMonth: data.safeToSpendThisMonth,
            monthlyNet: data.monthlyNet,
            totalGoalProgress: data.totalGoalProgress
        )
    }

    var hasInvestmentData: Bool {
        !investmentAccounts.isEmpty || !investmentHoldings.isEmpty
    }

    var overallInvestmentPerformance: InvestmentPerformanceSummary {
        data.investmentPerformance(forAccount: nil)
    }

    var overallPortfolioAllocation: [PortfolioAllocationSlice] {
        data.portfolioAllocation(forAccount: nil)
    }

    var accountSnapshots: [BankAccountSnapshot] {
        visibleAccounts.map(accountSnapshot(for:))
    }

    func accountSnapshot(for account: Account) -> BankAccountSnapshot {
        BankAccountSnapshot(
            account: account,
            effectiveBalance: data.effectiveBalance(for: account),
            monthSpend: data.monthlySpend(forAccount: account.id, inMonth: Date()),
            monthIncome: data.monthlyIncome(forAccount: account.id, inMonth: Date()),
            monthNet: data.monthlyNet(forAccount: account.id, inMonth: Date()),
            transactionCount: data.transactions(forAccount: account.id, inMonth: Date()).count,
            investmentSummary: data.investmentPerformance(forAccount: account.id)
        )
    }

    func holdings(forAccount accountId: UUID) -> [InvestmentHolding] {
        data.holdings(forAccount: accountId)
    }

    func investmentPerformance(forAccount accountId: UUID) -> InvestmentPerformanceSummary {
        data.investmentPerformance(forAccount: accountId)
    }

    func portfolioAllocation(forAccount accountId: UUID) -> [PortfolioAllocationSlice] {
        data.portfolioAllocation(forAccount: accountId)
    }

    func normalizedBalance(for type: AccountType, enteredBalance: Double) -> Double {
        data.normalizedBalance(for: type, enteredBalance: enteredBalance)
    }

    func upsertAccount(_ account: Account) {
        mutations.upsertAccount(account)
    }

    func deleteAccount(id: UUID) {
        mutations.deleteAccount(id: id)
    }

    func setBudget(mode: BudgetMode, value: Double) {
        mutations.setBudget(mode: mode, value: value)
    }

    func upsertInvestmentHolding(_ holding: InvestmentHolding) {
        mutations.upsertInvestmentHolding(holding)
    }

    func deleteInvestmentHolding(id: UUID) {
        mutations.deleteInvestmentHolding(id: id)
    }
}
