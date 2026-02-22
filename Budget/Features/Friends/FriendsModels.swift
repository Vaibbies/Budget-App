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

// MARK: - Sample Data (Replace with API calls later)
struct FriendsData {
    static let settlementBalance: Double = 412.50
    
    static let pendingRequests: [PendingRequest] = [
        PendingRequest(
            id: 1,
            name: "Felix Vance",
            seed: "Felix",
            description: "DINNER AT GUSTO'S",
            time: "Yesterday",
            amount: 45.00,
            type: .request
        ),
        PendingRequest(
            id: 2,
            name: "Sarah Jenkins",
            seed: "Sarah",
            description: "MOVIE TICKETS",
            time: "Fri",
            amount: -22.50,
            type: .owe
        )
    ]
    
    static let sharedExpenses: [SharedExpense] = [
        SharedExpense(
            id: 1,
            title: "Road Trip Fuel",
            name: nil,
            description: "Split 3 ways",
            amount: 124.00,
            status: "2/3 Paid",
            avatars: ["Leo", "Mia"],
            seed: nil,
            type: .split
        ),
        SharedExpense(
            id: 2,
            title: nil,
            name: "Cooper H.",
            description: "Electricity Bill • Oct",
            amount: 221.00,
            status: "Outstanding",
            avatars: nil,
            seed: "Cooper",
            type: .outstanding
        ),
        SharedExpense(
            id: 3,
            title: nil,
            name: "Maya Smith",
            description: "Coffee • Completed",
            amount: 6.50,
            status: "Settled",
            avatars: nil,
            seed: "Maya",
            type: .settled
        )
    ]
    
    static let allFriends: [Friend] = [
        Friend(
            id: 1,
            name: "Julian Smith",
            initials: "JS",
            description: "Last split 2d ago",
            amount: -12.40,
            status: .youOwe,
            hasGradient: false
        ),
        Friend(
            id: 2,
            name: "Maya Kapoor",
            initials: "MK",
            description: "Coffee & Bagels",
            amount: 188.00,
            status: .owesYou,
            hasGradient: true
        ),
        Friend(
            id: 3,
            name: "David Lee",
            initials: "DL",
            description: "Settled last week",
            amount: 0.00,
            status: .settled,
            hasGradient: false
        )
    ]
}
