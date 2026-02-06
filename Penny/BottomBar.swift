import SwiftUI

struct BottomBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        ZStack {
            // Liquid glass bar background
            HStack(spacing: 0) {
                barItem(icon: "person.2", title: "Friends", tab: .friends)
                barItem(icon: "shield", title: "Spending", tab: .spending)
                
                // Spacer for center button
                Spacer()
                    .frame(width: 80)
                
                barItem(icon: "creditcard", title: "Bank", tab: .bank) // Moved 'Bank' tab here
                barItem(icon: "face.smiling", title: "Me", tab: .me) // Moved 'Me' tab here
            }
            .frame(height: 60)
            .background(
                ZStack {
                    // Liquid glass effect
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.black.opacity(0.3))
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Material.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.white.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                }
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 2) // Reduced bottom padding to move closer to the bottom
            
            // Giant center button (bigger than the bar)
            centerButton
        }
    }

    // MARK: - Items

    private func barItem(icon: String, title: String, tab: AppTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(
                        selectedTab == tab ? Color(red: 1.0, green: 0.42, blue: 0.16) : .white.opacity(0.6)
                    )

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(
                        selectedTab == tab ? Color(red: 1.0, green: 0.42, blue: 0.16) : .white.opacity(0.5)
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
    }

    private var centerButton: some View {
        Button {
            // TODO: Handle Penny AI chat action
        } label: {
            ZStack {
                // Adjusted outer glow size
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.6),
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.3),
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60 // Reduced by 10px
                        )
                    )
                    .frame(width: 120, height: 120) // Reduced by 20px
                    .blur(radius: 20)

                // Adjusted liquid glass ring size
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.35).opacity(0.8),
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 66, height: 66) // Reduced by 20px
                    .blur(radius: 0.5)

                // Adjusted main button size
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.6, blue: 0.3),
                                Color(red: 1.0, green: 0.45, blue: 0.18),
                                Color(red: 1.0, green: 0.38, blue: 0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60) // Reduced by 20px
                    .overlay(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.0)
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    )
                    .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.6), radius: 16, x: 0, y: 6)
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 8)

                // Chat icon
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 28, weight: .semibold)) // Reduced icon size
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
        .offset(y: -30) // Adjusted offset
    }
}
