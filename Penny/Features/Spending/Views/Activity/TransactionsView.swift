import SwiftUI

// MARK: - Theme
private enum TransactionsTheme {
    static let canvas = Color(red: 0.039, green: 0.043, blue: 0.051)
    static let surface = Color(red: 0.071, green: 0.071, blue: 0.086).opacity(0.7)
    static let ink = Color(red: 0.957, green: 0.961, blue: 0.969)
    static let muted = Color(red: 0.643, green: 0.655, blue: 0.682)
    static let line = Color.white.opacity(0.06)
    static let accent = Color(red: 1.0, green: 0.416, blue: 0.165)
}

// MARK: - TransactionsView
struct TransactionsView: View {
    @Environment(\.dismiss) var dismiss
    private var data = TransactionData.shared
    @State private var showAddTransaction = false

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                headerSection
                spentSection

                ScrollView(.vertical, showsIndicators: false) {
                    transactionsList
                        .padding(.bottom, 120)
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled(false)
        }
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            TransactionsTheme.canvas.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.7),
                    Color(red: 1.0, green: 0.376, blue: 0.125).opacity(0.1),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Button { dismiss() } label: {
                Circle()
                    .fill(TransactionsTheme.surface)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(TransactionsTheme.line, lineWidth: 1))
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(TransactionsTheme.ink)
                    )
            }

            Spacer()

            Text("TRANSACTIONS")
                .font(.system(size: 12, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))

            Spacer()

            Button {
                showAddTransaction = true
                Haptics.medium()
            } label: {
                Circle()
                    .fill(TransactionsTheme.accent)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: TransactionsTheme.accent.opacity(0.5), radius: 8)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Spent This Week
    private var spentSection: some View {
        VStack(spacing: 4) {
            Text("SPENT THIS WEEK")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(TransactionsTheme.muted)
                .tracking(2)

            Text("$\(String(format: "%.2f", data.totalSpent))")
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .tracking(-1)
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
    }

    // MARK: - Transactions List
    private var transactionsList: some View {
        VStack(spacing: 24) {
            ForEach(Array(data.groups.enumerated()), id: \.element.id) { groupIndex, group in
                VStack(alignment: .leading, spacing: 12) {
                    Text(group.title.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(2)
                        .padding(.horizontal, 24)

                    VStack(spacing: 10) {
                        ForEach(Array(group.transactions.enumerated()), id: \.element.id) { txIndex, transaction in
                            SwipeToDeleteRow(
                                onDelete: { deleteTransaction(groupIndex: groupIndex, txIndex: txIndex) }
                            ) {
                                fullTransactionRow(transaction)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
    }

    // MARK: - Delete Transaction
    private func deleteTransaction(groupIndex: Int, txIndex: Int) {
        Haptics.medium()
        var updatedTransactions = data.groups[groupIndex].transactions
        updatedTransactions.remove(at: txIndex)

        if updatedTransactions.isEmpty {
            data.groups.remove(at: groupIndex)
        } else {
            data.groups[groupIndex] = SpendingTransactionGroup(
                title: data.groups[groupIndex].title,
                transactions: updatedTransactions
            )
        }
    }

    // MARK: - Full Transaction Row
    private func fullTransactionRow(_ transaction: SpendingTransaction) -> some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(transaction.bgColor)
                .frame(width: 48, height: 48)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(transaction.borderColor, lineWidth: 1))
                .overlay(
                    Image(systemName: transaction.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(transaction.iconColor)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text("\(transaction.time) • \(transaction.subtitle)")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(TransactionsTheme.muted)
            }

            Spacer()

            Text(transaction.amount)
                .font(.system(size: 17, weight: .medium, design: .serif))
                .foregroundColor(transaction.isImpulse ? TransactionsTheme.accent : .white)
                .tracking(-0.5)
        }
        .padding(16)
        .background(TransactionsTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(TransactionsTheme.line, lineWidth: 1))
        .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
    }
}

// MARK: - Swipe To Delete Row (Mail-style)
// - Swipe a little: reveals trash button (no delete)
// - Tap trash: deletes
// - Full swipe past a larger threshold: deletes (like Mail)
struct SwipeToDeleteRow<Content: View>: View {
    let onDelete: () -> Void
    let content: () -> Content

    @State private var offset: CGFloat = 0
    @State private var isOpen: Bool = false
    @State private var isDeleting: Bool = false

    private let actionWidth: CGFloat = 86              // width of the revealed trash area
    private let openThreshold: CGFloat = 55            // how far you must swipe to “open”
    private let fullSwipeDeleteThreshold: CGFloat = 180 // must swipe far to auto-delete (Mail-like)

    var body: some View {
        ZStack(alignment: .trailing) {

            // Background action (only becomes visible as you drag)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(backgroundOpacity))
                .overlay(
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(trashOpacity)
                )
                .contentShape(RoundedRectangle(cornerRadius: 16))
                .onTapGesture {
                    // Tap to delete only when opened/revealed
                    guard isOpen, !isDeleting else { return }
                    triggerDelete()
                }

            // Foreground row
            content()
                .offset(x: offset)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            guard !isDeleting else { return }
                            let dx = value.translation.width

                            if dx < 0 {
                                // swipe left: allow going well past actionWidth for “full swipe delete”
                                offset = max(dx, -260)
                            } else {
                                // swipe right to close if open
                                if isOpen {
                                    offset = min(0, -actionWidth + dx)
                                }
                            }
                        }
                        .onEnded { value in
                            guard !isDeleting else { return }
                            let dx = value.translation.width

                            // Full swipe delete (must be pretty far)
                            if dx <= -fullSwipeDeleteThreshold {
                                triggerDelete()
                                return
                            }

                            // Otherwise decide open/close
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                                if dx <= -openThreshold {
                                    offset = -actionWidth
                                    isOpen = true
                                } else {
                                    offset = 0
                                    isOpen = false
                                }
                            }
                        }
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var revealProgress: CGFloat {
        // 0 -> 1 as you move from 0 to -actionWidth
        let p = min(1, max(0, (-offset / actionWidth)))
        return p
    }

    private var backgroundOpacity: Double {
        // Prevent “everything looks red” by only showing red while actually swiping/revealed
        Double(0.0 + 0.85 * revealProgress)
    }

    private var trashOpacity: Double {
        Double(revealProgress)
    }

    private func triggerDelete() {
        isDeleting = true
        Haptics.medium()

        // Animate row off-screen, then delete
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
            offset = -500
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            onDelete()
        }
    }
}

#Preview {
    TransactionsView()
        .preferredColorScheme(.dark)
}
