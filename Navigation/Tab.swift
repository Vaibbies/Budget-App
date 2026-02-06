import SwiftUI

enum AppTab: CaseIterable {
    case friends
    case spending
    case me
    case bank

    var icon: String {
        switch self {
        case .friends: return "person.2"
        case .spending: return "briefcase.fill"
        case .me: return "face.smiling"
        case .bank: return "creditcard"
        }
    }
}
