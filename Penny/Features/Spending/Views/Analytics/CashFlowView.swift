import SwiftUI

struct CashFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SpendingStore.self) private var spending
    @State private var showAddManualItem = false

    private var forecast: CashFlowForecast {
        spending.cashFlowForecast
    }

    var body: some View {
        NavigationStack {
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

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerCard
                        summaryGrid
                        manualItemsSection
                        forecastTimelineSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.white.opacity(0.8))
                }

                ToolbarItem(placement: .principal) {
                    Text("CASH FLOW")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.5))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddManualItem = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddManualItem) {
            AddManualForecastItemView()
                .presentationCornerRadius(28)
                .presentationDragIndicator(.visible)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projected Month End")
                .font(.system(size: 11, weight: .medium))
                .tracking(1.8)
                .foregroundColor(.white.opacity(0.4))

            Text(currencyString(forecast.projectedEndOfMonthCash))
                .font(.system(size: 36, weight: .light, design: .serif))
                .foregroundColor(forecast.projectedEndOfMonthCash >= 0 ? .white : Color(red: 1.0, green: 0.42, blue: 0.16))

            Text("Starting cash plus expected income minus expected bills through the current forecast window.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white.opacity(0.45))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.9))
                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }

    private var summaryGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                summaryCard(title: "Starting Cash", value: currencyString(forecast.startingCash), accent: .white.opacity(0.85))
                summaryCard(title: "Expected Income", value: currencyString(forecast.expectedIncome), accent: Color(red: 0.29, green: 0.87, blue: 0.50))
            }

            HStack(spacing: 10) {
                summaryCard(title: "Expected Bills", value: currencyString(forecast.expectedBills), accent: Color(red: 1.0, green: 0.42, blue: 0.16))
                summaryCard(title: "30 Day Net", value: currencyString(forecast.next30DayNet), accent: forecast.next30DayNet >= 0 ? Color(red: 0.29, green: 0.87, blue: 0.50) : Color(red: 1.0, green: 0.42, blue: 0.16))
            }
        }
    }

    private func summaryCard(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(1.3)
                .foregroundColor(.white.opacity(0.35))

            Text(value)
                .font(.system(size: 19, weight: .light, design: .serif))
                .foregroundColor(accent)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }

    private var manualItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Manual Forecast Items")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Button("Add") { showAddManualItem = true }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.36))
            }

            if spending.manualForecastItems.isEmpty {
                sectionEmptyCard("No manual forecast items yet", subtitle: "Add one-off bills or paychecks that are not part of your recurring schedules.")
            } else {
                VStack(spacing: 8) {
                    ForEach(spending.manualForecastItems) { item in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(item.kind == .income ? Color(red: 0.29, green: 0.87, blue: 0.50) : Color(red: 1.0, green: 0.42, blue: 0.16))
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Text("\(dateString(item.date)) • \(item.note ?? (item.kind == .income ? "Manual income" : "Manual bill"))")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.45))
                            }

                            Spacer()

                            Text((item.kind == .income ? "+" : "-") + currencyString(item.amount).replacingOccurrences(of: "-", with: ""))
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(item.kind == .income ? Color(red: 0.29, green: 0.87, blue: 0.50) : .white)

                            Button {
                                spending.deleteManualForecastItem(id: item.id)
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.04))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )
                    }
                }
            }
        }
    }

    private var forecastTimelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Forecast Timeline")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            if forecast.events.isEmpty {
                sectionEmptyCard("No forecast events yet", subtitle: "Active recurring bills and expected paychecks will appear here.")
            } else {
                VStack(spacing: 8) {
                    ForEach(forecast.events) { event in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(event.kind == .income ? Color(red: 0.29, green: 0.87, blue: 0.50) : Color(red: 1.0, green: 0.42, blue: 0.16))
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Text("\(dateString(event.date)) • \(event.subtitle)")
                                    .font(.system(size: 11, weight: .regular))
                                    .foregroundColor(.white.opacity(0.45))
                            }

                            Spacer()

                            Text((event.kind == .income ? "+" : "-") + currencyString(event.amount).replacingOccurrences(of: "-", with: ""))
                                .font(.system(size: 14, weight: .regular, design: .serif))
                                .foregroundColor(event.kind == .income ? Color(red: 0.29, green: 0.87, blue: 0.50) : .white)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.04))
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
                        )
                    }
                }
            }
        }
    }

    private func sectionEmptyCard(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.white.opacity(0.45))
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.06), lineWidth: 1))
        )
    }

    private func currencyString(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        return "\(sign)$\(String(format: "%.2f", abs(value)))"
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

private struct AddManualForecastItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SpendingStore.self) private var spending

    @State private var title = ""
    @State private var amount = ""
    @State private var date = Date()
    @State private var kind: ManualForecastItem.Kind = .bill
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $kind) {
                    ForEach(ManualForecastItem.Kind.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }

                TextField("Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Note", text: $note)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("ADD FORECAST ITEM")
                        .font(.system(size: 12, weight: .medium))
                        .tracking(2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let cleaned = amount.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "$", with: "")
                        spending.addManualForecastItem(
                            title: title,
                            amount: Double(cleaned) ?? 0,
                            date: date,
                            kind: kind,
                            note: note
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || (Double(amount.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "$", with: "")) ?? 0) <= 0)
                }
            }
        }
    }
}
