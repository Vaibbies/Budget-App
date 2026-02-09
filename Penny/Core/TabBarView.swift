import SwiftUI

// MARK: - Bottom Bar

struct BottomBarMock: View {
    @Binding var selectedTab: Int
    @Binding var showChat: Bool
    
    var body: some View {
        ZStack {
            // Subtle glass morphism background
            Capsule()
                .fill(.ultraThinMaterial)
                .background(
                    Capsule()
                        .fill(
                            Color.black.opacity(0.6)
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(
                            Color.white.opacity(0.15),
                            lineWidth: 0.5
                        )
                )
                .frame(height: 70)
                .padding(.horizontal, 20)
                .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 8)

            HStack(spacing: 0) {
                BottomIcon("person.2", "Friends", isSelected: selectedTab == 0)
                    .onTapGesture { selectedTab = 0 }
                
                BottomIcon("dollarsign", "Spending", isSelected: selectedTab == 1)
                    .onTapGesture { selectedTab = 1 }

                // Center button - opens chat
                Button(action: {
                    showChat = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 70, height: 70)
                            .shadow(color: Color.orange.opacity(0.5), radius: 12)
                        Image(systemName: "message.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 26, weight: .medium))
                    }
                }
                .offset(y: -22)
                .frame(maxWidth: .infinity)

                BottomIcon("person.fill", "Me", isSelected: selectedTab == 2)
                    .onTapGesture { selectedTab = 2 }
                
                BottomIcon("creditcard", "Bank", isSelected: selectedTab == 3)
                    .onTapGesture { selectedTab = 3 }
            }
            .padding(.horizontal, 26)
        }
        .padding(.bottom, 10)
    }
}

struct BottomIcon: View {
    let icon: String
    let label: String
    let isSelected: Bool

    init(_ icon: String, _ label: String, isSelected: Bool = false) {
        self.icon = icon
        self.label = label
        self.isSelected = isSelected
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(isSelected ? .orange : .white.opacity(0.5))
                .font(.system(size: 18, weight: .medium))
            Text(label)
                .font(.caption2)
                .foregroundColor(isSelected ? .orange : .white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
