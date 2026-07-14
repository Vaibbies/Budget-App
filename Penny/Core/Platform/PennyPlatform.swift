import Foundation
import Observation

enum DataConnectionMode: String, Codable {
    case manual = "Manual"
    case plaid = "Plaid"
    case mx = "MX"
    case finicity = "Finicity"
}

enum ServiceReadiness: String, Codable {
    case localOnly = "Local Only"
    case foundationReady = "Foundation Ready"
    case backendReady = "Backend Ready"
}

enum SyncHealth: String, Codable {
    case healthy = "Healthy"
    case needsAttention = "Needs Attention"
    case paused = "Paused"
    case notConfigured = "Not Configured"
}

struct PennyUserSummary: Identifiable, Codable {
    let id: UUID
    let fullName: String
    let email: String
}

struct HouseholdSummary: Identifiable, Codable {
    let id: UUID
    let name: String
    let memberCount: Int
    let roleLabel: String
}

struct InstitutionConnectionSummary: Identifiable, Codable {
    let id: UUID
    let displayName: String
    let providerMode: DataConnectionMode
    let syncHealth: SyncHealth
    let linkedAccountCount: Int
    let lastSyncedAt: Date?
    let syncLabel: String
}

struct AccountLedgerSummary: Identifiable, Codable {
    let id: UUID
    let name: String
    let institution: String
    let accountType: String
    let effectiveBalance: Double
    let transactionCount: Int
    let monthSpend: Double
    let monthIncome: Double
}

struct BudgetEngineSnapshot: Codable {
    let configuredMode: BudgetMode
    let configuredValue: Double
    let derivedDailyBudget: Double
    let derivedMonthlyBudget: Double
    let monthlySpent: Double
    let safeToSpend: Double
    let readiness: ServiceReadiness
}

struct RecurringEngineSnapshot: Codable {
    let activeCount: Int
    let pausedCount: Int
    let archivedCount: Int
    let expectedMonthlyOutflow: Double
    let readiness: ServiceReadiness
}

struct CategorizationEngineSnapshot: Codable {
    let merchantRuleCount: Int
    let recurringCandidateCount: Int
    let supportedKinds: [String]
    let readiness: ServiceReadiness
}

struct InvestmentEngineSnapshot: Codable {
    let investmentAccountCount: Int
    let holdingsCount: Int
    let marketValue: Double
    let gainLoss: Double
    let assetClassCount: Int
    let readiness: ServiceReadiness
}

struct NotificationEngineSnapshot: Codable {
    let spendingAlertsEnabled: Bool
    let budgetWarningsEnabled: Bool
    let billRemindersEnabled: Bool
    let weeklyDigestEnabled: Bool
    let savingTipsEnabled: Bool
    let readiness: ServiceReadiness
}

struct AIAssistantSnapshot: Codable {
    let hasConversationUI: Bool
    let hasStructuredFinanceContext: Bool
    let hasServerBackedInference: Bool
    let hasActionExecution: Bool
    let readiness: ServiceReadiness
}

struct PlatformCapabilitySnapshot: Codable {
    let authenticatedAPI: ServiceReadiness
    let userHouseholds: ServiceReadiness
    let accountsTransactions: ServiceReadiness
    let budgetingEngine: ServiceReadiness
    let recurringEngine: ServiceReadiness
    let categorizationEngine: ServiceReadiness
    let investmentEngine: ServiceReadiness
    let notificationEngine: ServiceReadiness
    let aiAssistant: ServiceReadiness
    let queueWorkers: ServiceReadiness
    let encryptedObjectStorage: ServiceReadiness
    let dataAggregators: ServiceReadiness
}

protocol UserHouseholdServicing {
    func currentUser() -> PennyUserSummary
    func households() -> [HouseholdSummary]
}

protocol AccountTransactionServicing {
    func institutionConnections() -> [InstitutionConnectionSummary]
    func accounts() -> [AccountLedgerSummary]
}

protocol BudgetingServicing {
    func snapshot() -> BudgetEngineSnapshot
}

protocol RecurringServicing {
    func snapshot() -> RecurringEngineSnapshot
}

protocol CategorizationRulesServicing {
    func snapshot() -> CategorizationEngineSnapshot
}

protocol InvestmentServicing {
    func snapshot() -> InvestmentEngineSnapshot
}

protocol NotificationServicing {
    func snapshot() -> NotificationEngineSnapshot
}

protocol AIAssistantServicing {
    func snapshot() -> AIAssistantSnapshot
}

@MainActor
@Observable
final class PennyPlatform {
    static let shared = PennyPlatform(data: TransactionData.shared)

    let data: any PlatformDataStore
    let userHouseholdService: UserHouseholdServicing
    let accountTransactionService: AccountTransactionServicing
    let budgetingService: BudgetingServicing
    let recurringService: RecurringServicing
    let categorizationService: CategorizationRulesServicing
    let investmentService: InvestmentServicing
    let notificationService: NotificationServicing
    let aiAssistantService: AIAssistantServicing

    init(data: any PlatformDataStore) {
        self.data = data
        self.userHouseholdService = LocalUserHouseholdService()
        self.accountTransactionService = LocalAccountTransactionService(data: data)
        self.budgetingService = LocalBudgetingService(data: data)
        self.recurringService = LocalRecurringService(data: data)
        self.categorizationService = LocalCategorizationRulesService(data: data)
        self.investmentService = LocalInvestmentService(data: data)
        self.notificationService = LocalNotificationService()
        self.aiAssistantService = LocalAIAssistantService()
    }

    var capabilities: PlatformCapabilitySnapshot {
        PlatformCapabilitySnapshot(
            authenticatedAPI: .localOnly,
            userHouseholds: .foundationReady,
            accountsTransactions: .foundationReady,
            budgetingEngine: .foundationReady,
            recurringEngine: .foundationReady,
            categorizationEngine: .foundationReady,
            investmentEngine: .foundationReady,
            notificationEngine: .foundationReady,
            aiAssistant: .foundationReady,
            queueWorkers: .localOnly,
            encryptedObjectStorage: .localOnly,
            dataAggregators: .localOnly
        )
    }
}

private struct LocalUserHouseholdService: UserHouseholdServicing {
    func currentUser() -> PennyUserSummary {
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: "penny.profile.name")?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = defaults.string(forKey: "penny.profile.email")?.trimmingCharacters(in: .whitespacesAndNewlines)

        return PennyUserSummary(
            id: UUID(uuidString: "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee") ?? UUID(),
            fullName: (name?.isEmpty == false ? name! : "Penny User"),
            email: (email?.isEmpty == false ? email! : "Not set")
        )
    }

    func households() -> [HouseholdSummary] {
        [
            HouseholdSummary(
                id: UUID(uuidString: "ffffffff-ffff-ffff-ffff-ffffffffffff") ?? UUID(),
                name: "Primary Household",
                memberCount: 1,
                roleLabel: "Owner"
            )
        ]
    }
}

private struct LocalAccountTransactionService: AccountTransactionServicing {
    let data: any PlatformDataStore

    func institutionConnections() -> [InstitutionConnectionSummary] {
        let grouped = Dictionary(grouping: data.accounts) { $0.institution }

        return grouped.keys.sorted().map { institution in
            let accounts = grouped[institution] ?? []
            let latestRefresh = accounts.map(\.lastUpdated).max()

            return InstitutionConnectionSummary(
                id: UUID(),
                displayName: institution,
                providerMode: .manual,
                syncHealth: .healthy,
                linkedAccountCount: accounts.count,
                lastSyncedAt: latestRefresh,
                syncLabel: "Manual refresh"
            )
        }
    }

    func accounts() -> [AccountLedgerSummary] {
        data.visibleAccounts.map { account in
            AccountLedgerSummary(
                id: account.id,
                name: account.name,
                institution: account.institution,
                accountType: account.type.rawValue,
                effectiveBalance: data.effectiveBalance(for: account),
                transactionCount: data.transactions(forAccount: account.id, inMonth: Date()).count,
                monthSpend: data.monthlySpend(forAccount: account.id, inMonth: Date()),
                monthIncome: data.monthlyIncome(forAccount: account.id, inMonth: Date())
            )
        }
    }
}

private struct LocalBudgetingService: BudgetingServicing {
    let data: any PlatformDataStore

    func snapshot() -> BudgetEngineSnapshot {
        BudgetEngineSnapshot(
            configuredMode: data.budgetMode,
            configuredValue: data.configuredBudgetValue,
            derivedDailyBudget: data.dailyBudget,
            derivedMonthlyBudget: data.derivedMonthlyBudget,
            monthlySpent: data.monthlySpent,
            safeToSpend: data.safeToSpendThisMonth,
            readiness: .foundationReady
        )
    }
}

private struct LocalRecurringService: RecurringServicing {
    let data: any PlatformDataStore

    func snapshot() -> RecurringEngineSnapshot {
        let active = data.subscriptions.filter { $0.status == .active }
        let paused = data.subscriptions.filter { $0.status == .paused }
        let archived = data.subscriptions.filter { $0.status == .archived }

        return RecurringEngineSnapshot(
            activeCount: active.count,
            pausedCount: paused.count,
            archivedCount: archived.count,
            expectedMonthlyOutflow: active.reduce(0) { $0 + $1.price },
            readiness: .foundationReady
        )
    }
}

private struct LocalCategorizationRulesService: CategorizationRulesServicing {
    let data: any PlatformDataStore

    func snapshot() -> CategorizationEngineSnapshot {
        CategorizationEngineSnapshot(
            merchantRuleCount: data.merchantRules.count,
            recurringCandidateCount: data.detectRecurringCandidates().count,
            supportedKinds: TransactionKind.allCases.map(\.rawValue),
            readiness: .foundationReady
        )
    }
}

private struct LocalInvestmentService: InvestmentServicing {
    let data: any PlatformDataStore

    func snapshot() -> InvestmentEngineSnapshot {
        let summary = data.investmentPerformance(forAccount: nil)
        let allocation = data.portfolioAllocation(forAccount: nil)
        return InvestmentEngineSnapshot(
            investmentAccountCount: data.investmentAccounts.count,
            holdingsCount: summary.holdingsCount,
            marketValue: summary.marketValue,
            gainLoss: summary.gainLoss,
            assetClassCount: allocation.count,
            readiness: .foundationReady
        )
    }
}

private struct LocalNotificationService: NotificationServicing {
    func snapshot() -> NotificationEngineSnapshot {
        let defaults = UserDefaults.standard
        return NotificationEngineSnapshot(
            spendingAlertsEnabled: defaults.object(forKey: "penny.notifications.spendingAlerts") as? Bool ?? true,
            budgetWarningsEnabled: defaults.object(forKey: "penny.notifications.budgetWarnings") as? Bool ?? true,
            billRemindersEnabled: defaults.object(forKey: "penny.notifications.billReminders") as? Bool ?? true,
            weeklyDigestEnabled: defaults.object(forKey: "penny.notifications.weeklyDigest") as? Bool ?? false,
            savingTipsEnabled: defaults.object(forKey: "penny.notifications.savingTips") as? Bool ?? false,
            readiness: .foundationReady
        )
    }
}

private struct LocalAIAssistantService: AIAssistantServicing {
    func snapshot() -> AIAssistantSnapshot {
        AIAssistantSnapshot(
            hasConversationUI: true,
            hasStructuredFinanceContext: false,
            hasServerBackedInference: false,
            hasActionExecution: false,
            readiness: .foundationReady
        )
    }
}
