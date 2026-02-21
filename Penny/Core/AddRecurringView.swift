import SwiftUI

struct AddRecurringView: View {
    @Environment(\.dismiss) var dismiss
    private var data = TransactionData.shared

    @State private var name = ""
    @State private var plan = ""
    @State private var priceString = ""
    @State private var nextBilling = Date()
    @State private var selectedColor = Color(red: 0.38, green: 0.65, blue: 0.98)
    @State private var selectedIcon = "creditcard.fill"

    let iconOptions = ["creditcard.fill", "cart.fill", "music.note", "play.rectangle.fill", "cloud.fill", "dumbbell.fill", "book.fill", "gamecontroller.fill", "tv.fill", "wifi", "phone.fill", "envelope.fill"]

    var priceDouble: Double { Double(priceString) ?? 0 }

    var body: some View {
        ZStack {
            Color(red: 0.039, green: 0.043, blue: 0.051).ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.5),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 400
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
                        // Live preview card
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedColor)
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 24, weight: .medium))
                                        .foregroundColor(.white)
                                )
                            VStack(alignment: .leading, spacing: 4) {
                                Text(name.isEmpty ? "Service Name" : name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(name.isEmpty ? .white.opacity(0.3) : .white)
                                Text(plan.isEmpty ? "Plan" : plan)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            Spacer()
                            HStack(alignment: .firstTextBaseline, spacing: 1) {
                                Text("$\(priceString.isEmpty ? "0.00" : priceString)")
                                    .font(.system(size: 20, weight: .light, design: .serif))
                                    .foregroundColor(.white)
                                Text("/mo")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.9))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )

                        VStack(spacing: 12) {
                            inputField(label: "SERVICE NAME", text: $name, placeholder: "Netflix, Spotify...")
                            inputField(label: "PLAN", text: $plan, placeholder: "Premium, Monthly...")
                            inputField(label: "MONTHLY PRICE", text: $priceString, placeholder: "9.99", keyboard: .decimalPad)
                        }

                        // Icon picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ICON")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 4)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Button {
                                        selectedIcon = icon
                                        Haptics.light()
                                    } label: {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedIcon == icon
                                                  ? Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.2)
                                                  : Color.white.opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedIcon == icon
                                                            ? Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.5)
                                                            : Color.white.opacity(0.06), lineWidth: 1)
                                            )
                                            .overlay(
                                                Image(systemName: icon)
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(selectedIcon == icon
                                                                     ? Color(red: 1.0, green: 0.42, blue: 0.16)
                                                                     : .white.opacity(0.5))
                                            )
                                            .frame(height: 44)
                                    }
                                }
                            }
                        }

                        // Color picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("COLOR")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 4)

                            HStack(spacing: 10) {
                                ForEach([
                                    Color(red: 0.38, green: 0.65, blue: 0.98),
                                    Color(red: 0.29, green: 0.87, blue: 0.50),
                                    Color(red: 0.96, green: 0.45, blue: 0.71),
                                    Color(red: 0.68, green: 0.45, blue: 0.98),
                                    Color(red: 1.0, green: 0.42, blue: 0.16),
                                    Color(red: 0.98, green: 0.85, blue: 0.35),
                                    Color.black,
                                    Color.white
                                ], id: \.self) { color in
                                    Button {
                                        selectedColor = color
                                        Haptics.light()
                                    } label: {
                                        Circle()
                                            .fill(color)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedColor == color
                                                            ? Color.white.opacity(0.8)
                                                            : Color.clear, lineWidth: 2)
                                            )
                                    }
                                }
                                Spacer()
                            }
                        }

                        // Next billing date
                        VStack(alignment: .leading, spacing: 10) {
                            Text("NEXT BILLING DATE")
                                .font(.system(size: 10, weight: .medium))
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.horizontal, 4)

                            DatePicker("", selection: $nextBilling, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .tint(Color(red: 1.0, green: 0.42, blue: 0.16))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.06))
                                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }

                Button {
                    guard !name.isEmpty, priceDouble > 0 else { return }
                    Haptics.medium()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d"
                    let billing = formatter.string(from: nextBilling)
                    let newSub = RecurringSubscription(
                        name: name,
                        plan: plan.isEmpty ? nil : plan,
                        price: priceDouble,
                        iconName: selectedIcon,
                        iconColor: .white,
                        bgColor: selectedColor,
                        nextBilling: billing
                    )
                    data.addSubscription(newSub)
                    dismiss()
                } label: {
                    Text("Add Subscription")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    name.isEmpty || priceDouble == 0
                                    ? LinearGradient(colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(colors: [Color(red: 1.0, green: 0.53, blue: 0.25), Color(red: 1.0, green: 0.35, blue: 0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: name.isEmpty || priceDouble == 0 ? .clear : Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.4), radius: 12, y: 4)
                        )
                }
                .disabled(name.isEmpty || priceDouble == 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private func inputField(label: String, text: Binding<String>, placeholder: String, keyboard: UIKeyboardType = .default) -> some View {
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
                .keyboardType(keyboard)
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
}
