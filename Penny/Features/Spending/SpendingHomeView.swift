import SwiftUI

struct SpendingHomeView: View {
    private enum TrendPeriod: String, CaseIterable, Identifiable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"

        var id: String { rawValue }
    }

    private enum TransactionsSheetScope: Equatable {
        case all
        case today
    }

    @State private var showDrawer = false
    @State private var showAddTransaction = false
    @State private var showTransactions = false
    @State private var transactionsSheetScope: TransactionsSheetScope = .all
    @State private var showRecurring = false
    @State private var selectedTrendPeriod: TrendPeriod = .weekly
    @AppStorage("penny.preferences.languageCode") private var languageCode = AppLanguage.english.rawValue
    @AppStorage("penny.profile.name") private var storedProfileName: String = "Alex Rivers"
            
    @Environment(TransactionData.self) private var data

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let dayGreeting: String
        if hour < 12 { dayGreeting = language.text(.goodMorning) }
        else if hour < 17 { dayGreeting = language.text(.goodAfternoon) }
        else { dayGreeting = language.text(.goodEvening) }
        return "\(dayGreeting), \(firstName)"
    }

    var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }

    private var firstName: String {
        let trimmed = storedProfileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawFirst = trimmed.split(separator: " ").first.map(String.init) ?? "Alex"
        return rawFirst.isEmpty ? "Alex" : rawFirst
    }

    private var language: AppLanguage {
        AppLanguage(rawValue: languageCode) ?? .english
    }

    // Now pulls from your real recurring subscriptions instead of hardcoded values
    var upcomingRecurring: [RecurringSubscription] {
        Array(data.subscriptions.prefix(3))
    }

    var spendingInsight: String {
        guard !data.allTransactions.isEmpty || !data.accounts.isEmpty || data.dailyBudget > 0 else {
            return "Add your accounts, set a daily budget, and log your first transactions to unlock spending insights."
        }

        let comparison = data.monthToDateComparison()
        let direction = comparison.delta <= 0 ? "down" : "up"
        let percent = Int(abs(comparison.percentChange) * 100)
        let safe = Int(data.safeToSpendThisMonth.rounded())
        return "Spending is \(direction) \(percent)% vs last month. You still have about $\(safe) safe to spend."
    }

    private var monthlyBudgetProgress: Double {
        guard data.totalMonthlyBudget > 0 else { return 0 }
        return min(data.monthlySpent / data.totalMonthlyBudget, 1.0)
    }

    private var monthlyComparison: MonthlyComparison {
        data.monthToDateComparison()
    }

    private var monthlyComparisonLabel: String {
        let direction = monthlyComparison.delta <= 0 ? "less" : "more"
        return "\(Int(abs(monthlyComparison.percentChange) * 100))% \(direction) than last month"
    }

    private var monthlyComparisonColor: Color {
        monthlyComparison.delta <= 0
            ? Color(red: 0.29, green: 0.87, blue: 0.50)
            : Color(red: 1.0, green: 0.42, blue: 0.16)
    }

    private var trendData: [(label: String, total: Double)] {
        let calendar = Calendar.current
        let now = Date()
        var dailyTotals: [Date: Double] = [:]

        for group in data.groups {
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
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

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

                ScrollView {
                    VStack(spacing: 0) {
                        greetingHeader
                            .padding(.bottom, 4)

                        BalanceView(onTap: {
                            transactionsSheetScope = .today
                            showTransactions = true
                        })
                            .padding(.bottom, 8)

                        budgetRingCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        monthOverviewSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        insightBanner
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        categoryPills
                            .padding(.bottom, 8)

                        WeeklyActivityCard()
                            .padding(.bottom, 8)

                        weeklyTrendSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        upcomingRecurringSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        recentTransactionsSection
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        Color.clear.frame(height: 120)
                    }
                }
                .scrollIndicators(.hidden)

                // Drawer overlay — sits on top, anchored top-left
                SpendingDrawer(isOpen: $showDrawer)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Spending Trend
    private var weeklyTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Spending Trend")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text(trendSubtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            }

            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    ForEach(TrendPeriod.allCases) { period in
                        Button {
                            Haptics.light()
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
                                              ? Color.white.opacity(0.15)
                                              : Color.white.opacity(0.04))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let maxValue = max(trendData.map { $0.total }.max() ?? 1, 1)

                    let points = trendData.enumerated().map { index, item in
                        CGPoint(
                            x: width * CGFloat(index) / CGFloat(max(trendData.count - 1, 1)),
                            y: height - (height * CGFloat(item.total / maxValue))
                        )
                    }

                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.03))

                        VStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle().fill(Color.white.opacity(0.06)).frame(height: 1)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)

                        HomeSparklineArea(points: points)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.28),
                                        Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.02)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        HomeSparkline(points: points)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.55, blue: 0.36),
                                        Color(red: 1.0, green: 0.42, blue: 0.16)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                            )
                    }
                }
                .frame(height: 110)

                HStack {
                    ForEach(Array(trendData.enumerated()), id: \.offset) { _, item in
                        Text(item.label)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.35))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.04))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
            )
        }
    }

    // MARK: - Greeting Header
    private var greetingHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.system(size: 26, weight: .light, design: .serif))
                    .foregroundColor(.white)

                Text(todayString)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()

            Button {
                Haptics.medium()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showDrawer.toggle()
                }
            } label: {
                Circle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .overlay(
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 12)
    }

    // MARK: - Budget Ring Card
    private var budgetRingCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: monthlyBudgetProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.16),
                                Color(red: 1.0, green: 0.6, blue: 0.36)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 1) {
                    Text("\(Int(monthlyBudgetProgress * 100))%")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                    Text("used")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MONTHLY BUDGET")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.4))
                    Text("$\(String(format: "%.2f", max(data.totalMonthlyBudget - data.monthlySpent, 0))) left")
                        .font(.system(size: 20, weight: .light, design: .serif))
                        .foregroundColor(.white)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.42, blue: 0.16),
                                        Color(red: 1.0, green: 0.6, blue: 0.36)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * monthlyBudgetProgress,
                                height: 6
                            )
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("$\(String(format: "%.2f", data.monthlySpent)) spent")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))

                    Spacer()

                    Text("of $\(String(format: "%.0f", data.totalMonthlyBudget))")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.25))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.9))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))
                .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 5)
        )
    }

    private var monthOverviewSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                monthMetricCard(
                    title: "SAFE TO SPEND",
                    value: "$\(String(format: "%.0f", data.safeToSpendThisMonth))",
                    subtitle: "after upcoming bills",
                    accent: Color(red: 0.29, green: 0.87, blue: 0.50)
                )

                monthMetricCard(
                    title: "UPCOMING BILLS",
                    value: "$\(String(format: "%.0f", data.upcomingRecurringTotal))",
                    subtitle: "\(upcomingRecurring.count) recurring charges",
                    accent: Color(red: 0.38, green: 0.65, blue: 0.98)
                )
            }

            HStack(spacing: 10) {
                monthMetricCard(
                    title: "MONTHLY NET",
                    value: currencyString(data.monthlyNet),
                    subtitle: data.monthlyIncome > 0 ? "income minus spend" : "no income tracked yet",
                    accent: data.monthlyNet >= 0 ? Color(red: 0.29, green: 0.87, blue: 0.50) : Color(red: 1.0, green: 0.42, blue: 0.16)
                )

                monthMetricCard(
                    title: "VS LAST MONTH",
                    value: monthlyComparisonLabel,
                    subtitle: "month to date",
                    accent: monthlyComparisonColor,
                    compact: true
                )
            }
        }
    }

    // MARK: - Insight Banner
    private var insightBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15))
                    .overlay(Circle().stroke(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.25), lineWidth: 1))
                    .frame(width: 36, height: 36)

                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
            }

            Text(spendingInsight)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15), lineWidth: 1))
        )
    }

    private func monthMetricCard(
        title: String,
        value: String,
        subtitle: String,
        accent: Color,
        compact: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 9, weight: .medium))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.4))

            Text(value)
                .font(.system(size: compact ? 16 : 20, weight: .light, design: .serif))
                .foregroundColor(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            HStack(spacing: 6) {
                Circle()
                    .fill(accent)
                    .frame(width: 6, height: 6)

                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.45))
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }

    private func currencyString(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        return "\(sign)$\(String(format: "%.0f", abs(value)))"
    }

    // MARK: - Category Pills
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if data.categoryTotals.isEmpty {
                    Text("No category activity yet")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                                .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                        )
                } else {
                    ForEach(data.categoryTotals) { category in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 6, height: 6)

                            Text(category.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))

                            Text("$\(String(format: "%.0f", category.amount))")
                                .font(.system(size: 12, weight: .regular, design: .serif))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.05))
                                .overlay(Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1))
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Upcoming Recurring
    private var upcomingRecurringSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming Bills")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    showRecurring = true
                    Haptics.light()
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                    }
                }
            }

            VStack(spacing: 8) {
                if upcomingRecurring.isEmpty {
                    emptySectionCard("No recurring bills yet", subtitle: "Add subscriptions later and they will show up here.")
                } else {
                    ForEach(upcomingRecurring) { sub in
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                                .frame(width: 36, height: 36)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 1))
                                .overlay(
                                    BrandLogoView(
                                        name: sub.name,
                                        size: 36,
                                        fallbackIcon: sub.iconName,
                                        fallbackColor: sub.iconColor
                                    )
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(sub.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)

                                Text(sub.nextBilling)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.4))
                            }

                            Spacer()

                            Text("$\(String(format: "%.2f", sub.price))")
                                .font(.system(size: 15, weight: .regular, design: .serif))
                                .foregroundColor(.white)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.04))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showRecurring) {
            RecurringView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Recent Transactions
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Button {
                    transactionsSheetScope = .all
                    showTransactions = true
                    Haptics.light()
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                    }
                }
            }

            VStack(spacing: 8) {
                if data.recentTransactions.isEmpty {
                    emptySectionCard("No transactions yet", subtitle: "Add a transaction and your recent activity will appear here.")
                } else {
                    ForEach(data.recentTransactions) { tx in
                        HStack(spacing: 14) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(tx.borderColor, lineWidth: 1))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    BrandLogoView(
                                        name: tx.title,
                                        size: 40,
                                        fallbackIcon: tx.icon,
                                        fallbackColor: tx.iconColor
                                    )
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(tx.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)

                                Text(tx.subtitle)
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.4))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(tx.amount)
                                    .font(.system(size: 14, weight: .regular, design: .serif))
                                    .foregroundColor(.white)

                                if tx.isImpulse {
                                    Text("impulse")
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.12))
                                        )
                                }
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.04))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showTransactions) {
            TransactionsView(scope: transactionsSheetScope == .today ? .today : .all)
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }

    private func emptySectionCard(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.white.opacity(0.45))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }
}

private struct HomeSparkline: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        return path
    }
}

private struct HomeSparklineArea: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first, let last = points.last else { return path }
        path.move(to: CGPoint(x: first.x, y: rect.maxY))
        path.addLine(to: first)
        for point in points.dropFirst() { path.addLine(to: point) }
        path.addLine(to: CGPoint(x: last.x, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SpendingHomeView()
}
