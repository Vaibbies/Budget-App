import SwiftUI

struct SpendingAnalyticsView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(SpendingStore.self) private var spending

    var body: some View {
        ZStack {
            // Background
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.04, blue: 0.05),
                        Color(red: 0.04, green: 0.04, blue: 0.04),
                        Color.black
                    ],
                    startPoint: .top, endPoint: .bottom
                )
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.95),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.18),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: -0.3),
                    startRadius: 50, endRadius: 420
                )
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                AnalyticsHeader(onBack: { dismiss() })

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        TotalSpendingSection(total: spending.totalSpent)

                        PieChartSection(
                            categories: spending.categoryTotals,
                            transactionCount: spending.transactionCount
                        )

                        SpendingTrendSection(groups: spending.groups)

                        TopCategoriesSection(categories: spending.categoryTotals)

                        StatsRowSection(
                            totalSpent: spending.totalSpent,
                            topCategory: spending.topCategories.first?.name ?? "—"
                        )

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
