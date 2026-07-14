import SwiftUI

struct WeeklyActivityCard: View {

    private let days = ["M", "T", "W", "T", "F", "S", "S"]
    private let activeDayIndex = 2 // W

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // MARK: - Header
            HStack {
                Text("Weekly Activity")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)

                    Text("IMPULSE")
                        .font(.caption2)
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            HStack(spacing: 0) {
                ForEach(days.indices, id: \.self) { index in
                    VStack(spacing: 20) {

                        VStack(spacing: 14) {
                            ForEach(0..<6, id: \.self) { dot in
                                Circle()
                                    .fill(
                                        dot <= index
                                        ? Color.orange
                                        : Color.white.opacity(0.12)
                                    )
                                    .frame(width: 9, height: 9)
                                    .shadow(
                                        color: index == activeDayIndex && dot <= index
                                        ? Color.orange.opacity(0.6)
                                        : .clear,
                                        radius: 3
                                    )
                            }
                        }

                        Text(days[index])
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(
                                index == activeDayIndex
                                ? Color.orange
                                : Color.white.opacity(0.5)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(red: 0.08, green: 0.06, blue: 0.05).opacity(0.6))
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        WeeklyActivityCard()
    }
}
