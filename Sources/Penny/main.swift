import SwiftUI

@main
struct PennyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, Penny!")
            .padding()
    }
}