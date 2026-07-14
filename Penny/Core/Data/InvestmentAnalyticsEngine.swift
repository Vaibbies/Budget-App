import Foundation

enum InvestmentAnalyticsEngine {
    static func holdings(
        forAccount accountId: UUID,
        in holdings: [InvestmentHolding]
    ) -> [InvestmentHolding] {
        holdings
            .filter { $0.accountId == accountId }
            .sorted { lhs, rhs in
                if lhs.marketValue != rhs.marketValue {
                    return lhs.marketValue > rhs.marketValue
                }
                return lhs.symbol < rhs.symbol
            }
    }

    static func performance(
        forAccount accountId: UUID? = nil,
        holdings: [InvestmentHolding]
    ) -> InvestmentPerformanceSummary {
        let scopedHoldings: [InvestmentHolding]
        if let accountId {
            scopedHoldings = self.holdings(forAccount: accountId, in: holdings)
        } else {
            scopedHoldings = holdings
        }

        let marketValue = scopedHoldings.reduce(0) { $0 + $1.marketValue }
        let costBasis = scopedHoldings.reduce(0) { $0 + $1.costBasis }
        let gainLoss = marketValue - costBasis
        let gainLossPercent = costBasis == 0 ? 0 : gainLoss / costBasis

        return InvestmentPerformanceSummary(
            marketValue: marketValue,
            costBasis: costBasis,
            gainLoss: gainLoss,
            gainLossPercent: gainLossPercent,
            holdingsCount: scopedHoldings.count
        )
    }

    static func allocation(
        forAccount accountId: UUID? = nil,
        holdings: [InvestmentHolding]
    ) -> [PortfolioAllocationSlice] {
        let scopedHoldings: [InvestmentHolding]
        if let accountId {
            scopedHoldings = self.holdings(forAccount: accountId, in: holdings)
        } else {
            scopedHoldings = holdings
        }

        let total = scopedHoldings.reduce(0) { $0 + $1.marketValue }
        guard total > 0 else { return [] }

        let grouped = Dictionary(grouping: scopedHoldings, by: \.assetClass)
        return grouped
            .map { assetClass, holdings in
                let marketValue = holdings.reduce(0) { $0 + $1.marketValue }
                return PortfolioAllocationSlice(
                    assetClass: assetClass,
                    marketValue: marketValue,
                    percentage: marketValue / total
                )
            }
            .sorted { $0.marketValue > $1.marketValue }
    }

    static func effectiveBalance(
        for account: Account,
        holdings: [InvestmentHolding]
    ) -> Double {
        guard account.type == .investment else { return account.balance }
        let summary = performance(forAccount: account.id, holdings: holdings)
        return summary.holdingsCount > 0 ? summary.marketValue : account.balance
    }

    static func visibleAccounts(from accounts: [Account]) -> [Account] {
        accounts.filter { !$0.isHidden }
    }

    static func liquidCashBalance(
        accounts: [Account],
        holdings: [InvestmentHolding]
    ) -> Double {
        visibleAccounts(from: accounts)
            .filter { $0.type == .checking || $0.type == .savings || $0.type == .cash }
            .reduce(0) { $0 + effectiveBalance(for: $1, holdings: holdings) }
    }

    static func investedBalance(
        accounts: [Account],
        holdings: [InvestmentHolding]
    ) -> Double {
        let holdingsBacked = performance(holdings: holdings).marketValue
        if holdingsBacked > 0 {
            return holdingsBacked
        }

        return visibleAccounts(from: accounts)
            .filter { $0.type == .investment }
            .reduce(0) { $0 + effectiveBalance(for: $1, holdings: holdings) }
    }

    static func totalDebtBalance(
        accounts: [Account],
        holdings: [InvestmentHolding]
    ) -> Double {
        visibleAccounts(from: accounts)
            .filter { $0.type == .creditCard || $0.type == .loan }
            .reduce(0) { $0 + abs(effectiveBalance(for: $1, holdings: holdings)) }
    }

    static func totalAssetsBalance(
        accounts: [Account],
        holdings: [InvestmentHolding]
    ) -> Double {
        visibleAccounts(from: accounts)
            .filter { effectiveBalance(for: $0, holdings: holdings) >= 0 }
            .reduce(0) { $0 + effectiveBalance(for: $1, holdings: holdings) }
    }

    static func totalLiabilitiesBalance(
        accounts: [Account],
        holdings: [InvestmentHolding]
    ) -> Double {
        visibleAccounts(from: accounts)
            .filter { effectiveBalance(for: $0, holdings: holdings) < 0 }
            .reduce(0) { $0 + abs(effectiveBalance(for: $1, holdings: holdings)) }
    }

    static func netWorthBalance(
        accounts: [Account],
        holdings: [InvestmentHolding]
    ) -> Double {
        totalAssetsBalance(accounts: accounts, holdings: holdings)
            - totalLiabilitiesBalance(accounts: accounts, holdings: holdings)
    }
}
