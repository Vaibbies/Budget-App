import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            // 🔥 Full-screen gradient (fixed, non-scrolling)
            LinearGradient(
                colors: [
                    Color(red: 0.74, green: 0.48, blue: 0.25), // dark orange
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {

                // Space for Dynamic Island
                Spacer().frame(height: 80)

                // BALANCE
                Text("BALANCE")
                    .font(.caption)
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.7))

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("$")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.7))

                    Text("124.50")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundColor(.white)
                }

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

                // 🔥 THIS is the key: very small gap
                Spacer().frame(height: 6)

                WeeklyActivityCard()
                TransactionsCard()

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}
