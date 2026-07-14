import SwiftUI

@main
struct PennyApp: App {
    @State private var container = makeLiveAppContainer()
    @AppStorage("penny.preferences.languageCode") private var languageCode = AppLanguage.english.rawValue
    
    var body: some Scene {
        WindowGroup {
            Group {
                if container.session.hasCompletedOnboarding {
                    RootTabView()
                } else {
                    AppModeOnboardingView()
                }
            }
            .environment(container.platform)
            .environment(container.session)
            .environment(container.spending)
            .environment(container.bank)
            .environment(container.recurring)
            .environment(container.maintenance)
            .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
        }
    }

    private var currentLocaleIdentifier: String {
        AppLanguage(rawValue: languageCode)?.localeIdentifier ?? AppLanguage.english.localeIdentifier
    }
}
