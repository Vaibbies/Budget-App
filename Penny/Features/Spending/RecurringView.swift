import SwiftUI

// MARK: - RecurringView
struct RecurringView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(TransactionData.self) private var data
    @State private var showAddRecurring = false

    var subscriptions: [RecurringSubscription] { data.subscriptions }

    var monthlyTotal: Double {
        subscriptions.reduce(0) { $0 + $1.price }
    }

    var previousMonthTotal: Double {
        monthlyTotal * 0.88
    }

    var monthOverMonthChange: Double {
        guard previousMonthTotal > 0 else { return 0 }
        return ((monthlyTotal - previousMonthTotal) / previousMonthTotal) * 100
    }

    var isSpendingDown: Bool {
        monthlyTotal <= previousMonthTotal
    }

    var weeklyTotals: [Double] {
        let weekly = monthlyTotal / 4
        return [weekly * 0.82, weekly * 0.95, weekly * 1.05, weekly * 1.18]
    }

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        @Bindable var data = data
        ZStack {
            Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.6),
                    Color(red: 1.0, green: 0.376, blue: 0.125).opacity(0.1),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                HStack {
                    Button { dismiss() } label: {
                        Circle()
                            .fill(Color.white.opacity(0.07))
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                            .overlay(
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }

                    Spacer()

                    Text("RECURRING")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Button {
                        showAddRecurring = true
                        Haptics.medium()
                    } label: {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.416, blue: 0.165))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color(red: 1.0, green: 0.416, blue: 0.165).opacity(0.5), radius: 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {

                        monthlySpendCard
                            .padding(.horizontal, 24)

                        HStack {
                            Text("Active Services")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(subscriptions.count) services")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .padding(.horizontal, 24)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(subscriptions) { sub in
                                SubscriptionSquareCard(
                                    subscription: sub,
                                    onDelete: {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                            data.subscriptions.removeAll { $0.id == sub.id }
                                        }
                                        Haptics.medium()
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .sheet(isPresented: $showAddRecurring) {
            AddRecurringView()
                .presentationCornerRadius(30)
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Monthly Spend Card
    private var monthlySpendCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("MONTHLY SPEND")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.4))

                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("$\(Int(monthlyTotal))")
                            .font(.system(size: 36, weight: .light, design: .serif))
                            .foregroundColor(.white)

                        Text(
                            String(format: ".%02d",
                                   Int((monthlyTotal.truncatingRemainder(dividingBy: 1)) * 100))
                        )
                        .font(.system(size: 22, weight: .light, design: .serif))
                        .foregroundColor(.white.opacity(0.4))
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: isSpendingDown ? "arrow.down.right" : "arrow.up.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(isSpendingDown
                            ? Color(red: 0.2, green: 0.85, blue: 0.4)
                            : Color(red: 1.0, green: 0.42, blue: 0.16))

                    Text("\(String(format: "%.0f", abs(monthOverMonthChange)))%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(isSpendingDown
                            ? Color(red: 0.2, green: 0.85, blue: 0.4)
                            : Color(red: 1.0, green: 0.42, blue: 0.16))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill((isSpendingDown
                            ? Color(red: 0.2, green: 0.85, blue: 0.4)
                            : Color(red: 1.0, green: 0.42, blue: 0.16)).opacity(0.1))
                        .overlay(
                            Capsule().stroke((isSpendingDown
                                ? Color(red: 0.2, green: 0.85, blue: 0.4)
                                : Color(red: 1.0, green: 0.42, blue: 0.16)).opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding(.bottom, 24)

            let maxWeekly = weeklyTotals.max() ?? 1
            let weekLabels = ["WK 1", "WK 2", "WK 3", "WK 4"]

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(weeklyTotals.enumerated()), id: \.offset) { index, total in
                    ChartBarView(
                        heightFraction: CGFloat(total / maxWeekly),
                        month: weekLabels[index],
                        isActive: index == weeklyTotals.count - 1
                    )
                }
            }
            .frame(height: 100)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.9))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))
                .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - Chart Bar
struct ChartBarView: View {
    let heightFraction: CGFloat
    let month: String
    let isActive: Bool

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            isActive
                            ? LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.42, blue: 0.16),
                                    Color(red: 1.0, green: 0.6, blue: 0.36)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            : LinearGradient(
                                colors: [
                                    Color.white.opacity(0.08),
                                    Color.white.opacity(0.08)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: geo.size.height * heightFraction)
                }
            }

            Text(month)
                .font(.system(size: 10, weight: isActive ? .semibold : .medium))
                .foregroundColor(isActive
                    ? Color(red: 1.0, green: 0.42, blue: 0.16)
                    : .white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Square Subscription Card
struct SubscriptionSquareCard: View {
    let subscription: RecurringSubscription
    let onDelete: () -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                .frame(width: 48, height: 48)
                .overlay(
                    BrandLogoView(
                        name: subscription.name,
                        size: 48,
                        fallbackIcon: subscription.iconName,
                        fallbackColor: subscription.iconColor
                    )
                )

            Spacer()

            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                if let plan = subscription.plan {
                    Text(plan)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("$\(String(format: "%.2f", subscription.price))")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundColor(.white)

                Text("/mo")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.9))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
                .shadow(color: .black.opacity(0.35), radius: 8, y: 4)
        )
        .scaleEffect(isPressed ? 0.97 : 1)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeOut(duration: 0.1)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeOut(duration: 0.1)) { isPressed = false } }
        )
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Subscription", systemImage: "trash")
            }
        }
    }
}

#Preview {
    RecurringView()
        .preferredColorScheme(.dark)
        .environment(TransactionData.shared)
}
