import SwiftUI

struct BottomBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            barItem(icon: "person.2", title: "Friends", tab: .friends)
            barItem(icon: "shield", title: "Spending", tab: .spending)

            Spacer(minLength: 0)

            centerButton

            Spacer(minLength: 0)

            barItem(icon: "face.smiling", title: "Me", tab: .me)
            barItem(icon: "creditcard", title: "Bank", tab: .bank)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 28)
        .padding(.top, 16)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.9))
                .blur(radius: 0.5)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Items

    private func barItem(icon: String, title: String, tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(
                        selectedTab == tab ? .white : .white.opacity(0.5)
                    )

                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var centerButton: some View {
        Button {
            // TODO: Handle Penny AI chat action
        } label: {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.5),
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 45
                        )
                    )
                    .frame(width: 90, height: 90)
                    .blur(radius: 15)

                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.55, blue: 0.25),
                                Color(red: 1.0, green: 0.42, blue: 0.16)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.5), radius: 12, x: 0, y: 4)

                // Chat icon
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .offset(y: -30)
    }
}
