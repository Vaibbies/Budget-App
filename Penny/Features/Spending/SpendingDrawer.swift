import SwiftUI

struct SpendingDrawer: View {
    @Binding var isOpen: Bool
    @State private var showAnalytics = false
    @State private var showTransactions = false
    @State private var showRecurring = false
    @State private var showTracking = false

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

                VStack(spacing: 6) {
                    // Top row
                    HStack(spacing: 6) {
                        DrawerItem(icon: "repeat", title: "Recurring", color: Color(red: 1.0, green: 0.42, blue: 0.16)) {
                            showRecurring = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { isOpen = false }
                        }
                        DrawerItem(icon: "chart.pie.fill", title: "Analytics", color: Color(red: 0.38, green: 0.65, blue: 0.98)) {
                            showAnalytics = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { isOpen = false }
                        }
                    }
                    // Bottom row
                    HStack(spacing: 6) {
                        DrawerItem(icon: "list.bullet.rectangle", title: "Transactions", color: Color(red: 0.68, green: 0.45, blue: 0.98)) {
                            showTransactions = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { isOpen = false }
                        }
                        DrawerItem(icon: "chart.bar.fill", title: "Tracking", color: Color(red: 0.29, green: 0.87, blue: 0.50)) {
                            showTracking = true
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { isOpen = false }
                        }
                    }
                }
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color(red: 0.08, green: 0.06, blue: 0.05).opacity(0.85))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.15),
                                            Color.white.opacity(0.04)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: .black.opacity(0.6), radius: 40, x: 0, y: 20)
                        .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.08), radius: 30, x: 0, y: 10)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 120)
                .padding(.trailing, 20)
                .transition(
                    .scale(scale: 0.85, anchor: .topTrailing)
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
        .fullScreenCover(isPresented: $showTracking) { TrackingView() }
    }
}

// MARK: - Drawer Item
struct DrawerItem: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            Haptics.light()
            action()
        }) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(color.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(color.opacity(0.2), lineWidth: 1)
                        )
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
            }
            .frame(width: 96, height: 88)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(isPressed ? 0.08 : 0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(isPressed ? 0.12 : 0.06), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
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
                .onChanged { _ in withAnimation(.easeOut(duration: 0.15)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeOut(duration: 0.15)) { isPressed = false } }
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
