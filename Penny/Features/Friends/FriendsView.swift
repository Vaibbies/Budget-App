import SwiftUI

struct FriendsView: View {
    @State private var showSettleModal = false
    @State private var showAddFriendModal = false
    @State private var showMenuModal = false

    var body: some View {
        ZStack {
            // Background - Much darker, almost black
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                FriendsHeader(
                    onMenuClick: { }, 
                    onAddClick: { showAddFriendModal = true }
                )

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Settlement Balance Card
                        SettlementBalanceCard(
                            balance: FriendsData.settlementBalance,
                            onSettleClick: { showSettleModal = true }
                        )
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)

                        // Pending Requests Section
                        if !FriendsData.pendingRequests.isEmpty {
                            PendingRequestsSection()
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                        }

                        // Shared Expenses Section
                        if !FriendsData.sharedExpenses.isEmpty {
                            SharedExpensesSection()
                                .padding(.horizontal, 24)
                                .padding(.bottom, 24)
                        }

                        // All Friends Section
                        AllFriendsSection()
                            .padding(.horizontal, 24)

                        // Bottom padding for tab bar
                        Color.clear.frame(height: 100)
                    }
                }
            }

            // Menu overlay stays as-is (optional)
            if showMenuModal {
                MenuModal(isPresented: $showMenuModal)
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
}

// MARK: - Pending Requests Section
struct PendingRequestsSection: View {
    let requests = FriendsData.pendingRequests

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PENDING REQUESTS")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))

                Spacer()

                // New badge - outlined style
                Text("\(requests.count) NEW")
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
                ForEach(requests) { request in
                    PendingRequestCard(request: request)
                }
            }
        }
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
