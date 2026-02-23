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
                            AllFriendsSection()
                                .padding(.horizontal, 24)
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

#Preview {
    FriendsView()
}
