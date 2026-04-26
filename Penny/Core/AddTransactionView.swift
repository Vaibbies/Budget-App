import SwiftUI
import UIKit

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var amountString = "0"
    @State private var merchantName = ""
    @State private var selectedCategory: SpendingCategory = .dining
    @State private var selectedDate = Date()
    @State private var selectedAccountId: UUID?
    @State private var isImpulse = false
    @State private var isListening = false
    @State private var showRecurringPrompt = false
    @State private var showAddRecurring = false
    @State private var pendingTransaction: SpendingTransaction? = nil

    private var data = TransactionData.shared

    private var displayAmount: String {
        let value = (Double(amountString) ?? 0) / 100
        return String(format: "%.2f", value)
    }

    private var amountDouble: Double {
        (Double(amountString) ?? 0) / 100
    }

    var body: some View {
        ZStack {
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
            }

            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

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
                    Text("NEW EXPENSE")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Button { startDictation() } label: {
                        Circle()
                            .fill(isListening
                                  ? Color(red: 1.0, green: 0.42, blue: 0.16)
                                  : Color.white.opacity(0.07))
                            .frame(width: 40, height: 40)
                            .overlay(Circle().stroke(Color.white.opacity(0.06), lineWidth: 1))
                            .overlay(
                                Image(systemName: isListening ? "waveform" : "mic.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                VStack(spacing: 10) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.white.opacity(0.5))
                        Text(displayAmount)
                            .font(.system(size: 64, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                    }
                    NoMoveTextField(placeholder: "MERCHANT NAME", text: $merchantName)
                        .frame(height: 30)
                }
                .padding(.bottom, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(SpendingCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                                Haptics.light()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)

                HStack(spacing: 12) {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
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
                    Spacer()
                    HStack(spacing: 8) {
                        Text("Impulse")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        Toggle("", isOn: $isImpulse)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: Color(red: 1.0, green: 0.42, blue: 0.16)))
                            .scaleEffect(0.85)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.white.opacity(0.06))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                if !data.visibleAccounts.isEmpty {
                    accountSelector
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                }

                KeypadView { key in handleKey(key) }
                    .padding(.horizontal, 24)

                Spacer()

                Button(action: logExpense) {
                    Text("Log Expense")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    amountDouble > 0
                                    ? LinearGradient(
                                        colors: [
                                            Color(red: 1.0, green: 0.53, blue: 0.25),
                                            Color(red: 1.0, green: 0.35, blue: 0.10)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    : LinearGradient(
                                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: amountDouble > 0 ? Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.4) : .clear,
                                    radius: 12,
                                    y: 4
                                )
                        )
                }
                .disabled(amountDouble == 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .alert("Add to Recurring?", isPresented: $showRecurringPrompt) {
            Button("Add to Recurring") {
                showAddRecurring = true
            }
            Button("Skip", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Would you like to add \(merchantName.isEmpty ? "this subscription" : merchantName) as a recurring subscription?")
        }
        .sheet(isPresented: $showAddRecurring, onDismiss: { dismiss() }) {
            QuickAddRecurringView(
                prefillName: merchantName,
                prefillPrice: amountDouble,
                startDate: selectedDate
            )
            .presentationCornerRadius(30)
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            selectedAccountId = data.defaultSpendingAccount?.id
        }
    }

    private func handleKey(_ key: String) {
        Haptics.light()
        switch key {
        case "delete":
            if amountString.count > 1 { amountString.removeLast() } else { amountString = "0" }
        case ".": break
        default:
            if amountString == "0" { amountString = key }
            else if amountString.count < 7 { amountString += key }
        }
    }

    private func logExpense() {
        Haptics.medium()

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = Calendar.current.isDateInToday(selectedDate)
            ? timeFormatter.string(from: Date())
            : "Added"

        let dayLabel: String
        if Calendar.current.isDateInToday(selectedDate) {
            dayLabel = "Today"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            dayLabel = "Yesterday"
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEEE, MMM d"
            dayLabel = fmt.string(from: selectedDate)
        }

        let transaction = SpendingTransaction(
            icon: selectedCategory.icon,
            title: merchantName.isEmpty ? selectedCategory.rawValue : merchantName,
            subtitle: selectedCategory.rawValue,
            time: timeString,
            amount: "-$\(String(format: "%.2f", amountDouble))",
            isImpulse: isImpulse,
            iconColor: selectedCategory.color,
            bgColor: selectedCategory.color.opacity(0.1),
            borderColor: selectedCategory.color.opacity(0.2),
            category: selectedCategory,
            accountId: selectedAccountId ?? data.defaultSpendingAccount?.id,
            kind: .spending,
            merchantRaw: merchantName.isEmpty ? selectedCategory.rawValue : merchantName,
            merchantNormalized: data.normalizeMerchant(merchantName.isEmpty ? selectedCategory.rawValue : merchantName)
        )

        if let index = data.groups.firstIndex(where: { $0.title == dayLabel }) {
            var updated = data.groups[index].transactions
            updated.insert(transaction, at: 0)
            data.groups[index] = SpendingTransactionGroup(title: data.groups[index].title, transactions: updated)
        } else {
            let fmt = DateFormatter()
            fmt.dateFormat = "EEEE, MMM d"
            let insertIndex = data.groups.firstIndex(where: { group in
                guard group.title != "Today" && group.title != "Yesterday" else { return false }
                if let groupDate = fmt.date(from: group.title) { return groupDate < selectedDate }
                return false
            }) ?? data.groups.endIndex
            data.groups.insert(SpendingTransactionGroup(title: dayLabel, transactions: [transaction]), at: insertIndex)
        }

        if selectedCategory == .subscriptions {
            showRecurringPrompt = true
        } else {
            dismiss()
        }
    }

    private func startDictation() {
        Haptics.medium()
        isListening.toggle()
    }

    private var accountSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ACCOUNT")
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))

            Picker("Account", selection: $selectedAccountId) {
                ForEach(data.visibleAccounts, id: \.id) { account in
                    Text(account.name).tag(Optional(account.id))
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.06))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.06), lineWidth: 1))
            )
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: SpendingCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12, weight: .medium))
                Text(category.rawValue)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.4))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : Color.white.opacity(0.06))
                    .overlay(
                        Capsule()
                            .stroke(
                                isSelected ? category.color.opacity(0.3) : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

// MARK: - Keypad
struct KeypadView: View {
    let onKey: (String) -> Void
    private let keys = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"],
        [".","0","delete"]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            onKey(key)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                    )
                                    .frame(height: 64)

                                if key == "delete" {
                                    Image(systemName: "delete.backward")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                } else {
                                    Text(key)
                                        .font(.system(size: 28, weight: .light, design: .serif))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - UIKit TextField
struct NoMoveTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.placeholder = placeholder
        tf.textAlignment = .center
        tf.keyboardAppearance = .dark
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .words
        tf.returnKeyType = .done
        tf.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        tf.textColor = UIColor.white.withAlphaComponent(0.5)
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                .kern: 2.0
            ]
        )
        tf.inputAssistantItem.leadingBarButtonGroups = []
        tf.inputAssistantItem.trailingBarButtonGroups = []
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        return tf
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text { uiView.text = text }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        @objc func textChanged(_ tf: UITextField) {
            let raw = tf.text ?? ""
            let cleaned = raw.lowercased()
                .split(separator: " ", omittingEmptySubsequences: false)
                .map { part -> String in
                    guard let first = part.first else { return String(part) }
                    return String(first).uppercased() + part.dropFirst()
                }
                .joined(separator: " ")
            if cleaned != raw { tf.text = cleaned }
            text = cleaned
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
    }
}

#Preview {
    AddTransactionView()
        .preferredColorScheme(.dark)
}
