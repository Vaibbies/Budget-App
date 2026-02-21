import SwiftUI

struct SpendingHomeView: View {
    @State private var showDrawer = false
    @State private var showAddTransaction = false
    @State private var showTransactions = false
    @State private var showRecurring = false

    private var data = TransactionData.shared

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        else if hour < 17 { return "Good afternoon" }
        else { return "Good evening" }
    }

    var todayString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }

    var upcomingRecurring: [RecurringSubscription] {
        [
            RecurringSubscription(name: "Netflix", plan: "Premium Plan", price: 19.99, iconName: "netflix", iconColor: .white, bgColor: .black, nextBilling: "May 12"),
            RecurringSubscription(name: "Spotify", plan: nil, price: 10.99, iconName: "spotify", iconColor: .black, bgColor: Color(red: 0.11, green: 0.72, blue: 0.33), nextBilling: "May 15"),
            RecurringSubscription(name: "iCloud", plan: "200GB", price: 2.99, iconName: "icloud.fill", iconColor: .white, bgColor: Color(red: 0.2, green: 0.5, blue: 1.0), nextBilling: "May 5"),
        ]
    }

    var spendingInsight: String {
        let topCat = data.topCategories.first?.name ?? "spending"
        let topAmt = data.topCategories.first?.amount ?? 0
        let pct = data.totalSpent > 0 ? Int((topAmt / data.totalSpent) * 100) : 0
        return "\(pct)% of your spending is on \(topCat.lowercased()) this week"
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

                        BalanceView()
                            .padding(.bottom, 8)

                        budgetRingCard
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        insightBanner
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        categoryPills
                            .padding(.bottom, 8)

                        WeeklyActivityCard()
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
                    .trim(from: 0, to: min(CGFloat(data.dailySpent / data.dailyBudget), 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.42, blue: 0.16), Color(red: 1.0, green: 0.6, blue: 0.36)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 1) {
                    Text("\(Int((data.dailySpent / data.dailyBudget) * 100))%")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                    Text("used")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("DAILY BUDGET")
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1.5)
                        .foregroundColor(.white.opacity(0.4))
                    Text("$\(String(format: "%.2f", data.dailyRemaining)) left")
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
                                    colors: [Color(red: 1.0, green: 0.42, blue: 0.16), Color(red: 1.0, green: 0.6, blue: 0.36)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * min(CGFloat(data.dailySpent / data.dailyBudget), 1.0), height: 6)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text("$\(String(format: "%.2f", data.dailySpent)) spent")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                    Text("of $\(String(format: "%.0f", data.dailyBudget))")
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

    // MARK: - Category Pills
    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
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
                ForEach(upcomingRecurring) { sub in
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(sub.bgColor)
                            .frame(width: 36, height: 36)
                            .overlay(recurringIcon(for: sub.iconName, color: sub.iconColor))

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
                ForEach(data.recentTransactions) { tx in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(tx.bgColor)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(tx.borderColor, lineWidth: 1))
                                .frame(width: 40, height: 40)
                            Image(systemName: tx.icon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(tx.iconColor)
                        }

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
        .sheet(isPresented: $showTransactions) {
            TransactionsView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func recurringIcon(for name: String, color: Color) -> some View {
        switch name {
        case "netflix":
            Text("N").font(.system(size: 16, weight: .black, design: .serif)).foregroundColor(.red)
        case "spotify":
            Image(systemName: "music.note").font(.system(size: 14, weight: .medium)).foregroundColor(color)
        case "notion":
            Text("N").font(.system(size: 14, weight: .semibold)).foregroundColor(.black)
        case "youtube":
            Image(systemName: "play.rectangle.fill").font(.system(size: 14, weight: .medium)).foregroundColor(color)
        default:
            Image(systemName: name).font(.system(size: 14, weight: .medium)).foregroundColor(color)
        }
    }
}

#Preview {
    SpendingHomeView()
}
