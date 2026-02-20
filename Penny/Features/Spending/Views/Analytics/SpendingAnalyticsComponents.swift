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
                            .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                    )
            }
            Spacer()
            Text("ANALYTICS")
                .font(.system(size: 12, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, 24)
        .padding(.top, 48)
        .padding(.bottom, 8)
    }
}

// MARK: - Total Spending Section
struct TotalSpendingSection: View {
    let total: Double

    var wholePart: String { String(format: "%.0f", floor(total)) }
    var centsPart: String { String(format: "%02.0f", (total.truncatingRemainder(dividingBy: 1)) * 100) }

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 2) {
                Text("$")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(y: 12)
                Text(wholePart)
                    .font(.system(size: 48, weight: .light, design: .serif))
                    .foregroundColor(.white)
                Text(".\(centsPart)")
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.6))
                    .offset(y: 16)
            }
            .shadow(color: .black.opacity(0.8), radius: 17, x: 0, y: 5)

            Text("TOTAL SPENDING")
                .font(.system(size: 12, weight: .medium))
                .tracking(1.8)
                .foregroundColor(.white.opacity(0.72))
        }
        .padding(.top, 8)
    }
}

// MARK: - Category Data Model
struct CategoryData: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let amount: Double
    let total: Double

    var percentage: Double {
        guard total > 0 else { return 0 }
        return (amount / total) * 100
    }
}

// MARK: - Pie Chart Section
struct PieChartSection: View {
    let categories: [CategoryData]
    let transactionCount: Int

    var body: some View {
        ZStack {
            if categories.isEmpty {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 220, height: 220)
            } else {
                PieChartShape(categories: categories)
                    .frame(width: 220, height: 220)
            }

            VStack(spacing: 4) {
                Text("TOTAL")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(.white.opacity(0.4))
                Text("\(transactionCount)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("txns")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(width: 110, height: 110)
            .background(
                Circle()
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.09))
                    .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 2)
            )
        }
        .padding(.vertical, 16)
    }
}

// MARK: - Pie Chart Shape
struct PieChartShape: View {
    let categories: [CategoryData]

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            let total = categories.reduce(0) { $0 + $1.amount }
            guard total > 0 else { return }

            var startAngle = Angle.degrees(-90)

            for category in categories {
                let fraction = category.amount / total
                let endAngle = startAngle + Angle.degrees(fraction * 360)

                var path = Path()
                path.move(to: center)
                path.addArc(center: center, radius: radius,
                            startAngle: startAngle, endAngle: endAngle, clockwise: false)
                path.closeSubpath()

                context.fill(path, with: .color(category.color))
                startAngle = endAngle
            }
        }
    }
}

// MARK: - Top Categories Section
struct TopCategoriesSection: View {
    let categories: [CategoryData]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TOP CATEGORIES")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
            }
            .padding(.horizontal, 4)

            VStack(spacing: 20) {
                ForEach(categories) { category in
                    CategoryProgressRow(category: category)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .background(RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7)))
                    .overlay(RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1))
                    .shadow(color: .black.opacity(0.45), radius: 15, x: 0, y: 5)
            )
        }
    }
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
                Text("(\(Int(category.percentage))%)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.35))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(category.color)
                        .frame(width: geometry.size.width * CGFloat(category.percentage / 100), height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Stats Row Section
struct StatsRowSection: View {
    let totalSpent: Double
    let topCategory: String

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL SPENT")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                Text("$\(String(format: "%.2f", totalSpent))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1, height: 40)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("TOP CATEGORY")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                Text(topCategory)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .background(RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7)))
                .overlay(RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1))
                .shadow(color: .black.opacity(0.45), radius: 15, x: 0, y: 5)
        )
    }
}
