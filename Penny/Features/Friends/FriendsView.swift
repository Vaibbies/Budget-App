import SwiftUI

private enum FriendsFilter: String, CaseIterable {
    case overview = "Overview"
    case requests = "Requests"
    case expenses = "Expenses"
    case people = "People"
}

struct FriendsView: View {
    @State private var showSettleModal = false
    @State private var showAddFriendModal = false
    @State private var selectedFilter: FriendsFilter = .overview

    private var pendingCount: Int { FriendsData.pendingRequests.count + FriendsData.sentRequests.count }
    private var activeSharedCount: Int { FriendsData.sharedExpenses.filter { $0.type != .settled }.count }
    private var friendCount: Int { FriendsData.allFriends.count }
    private var hasAnyData: Bool {
        pendingCount > 0 || activeSharedCount > 0 || friendCount > 0 || FriendsData.settlementBalance != 0
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                FriendsHeader(
                    onAddClick: { showAddFriendModal = true }
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        SettlementBalanceCard(
                            balance: FriendsData.settlementBalance,
                            onSettleClick: { showSettleModal = true }
                        )
                        .padding(.horizontal, 24)

                        filterBar
                            .padding(.horizontal, 24)

                        quickStatsRow
                            .padding(.horizontal, 24)

                        if !hasAnyData && selectedFilter == .overview {
                            sectionEmptyState(
                                title: "No friend activity yet",
                                subtitle: "Add friends and shared expenses later. This tab will track requests, splits, and balances when you start using it."
                            )
                            .padding(.horizontal, 24)
                        }

                        if (selectedFilter == .overview || selectedFilter == .expenses) && !FriendsData.sharedExpenses.isEmpty {
                            FriendsChartsSection()
                                .padding(.horizontal, 24)
                        }

                        if selectedFilter == .overview || selectedFilter == .requests {
                            if !FriendsData.pendingRequests.isEmpty || !FriendsData.sentRequests.isEmpty {
                                PendingRequestsSection()
                                    .padding(.horizontal, 24)
                            } else if selectedFilter == .requests {
                                sectionEmptyState(
                                    title: "No requests yet",
                                    subtitle: "Received and sent friend requests will appear here."
                                )
                                .padding(.horizontal, 24)
                            }
                        }

                        if selectedFilter == .overview || selectedFilter == .expenses {
                            if !FriendsData.sharedExpenses.isEmpty {
                                SharedExpensesSection()
                                    .padding(.horizontal, 24)
                            } else if selectedFilter == .expenses {
                                sectionEmptyState(
                                    title: "No shared expenses yet",
                                    subtitle: "Create your first split to start tracking shared spending."
                                )
                                .padding(.horizontal, 24)
                            }
                        }

                        if selectedFilter == .overview || selectedFilter == .people {
                            if !FriendsData.allFriends.isEmpty {
                                AllFriendsSection()
                                    .padding(.horizontal, 24)
                            } else if selectedFilter == .people {
                                sectionEmptyState(
                                    title: "No friends added yet",
                                    subtitle: "People you split with will appear here once you add them."
                                )
                                .padding(.horizontal, 24)
                            }
                        }

                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 8)
                }
            }

        }
        .sheet(isPresented: $showAddFriendModal) {
            AddFriendModal(isPresented: $showAddFriendModal)
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large], selection: .constant(.medium))
        }
        .sheet(isPresented: $showSettleModal) {
            SettleUpModal(isPresented: $showSettleModal)
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large], selection: .constant(.medium))
        }
    }

    private var background: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.22),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(FriendsFilter.allCases, id: \.self) { filter in
                Button {
                    selectedFilter = filter
                    Haptics.light()
                } label: {
                    Text(filter.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selectedFilter == filter ? .black : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(
                            Capsule()
                                .fill(selectedFilter == filter ? Color.white : Color.white.opacity(0.08))
                                .overlay(
                                    Capsule().stroke(Color.white.opacity(0.08), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var quickStatsRow: some View {
        HStack(spacing: 10) {
            quickStatCard(title: "Pending", value: "\(pendingCount)")
            quickStatCard(title: "Active Splits", value: "\(activeSharedCount)")
            quickStatCard(title: "Friends", value: "\(friendCount)")
        }
    }

    private func quickStatCard(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.2)
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func sectionEmptyState(title: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - Charts Section
struct FriendsChartsSection: View {
    private let weeklySplitTotals: [Double] = []
    private var friendBars: [(name: String, amount: Double)] {
        FriendsData.allFriends
            .filter { $0.amount != 0 }
            .map { ($0.name, $0.amount) }
            .sorted { abs($0.amount) > abs($1.amount) }
    }
    private var maxBarValue: Double {
        max(friendBars.map { abs($0.amount) }.max() ?? 1, 1)
    }

    var body: some View {
        VStack(spacing: 12) {
            trendCard
            barChartCard
        }
    }

    private var trendCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WEEKLY SPLIT TREND")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.8)
                .foregroundColor(.white.opacity(0.45))

            if weeklySplitTotals.isEmpty {
                emptyChartCard("No split trend yet")
            } else {
                GeometryReader { geo in
                    let width = geo.size.width
                    let height = geo.size.height
                    let maxValue = max(weeklySplitTotals.max() ?? 1, 1)
                    let minValue = min(weeklySplitTotals.min() ?? 0, 0)
                    let range = max(maxValue - minValue, 1)
                    let points = weeklySplitTotals.enumerated().map { index, value in
                        CGPoint(
                            x: width * CGFloat(index) / CGFloat(max(weeklySplitTotals.count - 1, 1)),
                            y: height - ((CGFloat(value - minValue) / CGFloat(range)) * height)
                        )
                    }

                    ZStack(alignment: .bottomLeading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))

                        VStack(spacing: 0) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(0.06))
                                    .frame(height: 1)
                                Spacer()
                            }
                        }
                        .padding(.vertical, 8)

                        SparklineAreaShape(points: points)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.30),
                                        Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.02)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        SparklineShape(points: points)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.58, blue: 0.35),
                                        Color(red: 1.0, green: 0.42, blue: 0.16)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                            )
                    }
                }
                .frame(height: 108)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private var barChartCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WHO OWES WHAT")
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.8)
                .foregroundColor(.white.opacity(0.45))

            if friendBars.isEmpty {
                emptyChartCard("No balances with friends")
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(friendBars.enumerated()), id: \.offset) { _, entry in
                        friendBarRow(name: entry.name, amount: entry.amount)
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    private func friendBarRow(name: String, amount: Double) -> some View {
        let ratio = CGFloat(abs(amount) / maxBarValue)
        let barColor = amount >= 0 ? Color(red: 1.0, green: 0.42, blue: 0.16) : Color(red: 0.42, green: 0.65, blue: 1.0)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)

                Spacer()

                Text(amount >= 0 ? "+$\(String(format: "%.2f", amount))" : "-$\(String(format: "%.2f", abs(amount)))")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(barColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(barColor)
                        .frame(width: max(10, geo.size.width * ratio))
                }
            }
            .frame(height: 8)
        }
    }

    private func emptyChartCard(_ title: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.white.opacity(0.03))
            .frame(height: 108)
            .overlay(
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.45))
            )
    }
}

private struct SparklineShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

private struct SparklineAreaShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first, let last = points.last else { return path }
        path.move(to: CGPoint(x: first.x, y: rect.maxY))
        path.addLine(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.addLine(to: CGPoint(x: last.x, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Pending Requests Section
struct PendingRequestsSection: View {
    let receivedRequests = FriendsData.pendingRequests
    let sentRequests = FriendsData.sentRequests
    private var totalCount: Int { receivedRequests.count + sentRequests.count }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PENDING REQUESTS")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))

                Spacer()

                // New badge - outlined style
                Text("\(totalCount) OPEN")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
            }

            VStack(spacing: 12) {
                if !receivedRequests.isEmpty {
                    requestGroupHeader("Received")
                    ForEach(receivedRequests) { request in
                        PendingRequestCard(request: request)
                    }
                }

                if !sentRequests.isEmpty {
                    requestGroupHeader("Sent")
                        .padding(.top, receivedRequests.isEmpty ? 0 : 2)
                    ForEach(sentRequests) { request in
                        PendingRequestCard(request: request)
                    }
                }
            }
        }
    }

    private func requestGroupHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(1.4)
            .foregroundColor(.white.opacity(0.45))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
    }
}

// MARK: - Shared Expenses Section
struct SharedExpensesSection: View {
    let expenses = FriendsData.sharedExpenses
    let activeCount = FriendsData.sharedExpenses.filter { $0.type != .settled }.count

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SHARED EXPENSES")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))

                Spacer()

                Text("\(activeCount) Active")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }

            VStack(spacing: 12) {
                ForEach(expenses) { expense in
                    SharedExpenseRow(expense: expense)
                }
            }
        }
    }
}

// MARK: - All Friends Section
struct AllFriendsSection: View {
    let friends = FriendsData.allFriends

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("ALL FRIENDS")
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            if friends.isEmpty {
                VStack(spacing: 6) {
                    Text("No people yet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    Text("People you add for splits and requests will appear here.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.04))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(friends) { friend in
                        FriendRow(friend: friend)

                        if friend.id != friends.last?.id {
                            Divider()
                                .background(Color.white.opacity(0.08))
                                .padding(.leading, 56)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    FriendsView()
}
