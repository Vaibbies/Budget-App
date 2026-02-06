import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .spending
    
    var body: some View {
        ZStack {
            // Content for selected tab
            Group {
                switch selectedTab {
                case .friends:
                    friendsView
                case .spending:
                    HomeView()
                case .me:
                    meView
                case .bank:
                    bankView
                }
            }
            
            // Bottom navigation bar
            VStack {
                Spacer()
                BottomBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
    
    // Placeholder views for other tabs
    private var friendsView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Friends")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
    
    private var meView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Me")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
    
    private var bankView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("Bank")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}
