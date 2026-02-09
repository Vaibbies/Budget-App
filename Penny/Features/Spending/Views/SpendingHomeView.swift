import SwiftUI

struct SpendingHomeView: View {
    @State private var showDrawer = false
    
    var body: some View {
        ZStack {
            // Backgrounds
            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.12, blue: 0.08),  // Warm brown at top
                    Color(red: 0.08, green: 0.05, blue: 0.04),  // Darker brown
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Top orange/brown glow - more prominent and warmer
            RadialGradient(
                colors: [
                    Color(red: 0.85, green: 0.45, blue: 0.20).opacity(0.9),
                    Color(red: 0.75, green: 0.35, blue: 0.15).opacity(0.6),
                    Color(red: 0.50, green: 0.25, blue: 0.12).opacity(0.3),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: -0.1),
                startRadius: 20,
                endRadius: 380
            )
            .ignoresSafeArea()

            // Content
            ScrollView {
                VStack(spacing: 0) {
                    HeaderView(showDrawer: $showDrawer)
                    BalanceView()
                        .padding(.bottom, 8)

                    WeeklyActivityCard()
                        .padding(.bottom, 8)

                    TransactionsCard()
                    
                    // Bottom padding for tab bar clearance
                    Color.clear
                        .frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
            
            // Drawer overlay
            SpendingDrawer(isOpen: $showDrawer)
        }
    }
}

#Preview {
    SpendingHomeView()
}
