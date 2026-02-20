import SwiftUI

struct TrackingView: View {
    @Environment(\.dismiss) var dismiss
    private var data = TransactionData.shared

    private var impulseTotal: Double {
        data.allTransactions.filter { $0.isImpulse }.reduce(0) { $0 + $1.amountValue }
    }

    private var impulsePercentage: Double {
        guard data.totalSpent > 0 else { return 0 }
        return (impulseTotal / data.totalSpent) * 100
    }

    private var avgTransactionValue: Double {
        guard data.transactionCount > 0 else { return 0 }
        return data.totalSpent / Double(data.transactionCount)
    }

    private var busiestDay: String {
        data.groups.max(by: { $0.transactions.count < $1.transactions.count })?.title ?? "—"
    }

    private var busiestDayCount: Int {
        data.groups.max(by: { $0.transactions.count < $1.transactions.count })?.transactions.count ?? 0
    }

    private var topCategory: String {
        data.topCategories.first?.name ?? "—"
    }

    private var topCategoryAmount: Double {
        data.topCategories.first?.amount ?? 0
    }

    var body: some View {
        ZStack {
            Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.6),
                    Color(red: 1.0, green: 0.376, blue: 0.125).opacity(0.1),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                    Spacer()
                    Text("TRACKING")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 40, height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        heroCard
                        impulseCard
                        HStack(spacing: 12) {
                            statCard(
                                title: "AVG SPEND",
                                value: "$\(String(format: "%.0f", avgTransactionValue))",
                                subtitle: "per transaction",
                                icon: "arrow.up.arrow.down",
                                color: Color(red: 0.38, green: 0.65, blue: 0.98)
                            )
                            statCard(
                                title: "BUSIEST DAY",
                                value: busiestDay,
                                subtitle: "\(busiestDayCount) txns",
                                icon: "calendar",
                                color: Color(red: 0.68, green: 0.45, blue: 0.98)
                            )
                        }
                        topCategoryCard
                        categoryBreakdownCard
                        spendingByDayCard
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
    }

    // MARK: - Hero Card
    private var heroCard: some View {
        VStack(spacing: 8) {
            Text("THIS WEEK")
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("$")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
                Text(String(format: "%.0f", floor(data.totalSpent)))
                    .font(.system(size: 56, weight: .light, design: .serif))
                    .foregroundColor(.white)
                Text(String(format: ".%02.0f", (data.totalSpent.truncatingRemainder(dividingBy: 1)) * 100))
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.4))
            }

            HStack(spacing: 16) {
                Label("\(data.transactionCount) transactions", systemImage: "list.bullet")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
                Label("\(data.groups.count) days", systemImage: "calendar")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(card)
    }

    // MARK: - Impulse Card
    private var impulseCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("IMPULSE SPENDING")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.4))
                    Text("$\(String(format: "%.2f", impulseTotal))")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("INTENTIONAL")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.4))
                    Text("$\(String(format: "%.2f", data.totalSpent - impulseTotal))")
                        .font(.system(size: 24, weight: .light, design: .serif))
                        .foregroundColor(Color(red: 0.29, green: 0.87, blue: 0.50))
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.29, green: 0.87, blue: 0.50).opacity(0.3))
                        .frame(height: 12)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(
                            colors: [Color(red: 1.0, green: 0.53, blue: 0.25), Color(red: 1.0, green: 0.35, blue: 0.10)],
                            startPoint: .leading, endPoint: .trailing
                        ))
                        .frame(width: geo.size.width * CGFloat(impulsePercentage / 100), height: 12)
                }
            }
            .frame(height: 12)

            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color(red: 1.0, green: 0.42, blue: 0.16)).frame(width: 6, height: 6)
                    Text("\(Int(impulsePercentage))% impulse")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
                Spacer()
                HStack(spacing: 6) {
                    Circle().fill(Color(red: 0.29, green: 0.87, blue: 0.50)).frame(width: 6, height: 6)
                    Text("\(Int(100 - impulsePercentage))% intentional")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
        }
        .padding(20)
        .background(card)
    }

    // MARK: - Stat Card
    private func statCard(title: String, value: String, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .overlay(Circle().stroke(color.opacity(0.25), lineWidth: 1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.4))
                Text(value)
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(card)
    }

    // MARK: - Top Category Card
    private var topCategoryCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15))
                    .overlay(Circle().stroke(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.25), lineWidth: 1))
                    .frame(width: 48, height: 48)
                Image(systemName: "star.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("TOP CATEGORY")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
                Text(topCategory)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(String(format: "%.2f", topCategoryAmount))")
                    .font(.system(size: 20, weight: .light, design: .serif))
                    .foregroundColor(.white)
                Text("\(data.totalSpent > 0 ? Int((topCategoryAmount / data.totalSpent) * 100) : 0)% of total")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .padding(20)
        .background(card)
    }

    // MARK: - Category Breakdown
    private var categoryBreakdownCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CATEGORY BREAKDOWN")
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            ForEach(data.categoryTotals) { category in
                HStack(spacing: 12) {
                    Circle()
                        .fill(category.color)
                        .frame(width: 8, height: 8)
                    Text(category.name)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white)
                    Spacer()
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(category.color)
                                .frame(width: geo.size.width * CGFloat(category.percentage / 100), height: 6)
                        }
                    }
                    .frame(width: 80, height: 6)
                    Text("$\(String(format: "%.0f", category.amount))")
                        .font(.system(size: 13, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding(20)
        .background(card)
    }

    // MARK: - Spending By Day
    private var spendingByDayCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SPENDING BY DAY")
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            let maxDaySpend = data.groups.map { $0.transactions.reduce(0) { $0 + $1.amountValue } }.max() ?? 1

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data.groups.prefix(6)) { group in
                    let dayTotal = group.transactions.reduce(0) { $0 + $1.amountValue }
                    let fraction = dayTotal / maxDaySpend

                    VStack(spacing: 6) {
                        Text("$\(String(format: "%.0f", dayTotal))")
                            .font(.system(size: 8, weight: .regular))
                            .foregroundColor(.white.opacity(0.3))

                        GeometryReader { geo in
                            VStack {
                                Spacer()
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(
                                        colors: [Color(red: 1.0, green: 0.42, blue: 0.16), Color(red: 1.0, green: 0.6, blue: 0.36)],
                                        startPoint: .bottom, endPoint: .top
                                    ))
                                    .frame(height: geo.size.height * CGFloat(fraction))
                                    .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.3), radius: 4)
                            }
                        }

                        Text(String(group.title.prefix(3)).uppercased())
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 100)
        }
        .padding(20)
        .background(card)
    }

    // MARK: - Card Background
    private var card: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.9))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))
            .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 5)
    }
}

#Preview {
    TrackingView()
        .preferredColorScheme(.dark)
}
