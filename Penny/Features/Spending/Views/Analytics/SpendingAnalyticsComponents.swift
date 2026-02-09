import SwiftUI

// MARK: - Analytics Header
struct AnalyticsHeader: View {
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            Text("ANALYTICS")
                .font(.system(size: 12, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
            
            Color.clear
                .frame(width: 40, height: 40)
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 8)
    }
}

// MARK: - Total Spending Section
struct TotalSpendingSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Amount
            HStack(alignment: .top, spacing: 2) {
                Text("$")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(y: 12)
                
                Text("2,840")
                    .font(.system(size: 48, weight: .light, design: .serif))
                    .foregroundColor(.white)
                
                Text(".00")
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(y: 16)
            }
            .shadow(color: .black.opacity(0.8), radius: 17, x: 0, y: 5)
            
            // Label
            Text("MARCH SPENDING")
                .font(.system(size: 12, weight: .medium))
                .tracking(1.8)
                .foregroundColor(.white.opacity(0.72))
            
            // Comparison Badge
            HStack(spacing: 8) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.green)
                
                Text("12% less than Feb")
                    .font(.system(size: 11))
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.green.opacity(0.1))
                    .overlay(
                        Capsule()
                            .stroke(Color.green.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.top, 8)
    }
}

// MARK: - Pie Chart Section
struct PieChartSection: View {
    var body: some View {
        ZStack {
            // Pie segments using conic gradient
            Circle()
                .fill(
                    AngularGradient(
                        stops: [
                            .init(color: Color(red: 1.0, green: 0.42, blue: 0.16), location: 0.0),
                            .init(color: Color(red: 1.0, green: 0.42, blue: 0.16), location: 0.45),
                            .init(color: Color(red: 0.29, green: 0.87, blue: 0.50), location: 0.45),
                            .init(color: Color(red: 0.29, green: 0.87, blue: 0.50), location: 0.70),
                            .init(color: Color(red: 0.38, green: 0.65, blue: 0.98), location: 0.70),
                            .init(color: Color(red: 0.38, green: 0.65, blue: 0.98), location: 0.85),
                            .init(color: Color(red: 0.96, green: 0.45, blue: 0.71), location: 0.85),
                            .init(color: Color(red: 0.96, green: 0.45, blue: 0.71), location: 1.0)
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    )
                )
                .frame(width: 160, height: 160)
            
            // Center hole with stats
            VStack(spacing: 2) {
                Text("TOTAL")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(.white.opacity(0.4))
                
                Text("142")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text("txns")
                    .font(.system(size: 8))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(width: 80, height: 80)
            .background(
                Circle()
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.09))
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Top Categories Section
struct TopCategoriesSection: View {
    let categories = [
        CategoryData(name: "Entertainment", color: Color(red: 1.0, green: 0.42, blue: 0.16), amount: 1278.00, percentage: 45),
        CategoryData(name: "Food & Dining", color: Color(red: 0.29, green: 0.87, blue: 0.50), amount: 710.00, percentage: 25),
        CategoryData(name: "Transportation", color: Color(red: 0.38, green: 0.65, blue: 0.98), amount: 426.00, percentage: 15)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("TOP CATEGORIES")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
                
                Spacer()
                
                Text("View All")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 4)
            
            // Categories Card
            VStack(spacing: 20) {
                ForEach(categories) { category in
                    CategoryProgressRow(category: category)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.45), radius: 15, x: 0, y: 5)
                    .shadow(color: .black.opacity(0.35), radius: 7, x: 0, y: 2)
            )
        }
    }
}

// MARK: - Category Data Model
struct CategoryData: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let amount: Double
    let percentage: Int
}

// MARK: - Category Progress Row
struct CategoryProgressRow: View {
    let category: CategoryData
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 12) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                    
                    Text(category.name)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("$\(String(format: "%.2f", category.amount))")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 3)
                        .fill(category.color)
                        .frame(width: geometry.size.width * CGFloat(category.percentage) / 100, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Stats Row Section
struct StatsRowSection: View {
    var body: some View {
        HStack(spacing: 0) {
            // Average Monthly
            VStack(alignment: .leading, spacing: 4) {
                Text("AVERAGE MONTHLY")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                
                Text("$3,120.00")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 40)
            
            Spacer()
            
            // Peak Day
            VStack(alignment: .trailing, spacing: 4) {
                Text("PEAK DAY")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                
                Text("Mar 12")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 15, x: 0, y: 5)
                .shadow(color: .black.opacity(0.35), radius: 7, x: 0, y: 2)
        )
    }
}
