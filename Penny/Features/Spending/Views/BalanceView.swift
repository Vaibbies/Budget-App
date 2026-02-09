import SwiftUI

struct BalanceView: View {
    var body: some View {
        VStack(spacing: 10) {

            // Amount
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("$")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.white.opacity(0.6))

                Text("124")
                    .font(.system(size: 64, weight: .light, design: .serif))
                    .foregroundColor(.white)

                Text(".50")
                    .font(.system(size: 40, weight: .light, design: .serif))
                    .foregroundColor(.white.opacity(0.6))
            }
            .shadow(color: .black.opacity(0.8), radius: 14, x: 0, y: 10)
            .shadow(
                color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15),
                radius: 30
            )

            // Subtitle
            Text("DAILY SPENT")
                .font(.caption)
                .tracking(3)
                .foregroundColor(.white.opacity(0.7))

            // Remaining pill
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(red: 1.0, green: 0.42, blue: 0.16))
                    .frame(width: 6, height: 6)
                    .shadow(
                        color: Color(red: 1.0, green: 0.42, blue: 0.16),
                        radius: 3
                    )

                Text("$45.50 remaining")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.15, green: 0.10, blue: 0.08).opacity(0.7))
        )
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }
}
