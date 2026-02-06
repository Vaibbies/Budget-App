import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .spending

    var body: some View {
        ZStack(alignment: .bottom) {
            HomeView()

            BottomBar(selectedTab: $selectedTab)
        }
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
