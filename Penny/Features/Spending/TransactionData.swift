import SwiftUI

// MARK: - Transaction Model
struct SpendingTransaction: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let time: String
    let amount: String
    let isImpulse: Bool
    let iconColor: Color
    let bgColor: Color
    let borderColor: Color
}

// MARK: - Transaction Group (by day)
struct SpendingTransactionGroup: Identifiable {
    let id = UUID()
    let title: String
    let transactions: [SpendingTransaction]
}

// MARK: - Shared Data
@Observable
class TransactionData {
    static let shared = TransactionData()
    
    var groups: [SpendingTransactionGroup] = [
        SpendingTransactionGroup(title: "Today", transactions: [
            SpendingTransaction(
                icon: "cup.and.saucer.fill",
                title: "Blue Bottle",
                subtitle: "Coffee & Pastry",
                time: "08:42 AM",
                amount: "-$12.50",
                isImpulse: false,
                iconColor: Color(red: 1.0, green: 0.416, blue: 0.165),
                bgColor: Color.orange.opacity(0.1),
                borderColor: Color.orange.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "car.fill",
                title: "Uber Trip",
                subtitle: "Transport",
                time: "10:15 AM",
                amount: "-$24.20",
                isImpulse: false,
                iconColor: Color.blue.opacity(0.8),
                bgColor: Color.blue.opacity(0.1),
                borderColor: Color.blue.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "bag.fill",
                title: "Target",
                subtitle: "Shopping",
                time: "12:30 PM",
                amount: "-$47.83",
                isImpulse: true,
                iconColor: Color.red.opacity(0.8),
                bgColor: Color.red.opacity(0.1),
                borderColor: Color.red.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "fork.knife",
                title: "Chipotle",
                subtitle: "Dining",
                time: "01:15 PM",
                amount: "-$14.25",
                isImpulse: false,
                iconColor: Color(red: 0.2, green: 0.78, blue: 0.55),
                bgColor: Color.green.opacity(0.1),
                borderColor: Color.green.opacity(0.2)
            ),
        ]),
        SpendingTransactionGroup(title: "Yesterday", transactions: [
            SpendingTransaction(
                icon: "fork.knife",
                title: "Sweetgreen Salads",
                subtitle: "Dining",
                time: "01:30 PM",
                amount: "-$18.90",
                isImpulse: false,
                iconColor: Color(red: 0.2, green: 0.78, blue: 0.55),
                bgColor: Color.green.opacity(0.1),
                borderColor: Color.green.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "tram.fill",
                title: "CalTrain Ticket",
                subtitle: "Transport",
                time: "05:45 PM",
                amount: "-$12.00",
                isImpulse: false,
                iconColor: Color.blue.opacity(0.8),
                bgColor: Color.blue.opacity(0.1),
                borderColor: Color.blue.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "gamecontroller.fill",
                title: "Steam Store",
                subtitle: "Entertainment",
                time: "09:41 PM",
                amount: "-$59.99",
                isImpulse: true,
                iconColor: Color.purple.opacity(0.8),
                bgColor: Color.purple.opacity(0.1),
                borderColor: Color.purple.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "cup.and.saucer.fill",
                title: "Ritual Coffee",
                subtitle: "Lifestyle",
                time: "09:12 AM",
                amount: "-$5.75",
                isImpulse: false,
                iconColor: Color(red: 1.0, green: 0.416, blue: 0.165),
                bgColor: Color.orange.opacity(0.1),
                borderColor: Color.orange.opacity(0.2)
            ),
        ]),
        SpendingTransactionGroup(title: "Monday", transactions: [
            SpendingTransaction(
                icon: "bolt.fill",
                title: "PG&E Electric",
                subtitle: "Utilities",
                time: "Auto-Pay",
                amount: "-$82.40",
                isImpulse: false,
                iconColor: Color.yellow.opacity(0.9),
                bgColor: Color.yellow.opacity(0.1),
                borderColor: Color.yellow.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "cart.fill",
                title: "Trader Joe's",
                subtitle: "Groceries",
                time: "11:20 AM",
                amount: "-$63.17",
                isImpulse: false,
                iconColor: Color(red: 0.2, green: 0.78, blue: 0.55),
                bgColor: Color.green.opacity(0.1),
                borderColor: Color.green.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "dumbbell.fill",
                title: "Equinox",
                subtitle: "Fitness",
                time: "Auto-Pay",
                amount: "-$95.00",
                isImpulse: true,
                iconColor: Color(red: 1.0, green: 0.416, blue: 0.165),
                bgColor: Color.orange.opacity(0.1),
                borderColor: Color.orange.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "music.note",
                title: "Spotify Premium",
                subtitle: "Subscriptions",
                time: "Auto-Pay",
                amount: "-$10.99",
                isImpulse: false,
                iconColor: Color.green.opacity(0.8),
                bgColor: Color.green.opacity(0.1),
                borderColor: Color.green.opacity(0.2)
            ),
        ]),
        SpendingTransactionGroup(title: "Last Sunday", transactions: [
            SpendingTransaction(
                icon: "fuelpump.fill",
                title: "Shell Gas",
                subtitle: "Transport",
                time: "10:05 AM",
                amount: "-$52.30",
                isImpulse: false,
                iconColor: Color.blue.opacity(0.8),
                bgColor: Color.blue.opacity(0.1),
                borderColor: Color.blue.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "film.fill",
                title: "AMC Theatres",
                subtitle: "Entertainment",
                time: "07:30 PM",
                amount: "-$28.50",
                isImpulse: true,
                iconColor: Color.purple.opacity(0.8),
                bgColor: Color.purple.opacity(0.1),
                borderColor: Color.purple.opacity(0.2)
            ),
            SpendingTransaction(
                icon: "cup.and.saucer.fill",
                title: "Philz Coffee",
                subtitle: "Lifestyle",
                time: "09:00 AM",
                amount: "-$7.25",
                isImpulse: false,
                iconColor: Color(red: 1.0, green: 0.416, blue: 0.165),
                bgColor: Color.orange.opacity(0.1),
                borderColor: Color.orange.opacity(0.2)
            ),
        ]),
    ]
    
    var recentTransactions: [SpendingTransaction] {
        groups.flatMap { $0.transactions }.prefix(3).map { $0 }
    }
}
