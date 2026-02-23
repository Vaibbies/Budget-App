import SwiftUI

enum BillingFrequency: String, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case biannual = "Every 6 Months"
    case annual = "Annually"

    var days: Int {
        switch self {
        case .weekly:    return 7
        case .monthly:   return 30
        case .quarterly: return 90
        case .biannual:  return 180
        case .annual:    return 365
        }
    }

    var storageKey: String {
        switch self {
        case .weekly: return "weekly"
        case .monthly: return "monthly"
        case .quarterly: return "quarterly"
        case .biannual: return "biannual"
        case .annual: return "annual"
        }
    }

    func advanced(from date: Date) -> Date {
        let calendar = Calendar.current
        switch self {
        case .weekly:
            return calendar.date(byAdding: .day, value: 7, to: date) ?? date
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .quarterly:
            return calendar.date(byAdding: .month, value: 3, to: date) ?? date
        case .biannual:
            return calendar.date(byAdding: .month, value: 6, to: date) ?? date
        case .annual:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        }
    }

    var nextDate: Date {
        advanced(from: Date())
    }

    var icon: String {
        switch self {
        case .weekly:    return "7.circle.fill"
        case .monthly:   return "calendar"
        case .quarterly: return "calendar.badge.clock"
        case .biannual:  return "arrow.clockwise"
        case .annual:    return "star.fill"
        }
    }
}

struct QuickAddRecurringView: View {
    @Environment(\.dismiss) var dismiss
    private var data = TransactionData.shared

    let prefillName: String
    let prefillPrice: Double
    let startDate: Date

    @State private var name: String
    @State private var plan = ""
    @State private var selectedFrequency: BillingFrequency = .monthly

    private let accent = Color(red: 0.35, green: 0.98, blue: 0.85)

    init(prefillName: String, prefillPrice: Double, startDate: Date = Date()) {
        self.prefillName = prefillName
        self.prefillPrice = prefillPrice
        self.startDate = startDate
        _name = State(initialValue: prefillName)
    }

    private var nextBillingDate: Date {
        Self.nextOccurrenceDate(
            anchorDate: startDate,
            frequency: selectedFrequency,
            after: Date()
        )
    }

    private var nextBillingString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: nextBillingDate)
    }

    private var nextBillingFull: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM d"
        return fmt.string(from: nextBillingDate)
    }

    var body: some View {
        ZStack {
            Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()
            RadialGradient(
                colors: [accent.opacity(0.3), Color.clear],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0, endRadius: 400
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
                    Text("ADD TO RECURRING")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Circle().fill(Color.clear).frame(width: 40, height: 40)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Preview card
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.12))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    BrandLogoView(
                                        name: name.isEmpty ? prefillName : name,
                                        size: 56,
                                        fallbackIcon: "music.note",
                                        fallbackColor: .white
                                    )
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(name.isEmpty ? prefillName : name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Text(plan.isEmpty ? selectedFrequency.rawValue : plan)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(alignment: .firstTextBaseline, spacing: 1) {
                                    Text("$\(String(format: "%.2f", prefillPrice))")
                                        .font(.system(size: 20, weight: .light, design: .serif))
                                        .foregroundColor(.white)
                                    Text("/mo")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                Text("Next: \(nextBillingString)")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(accent.opacity(0.7))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.9))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )

                        // Service name
                        inputField(label: "SERVICE NAME", text: $name, placeholder: prefillName)

                        // Plan description
                        inputField(label: "PLAN DESCRIPTION (OPTIONAL)", text: $plan, placeholder: "e.g. Premium, Family, Student...")

                        // Frequency picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("BILLING FREQUENCY")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 4)

                            VStack(spacing: 8) {
                                ForEach(BillingFrequency.allCases, id: \.self) { freq in
                                    Button {
                                        selectedFrequency = freq
                                        Haptics.light()
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: freq.icon)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedFrequency == freq
                                                    ? accent
                                                    : .white.opacity(0.4))
                                                .frame(width: 20)

                                            Text(freq.rawValue)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(selectedFrequency == freq ? .white : .white.opacity(0.5))

                                            Spacer()

                                            if selectedFrequency == freq {
                                                Text(nextBillingFull)
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(accent.opacity(0.8))

                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 11, weight: .semibold))
                                                    .foregroundColor(accent)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(selectedFrequency == freq
                                                    ? accent.opacity(0.08)
                                                    : Color.white.opacity(0.05))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(selectedFrequency == freq
                                                            ? accent.opacity(0.3)
                                                            : Color.white.opacity(0.06),
                                                            lineWidth: 1
                                                        )
                                                )
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }

                // Add button
                Button {
                    Haptics.medium()
                    let sub = RecurringSubscription(
                        name: name.isEmpty ? prefillName : name,
                        plan: plan.isEmpty ? nil : plan,
                        price: prefillPrice,
                        iconName: "music.note",
                        iconColor: .white,
                        bgColor: accent,
                        nextBilling: nextBillingString,
                        frequencyDays: selectedFrequency.days,
                        frequencyKey: selectedFrequency.storageKey,
                        nextBillingEpoch: nextBillingDate.timeIntervalSince1970
                    )
                    data.addSubscription(sub, logInitialTransaction: false)
                    dismiss()
                } label: {
                    Text("Add to Recurring")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(accent)
                                .shadow(color: accent.opacity(0.3), radius: 12, y: 4)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private static func nextOccurrenceDate(anchorDate: Date, frequency: BillingFrequency, after referenceDate: Date) -> Date {
        let calendar = Calendar.current
        let anchor = calendar.startOfDay(for: anchorDate)
        let reference = calendar.startOfDay(for: referenceDate)

        if anchor > reference {
            return frequency.advanced(from: anchor)
        }

        var next = frequency.advanced(from: anchor)
        while next <= reference {
            next = frequency.advanced(from: next)
        }
        return next
    }

    private func inputField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 4)

            TextField(placeholder, text: text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.white)
                .tint(Color(red: 1.0, green: 0.42, blue: 0.16))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                )
        }
    }
}

#Preview {
    QuickAddRecurringView(prefillName: "Spotify", prefillPrice: 10.99)
        .preferredColorScheme(.dark)
}
