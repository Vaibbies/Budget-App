import SwiftUI

// MARK: - Recurring Subscription Model
struct RecurringSubscription: Identifiable {
    let id = UUID()
    let name: String
    let plan: String?
    let price: Double
    let iconName: String
    let iconColor: Color
    let bgColor: Color
    let nextBilling: String
}

// MARK: - RecurringView
struct RecurringView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAddRecurring = false

    @State private var subscriptions: [RecurringSubscription] = [
        RecurringSubscription(name: "Netflix", plan: "Premium Plan", price: 19.99, iconName: "netflix", iconColor: .white, bgColor: .black, nextBilling: "May 12"),
        RecurringSubscription(name: "Spotify", plan: nil, price: 10.99, iconName: "spotify", iconColor: .black, bgColor: Color(red: 0.11, green: 0.72, blue: 0.33), nextBilling: "May 15"),
        RecurringSubscription(name: "Notion", plan: nil, price: 8.00, iconName: "notion", iconColor: .black, bgColor: .white, nextBilling: "May 18"),
        RecurringSubscription(name: "YouTube", plan: "Premium", price: 13.99, iconName: "youtube", iconColor: .white, bgColor: Color(red: 1.0, green: 0.0, blue: 0.0), nextBilling: "May 20"),
        RecurringSubscription(name: "Equinox", plan: "Monthly", price: 95.00, iconName: "dumbbell.fill", iconColor: .white, bgColor: Color(red: 0.1, green: 0.1, blue: 0.1), nextBilling: "May 1"),
        RecurringSubscription(name: "iCloud", plan: "200GB", price: 2.99, iconName: "icloud.fill", iconColor: .white, bgColor: Color(red: 0.2, green: 0.5, blue: 1.0), nextBilling: "May 5"),
    ]

    var monthlyTotal: Double {
        subscriptions.reduce(0) { $0 + $1.price }
    }

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
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
                // Header
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
                            Text("View All")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                        }
                        .padding(.horizontal, 24)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(subscriptions) { sub in
                                SubscriptionSquareCard(subscription: sub)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .sheet(isPresented: $showAddRecurring) {
            AddRecurringView { newSub in
                subscriptions.append(newSub)
            }
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
                        Text(String(format: ".%02d", Int((monthlyTotal.truncatingRemainder(dividingBy: 1)) * 100)))
                            .font(.system(size: 22, weight: .light, design: .serif))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.4))
                    Text("12%")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.4))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color(red: 0.2, green: 0.85, blue: 0.4).opacity(0.1))
                        .overlay(Capsule().stroke(Color(red: 0.2, green: 0.85, blue: 0.4).opacity(0.2), lineWidth: 1))
                )
            }
            .padding(.bottom, 24)

            HStack(alignment: .bottom, spacing: 8) {
                ChartBarView(heightFraction: 0.40, month: "JAN", isActive: false)
                ChartBarView(heightFraction: 0.65, month: "FEB", isActive: false)
                ChartBarView(heightFraction: 0.55, month: "MAR", isActive: false)
                ChartBarView(heightFraction: 0.90, month: "APR", isActive: true)
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
                                colors: [Color(red: 1.0, green: 0.42, blue: 0.16), Color(red: 1.0, green: 0.6, blue: 0.36)],
                                startPoint: .bottom, endPoint: .top
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)],
                                startPoint: .bottom, endPoint: .top
                            )
                        )
                        .frame(height: geo.size.height * heightFraction)
                        .shadow(color: isActive ? Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.3) : .clear, radius: 8)
                }
            }
            Text(month)
                .font(.system(size: 10, weight: isActive ? .semibold : .medium))
                .foregroundColor(isActive ? Color(red: 1.0, green: 0.42, blue: 0.16) : .white.opacity(0.25))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Square Subscription Card
struct SubscriptionSquareCard: View {
    let subscription: RecurringSubscription
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 14)
                .fill(subscription.bgColor)
                .frame(width: 48, height: 48)
                .overlay(
                    serviceIcon(for: subscription.iconName, color: subscription.iconColor)
                )

            Spacer()

            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                if let plan = subscription.plan {
                    Text(plan)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("$\(String(format: "%.2f", subscription.price))")
                    .font(.system(size: 17, weight: .regular, design: .serif))
                    .foregroundColor(.white)
                Text("/mo")
                    .font(.system(size: 9, weight: .regular))
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
    }

    @ViewBuilder
    func serviceIcon(for name: String, color: Color) -> some View {
        switch name {
        case "netflix":
            Text("N")
                .font(.system(size: 26, weight: .black, design: .serif))
                .foregroundColor(.red)
        case "spotify":
            Image(systemName: "music.note")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(color)
        case "notion":
            Text("N")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.black)
        case "youtube":
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(color)
        default:
            Image(systemName: name)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(color)
        }
    }
}

#Preview {
    RecurringView()
        .preferredColorScheme(.dark)
}
