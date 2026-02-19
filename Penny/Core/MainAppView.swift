import SwiftUI

struct MainAppView: View {
    @State private var selectedTab = 1
    @State private var showChat = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.black.ignoresSafeArea()

                Group {
                    switch selectedTab {
                    case 0:
                        FriendsView()
                    case 1:
                        SpendingHomeView()
                    case 2:
                        MeView()
                    case 3:
                        BankView()
                    default:
                        SpendingHomeView()
                    }
                }
            }

            TabBarView(
                selectedTab: $selectedTab,
                showChat: $showChat
            )
            .padding(.top, 4)
            .padding(.bottom, 4)
            .background(Color.black.opacity(0.7))
        }
        .sheet(isPresented: $showChat) {
            PennyChatView(
                selectedTab: $selectedTab,
                showChat: $showChat
            )
            .presentationCornerRadius(30)
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    MainAppView()
}
