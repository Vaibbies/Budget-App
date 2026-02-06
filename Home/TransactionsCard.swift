import SwiftUI

struct TransactionsCard: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack {
                Text("TRANSACTIONS")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1.5)

                Spacer()

                Text("Impulse toggle")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.35))
            }

            // Transactions list
            VStack(spacing: 14) {
                TransactionRow(
                    icon: "cup.and.saucer.fill",
                    iconColor: .white,
                    title: "Blue Bottle",
                    subtitle: "Coffee & Pastry",
                    amount: "-$12.50",
                    amountColor: .white,
                    isImpulse: false
                )

                Divider()
                    .background(Color.white.opacity(0.06))

                TransactionRow(
                    icon: "gamecontroller.fill",
                    iconColor: .orange,
                    title: "Steam Store",
                    subtitle: "Entertainment",
                    amount: "-$59.99",
                    amountColor: .orange,
                    isImpulse: true
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.06))
                )
        )
        .padding(.horizontal)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TransactionsCard()
    }
}
