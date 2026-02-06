import SwiftUI

struct BalanceHeaderView: View {

    var body: some View {
        ZStack {
            // Fixed gradient background (does NOT scroll)
            LinearGradient(
                colors: [
                    Color.orange.opacity(0.85),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 12) {

                Spacer().frame(height: 80)

                // BALANCE label
                Text("BALANCE")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.7))

                // Amount
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.7))

                    Text("124.50")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundColor(.white)
                }

                // DAILY SPENT
                Text("DAILY SPENT")
                    .font(.caption)
                    .tracking(1.5)
                    .foregroundColor(.white.opacity(0.6))

                // Remaining pill
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)

                    Text("$45.50 remaining")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())

                Spacer().frame(height: 12)
            }
        }
    }
}

#Preview {
    BalanceHeaderView()
}
