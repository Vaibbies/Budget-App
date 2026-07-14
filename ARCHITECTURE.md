# Penny Architecture

## Goal

Penny should be able to evolve from a local-first SwiftUI budgeting app into a full personal-finance platform with:

- Mobile and web clients
- Authenticated API
- User and household service
- Transaction and account service
- Budgeting engine
- Recurring-payment engine
- Categorization and rules engine
- Investment and net-worth service
- Notification service
- AI assistant service
- PostgreSQL, workers, queue jobs, and encrypted object storage
- Plaid, MX, or Finicity plus market-data providers

## Current Foundation

The app currently has two layers:

1. `AppContainer` and `AppSessionStore`
   - Compose app-wide dependencies and session state at the app root
   - Live in:
     - `/Users/vaibhavjasti/Documents/GitHub/Budget/Penny/App/AppContainer.swift`
   - `AppSessionStore` now owns onboarding/session flow instead of views mutating `AppStorage` and global state directly

2. `TransactionData`
   - Local-first finance state, persistence, calculations, and editing flows
   - Useful for prototyping, previews, manual mode, and offline-first behavior

3. `PennyPlatform`
   - Service-oriented boundary that exposes the app as backend-shaped domains
   - Lives in:
     - `/Users/vaibhavjasti/Documents/GitHub/Budget/Penny/Core/Platform/PennyPlatform.swift`

`PennyPlatform` intentionally mirrors the future server architecture by exposing:

- `UserHouseholdServicing`
- `AccountTransactionServicing`
- `BudgetingServicing`
- `RecurringServicing`
- `CategorizationRulesServicing`
- `InvestmentServicing`
- `NotificationServicing`
- `AIAssistantServicing`

Today those services are local adapters over `TransactionData`.
Later they can become authenticated API clients without forcing a UI rewrite.

## Why This Matters

The biggest risk in local-first finance apps is letting UI code depend directly on one giant singleton forever.

That makes it hard to add:

- Plaid-linked institutions
- Shared households
- sync jobs
- conflict resolution
- encrypted file storage
- AI context assembly
- multi-device consistency

The service boundary avoids that trap.

The container/session layer avoids a second trap:

- onboarding and app startup logic spread across views
- inconsistent dependency creation
- views deciding which singleton to reach for

## Migration Path

### Phase 1: Local-first app

- `PennyApp` composes dependencies through `AppContainer`
- session/onboarding state flows through `AppSessionStore`
- SwiftUI views read from injected environment dependencies instead of directly owning globals
- `PennyPlatform` adapts local data into service snapshots
- Good for vibe-coding product and UX quickly

### Phase 2: Authenticated API

Replace the local service adapters inside `PennyPlatform` with network-backed implementations:

- `RemoteUserHouseholdService`
- `RemoteAccountTransactionService`
- `RemoteBudgetingService`
- `RemoteRecurringService`
- `RemoteCategorizationRulesService`
- `RemoteInvestmentService`
- `RemoteNotificationService`
- `RemoteAIAssistantService`

UI should keep depending on service outputs, not backend details.

### Phase 3: Sync + workers

Add:

- background transaction sync
- recurring-payment materialization
- notifications worker
- AI assistant orchestration worker
- investment price refresh worker

### Phase 4: Household + collaboration

Move from single-user assumptions to:

- household IDs
- member roles
- shared budgets
- shared goals
- shared notifications

## Current Readiness

### Already reasonable

- transaction editing and filtering
- recurring models
- manual accounts and net worth
- budget calculations
- investment holdings and drill-down
- local notifications

### Still needed for real Copilot-class backend

- authenticated API client and token lifecycle
- server-backed sync state and conflict handling
- true institution connections
- provider item/link metadata
- encrypted attachment/object storage
- AI context builder and action execution
- household-aware permissions
- web client contract reuse

## Rule

New product work should prefer:

1. Compose dependencies in `AppContainer`
2. Add or update a service contract in `PennyPlatform`
3. Adapt local behavior behind that contract
4. Let views consume injected environment state or service results

Avoid pushing more business logic directly into view files unless it is purely presentational.
