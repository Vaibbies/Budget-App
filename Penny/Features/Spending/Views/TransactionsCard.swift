import SwiftUI

struct TransactionsCard: View {
    @Environment(SpendingStore.self) private var spending
    @State private var showTransactions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header — tappable to open full Transactions view
            Button {
                showTransactions = true
            } label: {
                HStack {
                    Text("TRANSACTIONS")
                        .font(.caption)
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Spacer()
                    
                    Text("Impulse toggle")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            // Transactions list — latest 3 from shared data
            VStack(spacing: 0) {
                ForEach(Array(spending.recentTransactions.enumerated()), id: \.element.id) { index, transaction in
                    TransactionRow(
                        icon: transaction.icon,
                        title: transaction.title,
                        subtitle: transaction.subtitle,
                        amount: transaction.amount,
                        highlight: transaction.isImpulse,
                        isOn: transaction.isImpulse
                    )
                    
                    if index < spending.recentTransactions.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.08))
                            .padding(.horizontal, 16)
                    }
                }
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
        .fullScreenCover(isPresented: $showTransactions) {
            TransactionsView()
        }
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
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 42, height: 42)
                
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.semibold))
                
                Text(subtitle)
                    .foregroundColor(.white.opacity(0.5))
                    .font(.caption)
            }
            
            Spacer()
            
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
