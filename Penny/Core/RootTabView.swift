import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: Int = 1
    @State private var showMindfulPause = false

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
                if newValue != 4 { Haptics.medium() }
            }

            // Mindful pause overlay — shown when Action Button fires the intent
            if showMindfulPause {
                MindfulSpendingView(isPresented: $showMindfulPause)
                    .zIndex(999)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showMindfulPause)
        // Listen for the intent notification
        .onReceive(NotificationCenter.default.publisher(for: .triggerMindfulSpending)) { _ in
            Haptics.medium()
            showMindfulPause = true
        }
    }
}

#Preview {
    RootTabView()
}
