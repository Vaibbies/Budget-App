import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1 // Start on Spending tab
    @State private var showChat = false
    
    var body: some View {
        ZStack {
            // Tab content
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
            
            // Fixed bottom bar overlay
            VStack {
                Spacer()
                BottomBarMock(selectedTab: $selectedTab, showChat: $showChat)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $showChat) {
            PennyChatView(selectedTab: $selectedTab, showChat: $showChat)
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(30)
        }
    }
}

// MARK: - Placeholder Views

struct MeView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.12, blue: 0.08),
                    Color(red: 0.08, green: 0.05, blue: 0.04),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Me")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                
                Spacer()
            }
            .padding(.bottom, 100) // Space for bottom bar
        }
    }
}

struct BankView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.12, blue: 0.08),
                    Color(red: 0.08, green: 0.05, blue: 0.04),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Bank")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                
                Spacer()
            }
            .padding(.bottom, 100) // Space for bottom bar
        }
    }
}

#Preview {
    ContentView()
}
