import SwiftUI

// Old custom tab bar is no longer used (system TabView is used instead)
// Keeping this file so the project still builds if other code references TabBarView somewhere.
struct TabBarView: View {
    @Binding var selectedTab: Int
    @Binding var showChat: Bool

    var body: some View {
        EmptyView()
    }
}

#Preview {
    TabBarView(selectedTab: .constant(0), showChat: .constant(false))
}
