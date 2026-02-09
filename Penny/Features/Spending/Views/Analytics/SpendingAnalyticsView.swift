import SwiftUI

struct SpendingAnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.04, blue: 0.05),
                        Color(red: 0.04, green: 0.04, blue: 0.04),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.95),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.75),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.18),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: -0.3),
                    startRadius: 50,
                    endRadius: 420
                )
                
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.47, blue: 0.36).opacity(0.45),
                        Color(red: 1.0, green: 0.47, blue: 0.36).opacity(0.24),
                        Color(red: 1.0, green: 0.47, blue: 0.36).opacity(0.08),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.82, y: 0.82),
                    startRadius: 50,
                    endRadius: 360
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                AnalyticsHeader(onBack: {
                    dismiss()
                })
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Total Spending
                        TotalSpendingSection()
                        
                        // Pie Chart
                        PieChartSection()
                        
                        // Top Categories
                        TopCategoriesSection()
                        
                        // Stats Row
                        StatsRowSection()
                        
                        // Bottom padding
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }
            }
        }
    }
}

#Preview {
    SpendingAnalyticsView()
}
