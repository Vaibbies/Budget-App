import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: Int = 1
    @State private var showMindfulPause = false
    @AppStorage("penny.preferences.languageCode") private var languageCode = AppLanguage.english.rawValue
    @AppStorage("penny.notifications.spendingAlerts") private var spendingAlerts = true
    @AppStorage("penny.notifications.budgetWarnings") private var budgetWarnings = true
    @AppStorage("penny.notifications.billReminders") private var billReminders = true
    @AppStorage("penny.notifications.weeklyDigest") private var weeklyDigest = false
    @AppStorage("penny.notifications.savingTips") private var savingTips = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppMaintenanceStore.self) private var maintenance

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                SpendingHomeView()
                    .tabItem {
                        Label(language.text(.spending), systemImage: "dollarsign.circle.fill")
                    }
                    .tag(1)

                FriendsView()
                    .tabItem {
                        Label(language.text(.friends), systemImage: "person.2.fill")
                    }
                    .tag(0)

                MeView()
                    .tabItem {
                        Label(language.text(.me), systemImage: "person.fill")
                    }
                    .tag(2)

                BankView()
                    .tabItem {
                        Label(language.text(.bank), systemImage: "creditcard.fill")
                    }
                    .tag(3)

                PennyChatView(selectedTab: $selectedTab, showChat: .constant(true))
                    .tabItem {
                        Label(language.text(.chat), systemImage: "bubble.fill")
                    }
                    .tag(4)
            }
            .tint(Color(red: 1.0, green: 0.42, blue: 0.16))
            .preferredColorScheme(.dark)
            .onChange(of: selectedTab) { _, _ in
                Haptics.medium()
            }

            if showMindfulPause {
                MindfulSpendingView(isPresented: $showMindfulPause)
                    .zIndex(999)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showMindfulPause)
        .onReceive(NotificationCenter.default.publisher(for: .triggerMindfulSpending)) { _ in
            Haptics.medium()
            showMindfulPause = true
        }
        .onAppear {
            maintenance.handleForegroundActivation(preferences: notificationPreferences)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                maintenance.handleForegroundActivation(preferences: notificationPreferences)
            }
        }
        .onChange(of: billReminders) { _, _ in
            Task {
                await maintenance.refreshNotifications(preferences: notificationPreferences)
            }
        }
        .onChange(of: spendingAlerts) { _, _ in
            Task {
                await maintenance.refreshNotifications(preferences: notificationPreferences)
            }
        }
        .onChange(of: budgetWarnings) { _, _ in
            Task {
                await maintenance.refreshNotifications(preferences: notificationPreferences)
            }
        }
        .onChange(of: weeklyDigest) { _, _ in
            Task {
                await maintenance.refreshNotifications(preferences: notificationPreferences)
            }
        }
        .onChange(of: savingTips) { _, _ in
            Task {
                await maintenance.refreshNotifications(preferences: notificationPreferences)
            }
        }
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    private var notificationPreferences: NotificationPreferences {
        NotificationPreferences(
            spendingAlerts: spendingAlerts,
            budgetWarnings: budgetWarnings,
            billReminders: billReminders,
            weeklyDigest: weeklyDigest,
            savingTips: savingTips
        )
    }
}

#Preview {
    let container = AppContainer.preview
    RootTabView()
        .environment(container.maintenance)
}
