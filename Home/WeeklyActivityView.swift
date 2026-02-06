import SwiftUI


    let days = ["M", "T", "W", "T", "F", "S", "S"]
    let activity: [[Bool]] = [
        [true,true,true,false,false,false,false,false],
        [true,true,false,false,false,false,false,false],
        [true,true,true,true,false,false,false,false],
        [true,false,false,false,false,false,false,false],
        [true,true,false,false,false,false,false,false],
        [true,true,true,false,false,false,false,false],
        [true,false,false,false,false,false,false,false]
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Text("Weekly Activity")
                    .foregroundColor(.white.opacity(0.85))

                Spacer()

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)

                    Text("IMPULSE")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            HStack(spacing: 18) {
                ForEach(days.indices, id: \.self) { index in
                    VStack(spacing: 6) {
                        ForEach(activity[index].indices, id: \.self) { dot in
                            Circle()
                                .fill(activity[index][dot]
                                      ? Color.orange
                                      : Color.white.opacity(0.15))
                                .frame(width: 6, height: 6)
                        }

                        Text(days[index])
                            .font(.caption2)
                            .foregroundColor(index == 2 ? .orange : .white.opacity(0.4))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.06))
        )
        .padding(.horizontal)
    }

