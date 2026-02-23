import SwiftUI
import UIKit

struct AddRecurringView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(TransactionData.self) private var data

    @State private var name = ""
    @State private var plan = ""
    @State private var priceText = ""
    @State private var selectedFrequency: BillingFrequency = .monthly

    private let accent = Color(red: 0.35, green: 0.98, blue: 0.85)

    private var enteredPrice: Double {
        let cleaned = priceText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        return Double(cleaned) ?? 0
    }

    private var isSaveEnabled: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && enteredPrice > 0
    }

    private var nextBillingString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: selectedFrequency.nextDate)
    }

    private var nextBillingFull: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "EEEE, MMM d"
        return fmt.string(from: selectedFrequency.nextDate)
    }

    var body: some View {
        ZStack {
            Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()
            RadialGradient(
                colors: [accent.opacity(0.3), Color.clear],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 400
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

                    Text("NEW SUBSCRIPTION")
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
                                        name: name,
                                        size: 56,
                                        fallbackIcon: "creditcard.fill",
                                        fallbackColor: accent
                                    )
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(name.isEmpty ? "Service Name" : name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(name.isEmpty ? .white.opacity(0.3) : .white)
                                Text(plan.isEmpty ? selectedFrequency.rawValue : plan)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(alignment: .firstTextBaseline, spacing: 1) {
                                    Text("$\(String(format: "%.2f", enteredPrice))")
                                        .font(.system(size: 20, weight: .light, design: .serif))
                                        .foregroundColor(.white)
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

                        // Fields
                        inputField(label: "SERVICE NAME", text: $name, placeholder: "Netflix, Spotify...")
                        inputField(label: "PLAN DESCRIPTION (OPTIONAL)", text: $plan, placeholder: "e.g. Premium, Family, Student...")
                        amountField

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
                                                .foregroundColor(selectedFrequency == freq ? accent : .white.opacity(0.4))
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
                                                .fill(selectedFrequency == freq ? accent.opacity(0.08) : Color.white.opacity(0.05))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .stroke(selectedFrequency == freq ? accent.opacity(0.3) : Color.white.opacity(0.06), lineWidth: 1)
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
                    guard isSaveEnabled else { return }
                    Haptics.medium()

                    let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    let cleanPlan = plan.trimmingCharacters(in: .whitespacesAndNewlines)

                    let sub = RecurringSubscription(
                        name: cleanName,
                        plan: cleanPlan.isEmpty ? nil : cleanPlan,
                        price: enteredPrice,
                        iconName: "creditcard.fill",
                        iconColor: .white,
                        bgColor: accent,
                        nextBilling: nextBillingString,
                        frequencyDays: selectedFrequency.days,
                        frequencyKey: selectedFrequency.storageKey,
                        nextBillingEpoch: selectedFrequency.nextDate.timeIntervalSince1970
                    )

                    data.addSubscription(sub, logInitialTransaction: true)
                    dismiss()
                } label: {
                    Text("Add Subscription")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isSaveEnabled ? accent : Color.white.opacity(0.08))
                                .shadow(color: isSaveEnabled ? accent.opacity(0.3) : .clear, radius: 12, y: 4)
                        )
                }
                .disabled(!isSaveEnabled)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
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
                .tint(accent)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                )
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRICE")
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 4)

            HStack(spacing: 10) {
                Text("$")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))

                TextField("0.00", text: $priceText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.white)
                    .tint(accent)
            }
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
    AddRecurringView()
        .preferredColorScheme(.dark)
        .environment(TransactionData.shared)
}
