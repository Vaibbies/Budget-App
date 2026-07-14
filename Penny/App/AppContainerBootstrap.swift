import Foundation

@MainActor
func makeLiveAppContainer() -> AppContainer {
    AppContainer(data: TransactionData.shared)
}

@MainActor
func makePreviewAppContainer() -> AppContainer {
    AppContainer(data: TransactionData.shared)
}
