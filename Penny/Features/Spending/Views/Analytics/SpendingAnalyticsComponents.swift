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

// MARK: - Spending Trend Section
struct SpendingTrendSection: View {
    private enum TrendPeriod: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"

        var id: String { rawValue }
    }

    let groups: [SpendingTransactionGroup]
    @State private var selectedTrendPeriod: TrendPeriod = .weekly

    private var points: [(label: String, total: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var dailyTotals: [Date: Double] = [:]

        for group in groups {
            guard let date = resolveDate(forGroupTitle: group.title, now: now) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            dailyTotals[dayStart, default: 0] += group.transactions.reduce(0) { $0 + $1.amountValue }
        }

        switch selectedTrendPeriod {
        case .weekly:
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEE"
            return (0..<7).reversed().map { daysBack in
                guard let day = calendar.date(byAdding: .day, value: -daysBack, to: calendar.startOfDay(for: now)) else {
                    return (label: "---", total: 0)
                }
                return (
                    label: weekdayFormatter.string(from: day).uppercased(),
                    total: dailyTotals[day, default: 0]
                )
            }
        case .monthly:
            let monthFormatter = DateFormatter()
            monthFormatter.dateFormat = "MMM"
            return (0..<6).reversed().map { monthsBack in
                guard
                    let monthDate = calendar.date(byAdding: .month, value: -monthsBack, to: now),
                    let interval = calendar.dateInterval(of: .month, for: monthDate)
                else {
                    return (label: "---", total: 0)
                }

                let total = dailyTotals.reduce(0) { running, pair in
                    interval.contains(pair.key) ? running + pair.value : running
                }
                return (
                    label: monthFormatter.string(from: interval.start).uppercased(),
                    total: total
                )
            }
        case .yearly:
            let yearFormatter = DateFormatter()
            yearFormatter.dateFormat = "yyyy"
            return (0..<5).reversed().map { yearsBack in
                guard
                    let yearDate = calendar.date(byAdding: .year, value: -yearsBack, to: now),
                    let interval = calendar.dateInterval(of: .year, for: yearDate)
                else {
                    return (label: "----", total: 0)
                }

                let total = dailyTotals.reduce(0) { running, pair in
                    interval.contains(pair.key) ? running + pair.value : running
                }
                return (
                    label: yearFormatter.string(from: interval.start),
                    total: total
                )
            }
        }
    }

    private var trendSubtitle: String {
        switch selectedTrendPeriod {
        case .weekly: return "Last 7 days"
        case .monthly: return "Last 6 months"
        case .yearly: return "Last 5 years"
        }
    }

    private func resolveDate(forGroupTitle title: String, now: Date) -> Date? {
        let calendar = Calendar.current

        if title == "Today" { return calendar.startOfDay(for: now) }
        if title == "Yesterday" {
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))
        }

        let explicitFormatter = DateFormatter()
        explicitFormatter.locale = Locale(identifier: "en_US_POSIX")
        explicitFormatter.dateFormat = "EEEE, MMM d"
        if let parsed = explicitFormatter.date(from: title) {
            let month = calendar.component(.month, from: parsed)
            let day = calendar.component(.day, from: parsed)
            let currentYear = calendar.component(.year, from: now)

            var components = DateComponents()
            components.year = currentYear
            components.month = month
            components.day = day

            if let candidate = calendar.date(from: components) {
                if candidate > now, let previousYear = calendar.date(byAdding: .year, value: -1, to: candidate) {
                    return previousYear
                }
                return candidate
            }
        }

        let weekdayMap: [String: Int] = [
            "Sunday": 1, "Monday": 2, "Tuesday": 3, "Wednesday": 4,
            "Thursday": 5, "Friday": 6, "Saturday": 7
        ]
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let isLastPrefix = normalized.hasPrefix("Last ")
        let weekdayName = isLastPrefix
            ? String(normalized.dropFirst("Last ".count))
            : normalized

        if let targetWeekday = weekdayMap[weekdayName] {
            let todayWeekday = calendar.component(.weekday, from: now)
            var daysBack = (todayWeekday - targetWeekday + 7) % 7
            if isLastPrefix || daysBack == 0 { daysBack += 7 }
            return calendar.date(byAdding: .day, value: -daysBack, to: calendar.startOfDay(for: now))
        }

        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SPENDING TREND")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text(trendSubtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.horizontal, 4)

            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    ForEach(TrendPeriod.allCases) { period in
                        Button {
                            selectedTrendPeriod = period
                        } label: {
                            Text(period.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(selectedTrendPeriod == period ? .white : .white.opacity(0.55))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectedTrendPeriod == period
                                              ? Color.white.opacity(0.14)
                                              : Color.white.opacity(0.04))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                GeometryReader { geo in
                    let maxValue = max(points.map { $0.total }.max() ?? 1, 1)

                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))

                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                                let ratio = CGFloat(point.total / maxValue)

                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1.0, green: 0.56, blue: 0.36),
                                                Color(red: 1.0, green: 0.38, blue: 0.13)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: max(6, geo.size.height * ratio))
                                    .opacity(point.total == 0 ? 0.3 : 0.95)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 10)
                    }
                }
                .frame(height: 120)

                HStack {
                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        Text(point.label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                            .frame(maxWidth: .infinity)
                    }
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
