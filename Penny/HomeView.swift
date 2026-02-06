import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.74, green: 0.48, blue: 0.25),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            Text("HOME VIEW")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HomeView()
}
