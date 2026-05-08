import SwiftUI

struct AppModeOnboardingView: View {
    @Environment(TransactionData.self) private var data
    @AppStorage(TransactionData.hasCompletedOnboardingKey) private var hasCompletedOnboarding = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.14, blue: 0.07),
                    Color(red: 0.12, green: 0.07, blue: 0.05),
                    .black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 22) {
                Spacer(minLength: 10)

                Text("Welcome to Penny")
                    .font(.system(size: 38, weight: .semibold, design: .serif))
                    .foregroundColor(.white)

                Text("Choose how you want to start. You can explore a polished demo or begin with a clean manual setup.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 16) {
                    modeCard(
                        title: "Try Demo Mode",
                        subtitle: "See realistic accounts, spending, budgets, investments, and recurring bills already connected.",
                        eyebrow: "Guided Preview",
                        bulletPoints: [
                            "Preloaded dashboard and cash flow",
                            "Sample investments and subscriptions",
                            "Useful for screenshots and product review"
                        ],
                        accent: Color(red: 1.0, green: 0.49, blue: 0.23)
                    ) {
                        activate(.demo)
                    }

                    modeCard(
                        title: "Start in Real Mode",
                        subtitle: "Begin empty and enter your own accounts, budget, transactions, and recurring bills from scratch.",
                        eyebrow: "Clean Start",
                        bulletPoints: [
                            "No fake balances or transactions",
                            "Manual-first setup for your real data",
                            "Best path for actual day-to-day use"
                        ],
                        accent: Color(red: 0.49, green: 0.90, blue: 0.54)
                    ) {
                        activate(.real)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
    }

    private func activate(_ mode: AppDataMode) {
        data.activateMode(mode)
        hasCompletedOnboarding = true
    }

    private func modeCard(
        title: String,
        subtitle: String,
        eyebrow: String,
        bulletPoints: [String],
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(eyebrow.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(2)
                        .foregroundColor(accent.opacity(0.9))

                    Spacer()

                    Circle()
                        .fill(accent.opacity(0.15))
                        .frame(width: 42, height: 42)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.9))
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.66))
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(bulletPoints, id: \.self) { bullet in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(accent)
                                .frame(width: 7, height: 7)
                            Text(bullet)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.84))
                        }
                    }
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.06),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
