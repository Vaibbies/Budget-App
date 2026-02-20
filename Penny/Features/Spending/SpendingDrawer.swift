import SwiftUI

struct SpendingDrawer: View {
    @Binding var isOpen: Bool
    @State private var showAnalytics = false
    @State private var showTransactions = false
    @State private var showRecurring = false

    var body: some View {
        ZStack {
            if isOpen {
                Color.clear
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isOpen = false
                        }
                    }

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        GridMenuItem(icon: "repeat", title: "Recurring") {
                            showRecurring = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }
                        GridMenuItem(icon: "chart.pie.fill", title: "Analytics") {
                            showAnalytics = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }
                    }
                    HStack(spacing: 8) {
                        GridMenuItem(icon: "list.bullet.rectangle", title: "Txns") {
                            showTransactions = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }
                        GridMenuItem(icon: "chart.bar.fill", title: "Tracking") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isOpen = false
                            }
                        }
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(red: 0.10, green: 0.08, blue: 0.07).opacity(0.95))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.08),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.4),
                                            Color.white.opacity(0.06)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 16)
                        .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.1), radius: 20, x: 0, y: 8)
                )
                .position(x: 100, y: 130)
                .transition(
                    .scale(scale: 0.9, anchor: .topLeading)
                        .combined(with: .opacity)
                )
                .zIndex(100)
            }
        }
        .sheet(isPresented: $showRecurring) {
            RecurringView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showAnalytics) { SpendingAnalyticsView() }
        .fullScreenCover(isPresented: $showTransactions) { TransactionsView() }
    }
}

// MARK: - Grid Menu Item
struct GridMenuItem: View {
    let icon: String
    let title: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15))
                        .overlay(
                            Circle()
                                .stroke(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.25), lineWidth: 1)
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                }

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(isPressed ? 0.1 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.1)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.1)) { isPressed = false }
                }
        )
    }
}

// MARK: - Popup Menu Item (kept for compatibility)
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
                        .fill(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                }

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(isPressed ? 0.1 : 0.05))
            )
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.15)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.15)) { isPressed = false }
                }
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(red: 0.20, green: 0.12, blue: 0.08), Color.black],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        SpendingDrawer(isOpen: .constant(true))
    }
}
