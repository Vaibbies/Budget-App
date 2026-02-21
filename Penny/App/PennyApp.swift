import SwiftUI

@main
struct PennyApp: App {
    @State private var data = TransactionData.shared
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(data)
        }
    }
}
