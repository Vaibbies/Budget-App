import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: Int = 1
    @State private var showMindfulPause = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(TransactionData.self) private var data

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                SpendingHomeView()
                    .tabItem {
                        Label("Spending", systemImage: "dollarsign.circle.fill")
                    }
                    .tag(1)

                FriendsView()
                    .tabItem {
                        Label("Friends", systemImage: "person.2.fill")
                    }
                    .tag(0)

                MeView()
                    .tabItem {
                        Label("Me", systemImage: "person.fill")
                    }
                    .tag(2)

                BankView()
                    .tabItem {
                        Label("Bank", systemImage: "creditcard.fill")
                    }
                    .tag(3)

                PennyChatView(selectedTab: $selectedTab, showChat: .constant(true))
                    .tabItem {
                        Label("Chat", systemImage: "bubble.fill")
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
            data.syncRecurringTransactions()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                data.syncRecurringTransactions()
            }
        }
    }
}

#Preview {
    RootTabView()
}
