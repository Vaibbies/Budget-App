import SwiftUI

// MARK: - Pending Request Model
struct PendingRequest: Identifiable {
    let id: Int
    let name: String
    let seed: String
    let description: String
    let time: String
    let amount: Double
    let type: RequestType
}

enum RequestType {
    case request
    case owe
}

// MARK: - Shared Expense Model
struct SharedExpense: Identifiable {
    let id: Int
    let title: String?
    let name: String?
    let description: String
    let amount: Double
    let status: String
    let avatars: [String]?
    let seed: String?
    let type: ExpenseType
}

enum ExpenseType {
    case split
    case outstanding
    case settled
}

// MARK: - Friend Model
struct Friend: Identifiable {
    let id: Int
    let name: String
    let initials: String
    let description: String
    let amount: Double
    let status: FriendStatus
    let hasGradient: Bool
}

enum FriendStatus {
    case owesYou
    case youOwe
    case settled
}

// MARK: - Local Data Placeholder (Replace with real persistence/API later)
struct FriendsData {
    static let settlementBalance: Double = 0.0

    static let pendingRequests: [PendingRequest] = []

    static let sentRequests: [PendingRequest] = []

    static let sharedExpenses: [SharedExpense] = []

    static let allFriends: [Friend] = []
}
