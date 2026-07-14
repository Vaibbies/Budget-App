import SwiftUI

@main
struct PennyApp: App {
    @State private var container = AppContainer.shared
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
            .environment(container)
            .environment(container.data)
            .environment(container.platform)
            .environment(container.session)
            .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
        }
    }

    private var currentLocaleIdentifier: String {
        AppLanguage(rawValue: languageCode)?.localeIdentifier ?? AppLanguage.english.localeIdentifier
    }
}
