import SwiftUI

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let type: MessageType
    let content: String
    var showTip: Bool = false
    
    enum MessageType {
        case ai
        case user
    }
}
