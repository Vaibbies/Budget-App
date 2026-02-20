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

                // ✅ Use List for native scrolling + native swipe actions
                List {
                    ForEach(Array(data.groups.enumerated()), id: \.element.id) { groupIndex, group in
                        Section {
                            ForEach(Array(group.transactions.enumerated()), id: \.element.id) { txIndex, transaction in
                                fullTransactionRow(transaction)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteTransaction(groupIndex: groupIndex, txIndex: txIndex)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        } header: {
                            Text(group.title.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.3))
                                .tracking(2)
                                .padding(.horizontal, 24)
                                .padding(.top, 10)
                                .textCase(nil)
                        }
                    }

                    // bottom breathing room so last row isn’t under nav / home indicator
                    Color.clear
                        .frame(height: 120)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
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
        .padding(.bottom, 16)
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

#Preview {
    TransactionsView()
        .preferredColorScheme(.dark)
}
