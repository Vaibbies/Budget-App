import SwiftUI

@main
struct PennyApp: App {
    @State private var data = TransactionData.shared
    @AppStorage("penny.preferences.languageCode") private var languageCode = AppLanguage.english.rawValue
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(data)
                .environment(\.locale, Locale(identifier: currentLocaleIdentifier))
        }
    }

    private var currentLocaleIdentifier: String {
        AppLanguage(rawValue: languageCode)?.localeIdentifier ?? AppLanguage.english.localeIdentifier
    }
}
