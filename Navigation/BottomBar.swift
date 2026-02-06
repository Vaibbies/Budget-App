import SwiftUI

struct BottomBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            BottomBarItem(
                icon: "person.2",
                title: "Friends",
                isSelected: selectedTab == .friends
            ) {
                selectedTab = .friends
            }
            .frame(maxWidth: .infinity)

            BottomBarItem(
                icon: "shield",
                title: "Spending",
                isSelected: selectedTab == .spending
            ) {
                selectedTab = .spending
            }
            .frame(maxWidth: .infinity)

            // CENTER BUTTON
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
            .frame(maxWidth: .infinity)

            BottomBarItem(
                icon: "face.smiling",
                title: "Me",
                isSelected: selectedTab == .me
            ) {
                selectedTab = .me
            }
            .frame(maxWidth: .infinity)

            BottomBarItem(
                icon: "creditcard",
                title: "Bank",
                isSelected: selectedTab == .bank
            ) {
                selectedTab = .bank
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(Color.black.opacity(0.9))
        )
        .padding(.horizontal)
    }
}
