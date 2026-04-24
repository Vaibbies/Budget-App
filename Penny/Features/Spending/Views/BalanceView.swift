import SwiftUI

struct BalanceView: View {
    private var data = TransactionData.shared
    var onTap: (() -> Void)? = nil

    init(onTap: (() -> Void)? = nil) {
        self.onTap = onTap
    }

    var wholepart: String { String(format: "%.0f", floor(data.dailySpent)) }
    var centsPart: String { String(format: "%02.0f", (data.dailySpent.truncatingRemainder(dividingBy: 1)) * 100) }

    var body: some View {
        Button {
            Haptics.light()
            onTap?()
        } label: {
            VStack(spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(.white.opacity(0.6))

                    Text(wholepart)
                        .font(.system(size: 64, weight: .light, design: .serif))
                        .foregroundColor(.white)

                    Text(".\(centsPart)")
                        .font(.system(size: 40, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.6))
                }
                .shadow(color: .black.opacity(0.8), radius: 14, x: 0, y: 10)
                .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15), radius: 30)

                Text("DAILY SPENT")
                    .font(.caption)
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.7))

                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.16))
                        .frame(width: 6, height: 6)
                        .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16), radius: 3)

                    Text("$\(String(format: "%.2f", data.dailyRemaining)) remaining")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
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
        .buttonStyle(.plain)
    }
}
