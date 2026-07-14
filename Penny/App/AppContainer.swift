import Foundation
import Observation

@MainActor
@Observable
final class AppContainer {
    static let shared = AppContainer()

    let data: TransactionData
    let platform: PennyPlatform
    let session: AppSessionStore

    init(
        data: TransactionData = .shared,
        platform: PennyPlatform? = nil,
        session: AppSessionStore? = nil
    ) {
        self.data = data
        let resolvedPlatform = platform ?? PennyPlatform(data: data)
        self.platform = resolvedPlatform
        self.session = session ?? AppSessionStore(data: data)
    }
}

@MainActor
@Observable
final class AppSessionStore {
    enum StartupState: Equatable {
        case onboarding
        case active
    }

    private let data: TransactionData
    private let defaults: UserDefaults

    var startupState: StartupState
    var selectedMode: AppDataMode {
        data.appMode
    }

    init(
        data: TransactionData,
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
        data.activateMode(mode)
        defaults.set(true, forKey: TransactionData.hasCompletedOnboardingKey)
        startupState = .active
    }

    func resetToOnboarding() {
        defaults.set(false, forKey: TransactionData.hasCompletedOnboardingKey)
        startupState = .onboarding
    }
}
