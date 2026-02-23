import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: Int = 1
    @State private var showMindfulPause = false
    @Environment(\.scenePhase) private var scenePhase
    private let data = TransactionData.shared

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                Tab("Spending", systemImage: "dollarsign.circle.fill", value: 1) {
                    SpendingHomeView()
                }
                Tab("Friends", systemImage: "person.2.fill", value: 0) {
                    FriendsView()
                }
                Tab("Me", systemImage: "person.fill", value: 2) {
                    MeView()
                }
                Tab("Bank", systemImage: "creditcard.fill", value: 3) {
                    BankView()
                }
                Tab(value: 4, role: .search) {
                    PennyChatView(selectedTab: $selectedTab, showChat: .constant(true))
                } label: {
                    Label("Chat", systemImage: "bubble.fill")
                }
            }
            .tint(Color(red: 1.0, green: 0.42, blue: 0.16))
            .preferredColorScheme(.dark)
            .onChange(of: selectedTab) { _, newValue in
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
