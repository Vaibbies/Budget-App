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
        ZStack {
            Circle()
                .fill(Color.orange.opacity(0.35))
                .frame(width: 72, height: 72)
                .blur(radius: 18)

            Circle()
                .fill(Color.orange)
                .frame(width: 58, height: 58)

            Image(systemName: "briefcase.fill")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.white)
        }
        .offset(y: -24)
    }
}
