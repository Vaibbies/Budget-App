import SwiftUI
import Speech
import AVFoundation

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var amountString = "0"
    @State private var merchantName = ""
    @State private var selectedCategory: SpendingCategory = .dining
    @State private var selectedDate = Date()
    @State private var isImpulse = false
    @State private var isListening = false
    @State private var showCategoryPicker = false

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
            Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 40, height: 40)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    Spacer()
                    Text("NEW EXPENSE")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    // AI Dictation button
                    Button { startDictation() } label: {
                        ZStack {
                            Circle()
                                .fill(isListening ? Color(red: 1.0, green: 0.42, blue: 0.16) : Color.white.opacity(0.08))
                                .frame(width: 40, height: 40)
                            Image(systemName: isListening ? "waveform" : "mic.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)

                // Amount display
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("$")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.white.opacity(0.5))
                        Text(displayAmount)
                            .font(.system(size: 64, weight: .light, design: .serif))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.5)
                    }

                    // Merchant name input
                    TextField("MERCHANT NAME", text: $merchantName)
                        .font(.system(size: 13, weight: .medium))
                        .tracking(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.6))
                        .tint(Color(red: 1.0, green: 0.42, blue: 0.16))
                }
                .padding(.vertical, 16)

                // Category picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
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
                .padding(.bottom, 12)

                // Date + Impulse row
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
                        )

                    Spacer()

                    HStack(spacing: 8) {
                        Text("Impulse")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
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
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                // Keypad
                KeypadView { key in
                    handleKey(key)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Log Expense button
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
                                    ? Color(red: 1.0, green: 0.42, blue: 0.16)
                                    : Color.white.opacity(0.1)
                                )
                        )
                }
                .disabled(amountDouble == 0)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Keypad Handler
    private func handleKey(_ key: String) {
        Haptics.light()
        switch key {
        case "delete":
            if amountString.count > 1 {
                amountString.removeLast()
            } else {
                amountString = "0"
            }
        case ".":
            break // cents handled by /100 logic
        default:
            if amountString == "0" {
                amountString = key
            } else if amountString.count < 7 {
                amountString += key
            }
        }
    }

    // MARK: - Log Expense
    private func logExpense() {
        Haptics.medium()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: selectedDate)

        let dayLabel = Calendar.current.isDateInToday(selectedDate) ? "Today" :
                       Calendar.current.isDateInYesterday(selectedDate) ? "Yesterday" :
                       selectedDate.formatted(.dateTime.weekday(.wide))

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
            category: selectedCategory
        )

        // Insert into correct day group or create new one
        if let index = data.groups.firstIndex(where: { $0.title == dayLabel }) {
            var updatedTransactions = data.groups[index].transactions
            updatedTransactions.insert(transaction, at: 0)
            data.groups[index] = SpendingTransactionGroup(
                title: data.groups[index].title,
                transactions: updatedTransactions
            )
        } else {
            data.groups.insert(
                SpendingTransactionGroup(title: dayLabel, transactions: [transaction]),
                at: 0
            )
        }

        dismiss()
    }

    // MARK: - Dictation
    private func startDictation() {
        Haptics.medium()
        // Basic speech — expand with SFSpeechRecognizer for production
        isListening.toggle()
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
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : Color.white.opacity(0.07))
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
        VStack(spacing: 12) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button {
                            onKey(key)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.07))
                                    .frame(height: 64)
                                if key == "delete" {
                                    Image(systemName: "delete.backward")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
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

#Preview {
    AddTransactionView()
        .preferredColorScheme(.dark)
}
