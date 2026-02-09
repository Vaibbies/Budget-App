import SwiftUI

struct TransactionsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack {
                Text("TRANSACTIONS")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                Text("Impulse toggle")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
            }

            // Transactions list
            VStack(spacing: 0) {
                TransactionRow(
                    icon: "cup.and.saucer.fill",
                    title: "Blue Bottle",
                    subtitle: "Coffee & Pastry",
                    amount: "-$12.50",
                    highlight: false,
                    isOn: false
                )

                Divider()
                    .background(Color.white.opacity(0.08))
                    .padding(.horizontal, 16)

                TransactionRow(
                    icon: "gamecontroller.fill",
                    title: "Steam Store",
                    subtitle: "Entertainment",
                    amount: "-$59.99",
                    highlight: true,
                    isOn: true
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.08, green: 0.06, blue: 0.05).opacity(0.9))
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.08, green: 0.06, blue: 0.05).opacity(0.6))
        )
        .padding(.horizontal, 20)
    }
}

struct TransactionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let amount: String
    let highlight: Bool
    @State var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {

            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.8))
            }

            // Labels
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.semibold))

                Text(subtitle)
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
            }

            Spacer()

            // Amount + toggle
            VStack(alignment: .trailing, spacing: 6) {
                Text(amount)
                    .foregroundColor(highlight ? .orange : .white)
                    .font(.subheadline.weight(.semibold))

                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                    .scaleEffect(0.7)
            }
        }
        .padding(16)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        TransactionsCard()
    }
}
