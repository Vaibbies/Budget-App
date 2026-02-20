import SwiftUI

struct ContentView: View {
    var body: some View {
        MainAppView()
        ZStack {
            Color.red.ignoresSafeArea()
            Text("HELLO PENNY")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ContentView()
}

 
