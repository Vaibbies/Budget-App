import SwiftUI

struct SpendingDrawer: View {
    @Binding var isOpen: Bool
    @State private var showAnalytics = false
    @State private var showTransactions = false

    var body: some View {
        ZStack {
            // Popup menu
            if isOpen {
                VStack(alignment: .leading, spacing: 0) {

                    VStack(spacing: 0) {
                        PopupMenuItem(
                            icon: "clock.fill",
                            title: "Recents"
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }

                        PopupMenuItem(
                            icon: "chart.pie.fill",
                            title: "Analytics"
                        ) {
                            showAnalytics = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }

                        PopupMenuItem(
                            icon: "list.bullet.rectangle",
                            title: "Transactions"
                        ) {
                            showTransactions = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }

                        PopupMenuItem(
                            icon: "chart.bar.fill",
                            title: "Tracking"
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                }
                .frame(width: 168)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color.white.opacity(0.6))
                        )
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.25),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color.white.opacity(0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.18), radius: 25, x: 0, y: 14)
                        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
                )
                .position(x: 110, y: 140)
                .transition(
                    .scale(scale: 0.9, anchor: .topLeading)
                        .combined(with: .opacity)
                )
                .zIndex(100)
            }
        }
        .fullScreenCover(isPresented: $showAnalytics) {
            SpendingAnalyticsView()
        }
        .fullScreenCover(isPresented: $showTransactions) {
            TransactionsView()
        }
    }
}

// MARK: - Popup Menu Item
struct PopupMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black.opacity(0.8))
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.black.opacity(0.9))

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(isPressed ? 0.28 : 0.14))
            )
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.15).ignoresSafeArea()
        SpendingDrawer(isOpen: .constant(true))
    }
}
