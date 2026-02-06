import SwiftUI

struct TransactionRow: View {

    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let amount: String
    let amountColor: Color
    let isImpulse: Bool

    var body: some View {
        HStack(spacing: 12) {

            // Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
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
                    .foregroundColor(amountColor)
                    .font(.subheadline.weight(.semibold))

                Toggle("", isOn: .constant(isImpulse))
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: .orange))
                    .scaleEffect(0.8)
                    .disabled(true)
            }
        }
    }
}
