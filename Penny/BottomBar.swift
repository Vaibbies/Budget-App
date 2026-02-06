import SwiftUI

struct BottomBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack {
            tabButton(title: "Friends", tab: .friends)
            tabButton(title: "Spending", tab: .spending)
            tabButton(title: "Me", tab: .me)
            tabButton(title: "Bank", tab: .bank)
        }
        .padding()
        .background(Color.black.opacity(0.9))
    }

    private func tabButton(title: String, tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Text(title)
                .foregroundColor(
                    selectedTab == tab ? .white : .gray
                )
                .padding(.horizontal)
        }
    }
}
