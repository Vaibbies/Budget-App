import SwiftUI

struct WeeklyActivityCard: View {

    private let days = ["M", "T", "W", "T", "F", "S", "S"]
    private let activeDayIndex = 2 // W

    // Hard-coded visual data (UI-only, replace later with real data)
    private let activityLevels: [[Bool]] = [
        [true, false, false, false, false, false],
        [true, true, false, false, false, false],
        [true, true, true, true, false, false],
        [true, true, true, false, false, false],
        [true, true, true, true, true, false],
        [true, true, true, true, false, false],
        [true, true, true, false, false, false]
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack {
                Text("Weekly Activity")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)

                    Text("IMPULSE")
                        .font(.caption2)
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            // Dot grid
            HStack(spacing: 20) {
                ForEach(days.indices, id: \.self) { dayIndex in
                    VStack(spacing: 10) {

                        // Vertical dots
                        VStack(spacing: 7) {
                            ForEach(activityLevels[dayIndex].indices, id: \.self) { dotIndex in
                                Circle()
                                    .fill(
                                        activityLevels[dayIndex][dotIndex]
                                            ? Color.orange
                                            : Color.white.opacity(0.12)
                                    )
                                    .frame(width: 6, height: 6)
                                    .shadow(
                                        color:
                                            dayIndex == activeDayIndex &&
                                            activityLevels[dayIndex][dotIndex]
                                                ? Color.orange.opacity(0.55)
                                                : .clear,
                                        radius: 4
                                    )
                            }
                        }

                        // Day label
                        Text(days[dayIndex])
                            .font(.caption2)
                            .foregroundColor(
                                dayIndex == activeDayIndex
                                    ? Color.orange
                                    : Color.white.opacity(0.45)
                            )
                    }
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.black.opacity(0.42))
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
        WeeklyActivityCard()
    }
}
