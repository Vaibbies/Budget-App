import SwiftUI
import Navigation // Import the Navigation module to access AppTab and BottomBar

struct ContentView: View {
    @State private var selectedTab: AppTab = .spending
    
    var body: some View {
        ZStack {
            // Main content based on selected tab
            Group {
                switch selectedTab {
                case .friends:
                    PlaceholderView(title: "Friends", icon: "person.2.fill")
                case .spending:
                    HomeView()
                case .me:
                    PlaceholderView(title: "Me", icon: "person.circle.fill")
                case .bank:
                    PlaceholderView(title: "Bank", icon: "creditcard.fill")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom navigation overlay
            VStack {
                Spacer()
                BottomBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

// Placeholder view for tabs that aren't implemented yet
struct PlaceholderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.74, green: 0.48, blue: 0.25),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 72, weight: .light))
                    .foregroundColor(.white.opacity(0.3))
                
                Text(title)
                    .font(.largeTitle)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    ContentView()
}
