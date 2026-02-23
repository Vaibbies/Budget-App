import SwiftUI

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 18))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 3)
                )
        }
    }
}

struct FriendsHeader: View {
    let onAddClick: () -> Void
    
    var body: some View {
        HStack {
            Color.clear
                .frame(width: 40, height: 40)
            
            Text("FRIENDS")
                .font(.system(size: 12, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
            
            IconButton(icon: "person.badge.plus", action: onAddClick)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Settlement Balance Card
struct SettlementBalanceCard: View {
    let balance: Double
    let onSettleClick: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("TOTAL YOU'RE OWED")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.4))
                
                Text("$\(String(format: "%.2f", balance))")
                    .font(.system(size: 30, weight: .medium, design: .serif))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: onSettleClick) {
                Text("Settle Expense")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.55, blue: 0.36),
                                        Color(red: 1.0, green: 0.42, blue: 0.16)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Pending Request Card (with Remind/Settle buttons)
struct PendingRequestCard: View {
    let request: PendingRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                // Avatar with color based on name
                ZStack {
                    Circle()
                        .stroke(avatarColor(for: request.seed), lineWidth: 2)
                        .frame(width: 48, height: 48)
                    
                    Text(getInitials(for: request.name))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(avatarColor(for: request.seed))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(request.time)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(request.amount >= 0 ? "+$\(String(format: "%.2f", request.amount))" : "-$\(String(format: "%.2f", abs(request.amount)))")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(request.amount >= 0 ? Color(red: 1.0, green: 0.42, blue: 0.16) : .white)
                    
                    Text(request.description)
                        .font(.system(size: 9, weight: .medium))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Text("Remind")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                }
                
                Button(action: {}) {
                    Text("Settle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.55, blue: 0.36),
                                            Color(red: 1.0, green: 0.42, blue: 0.16)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    func getInitials(for name: String) -> String {
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)"
        }
        return String(name.prefix(2))
    }
    
    func avatarColor(for seed: String) -> Color {
        switch seed {
        case "Felix": // Felix - Purple
            return Color(red: 0.6, green: 0.4, blue: 0.9)
        case "Sarah": // Sarah - Pink
            return Color(red: 1.0, green: 0.4, blue: 0.6)
        default:
            return Color.white.opacity(0.5)
        }
    }
}

// MARK: - Shared Expense Row
struct SharedExpenseRow: View {
    let expense: SharedExpense
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar - overlapping circles for splits, single for others
            if let avatars = expense.avatars {
                // Overlapping avatars for splits
                HStack(spacing: -12) {
                    AvatarView(seed: avatars[0], size: 40, hasGradient: true)
                    AvatarView(seed: avatars[1], size: 40, hasGradient: true)
                }
                .padding(.trailing, 4)
            } else if let seed = expense.seed {
                AvatarView(seed: seed, size: 40, hasGradient: true)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title ?? expense.name ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(expense.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("+$\(String(format: "%.2f", expense.amount))")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(expense.status.uppercased())
                    .font(.system(size: 9, weight: .medium))
                    .tracking(1)
                    .foregroundColor(statusColor(for: expense.type))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
    
    func statusColor(for type: ExpenseType) -> Color {
        switch type {
        case .split:
            return Color.orange.opacity(0.7)
        case .outstanding:
            return Color.red.opacity(0.7)
        case .settled:
            return Color.green.opacity(0.7)
        }
    }
}

// MARK: - Friend Row
struct FriendRow: View {
    let friend: Friend
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar/Initials with correct colors
            ZStack {
                Circle()
                    .stroke(avatarStrokeColor(for: friend), lineWidth: 2)
                    .frame(width: 48, height: 48)
                
                Text(friend.initials)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(avatarStrokeColor(for: friend))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(friend.description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if friend.status == .settled {
                    Text("$\(String(format: "%.2f", friend.amount))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                } else {
                    Text(friend.amount >= 0 ? "+$\(String(format: "%.2f", friend.amount))" : "-$\(String(format: "%.2f", abs(friend.amount)))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(amountColor(for: friend))
                }
                
                Text(statusText(for: friend.status))
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundColor(statusTextColor(for: friend.status))
            }
        }
        .padding(.vertical, 12)
    }
    
    func avatarStrokeColor(for friend: Friend) -> Color {
        switch friend.initials {
        case "JS": // Julian Smith - teal/cyan
            return Color(red: 0.3, green: 0.9, blue: 0.8)
        case "MK": // Maya Kapoor - orange/gold
            return Color(red: 1.0, green: 0.7, blue: 0.2)
        case "DL": // David Lee - gray
            return Color(red: 0.5, green: 0.5, blue: 0.55)
        default:
            return Color.white.opacity(0.5)
        }
    }
    
    func amountColor(for friend: Friend) -> Color {
        if friend.amount >= 0 {
            return Color(red: 1.0, green: 0.42, blue: 0.16) // Orange for owes you
        } else {
            return .white // White for you owe
        }
    }
    
    func statusText(for status: FriendStatus) -> String {
        switch status {
        case .owesYou:
            return "OWES YOU"
        case .youOwe:
            return "YOU OWE"
        case .settled:
            return "SETTLED"
        }
    }
    
    func statusTextColor(for status: FriendStatus) -> Color {
        switch status {
        case .owesYou:
            return Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.7)
        case .youOwe:
            return Color.red.opacity(0.7)
        case .settled:
            return Color.white.opacity(0.4)
        }
    }
}

// MARK: - Avatar View
struct AvatarView: View {
    let seed: String
    let size: CGFloat
    let hasGradient: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: "https://api.dicebear.com/7.x/avataaars/svg?seed=\(seed)")) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Circle()
                .fill(Color.gray.opacity(0.3))
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(
                    hasGradient ?
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.5),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) : LinearGradient(colors: [.clear], startPoint: .top, endPoint: .bottom),
                    lineWidth: 2
                )
        )
    }
}
