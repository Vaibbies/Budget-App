import SwiftUI

struct ActionButtonsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            ActionButton(icon: "plus") {
                // TODO: Add expense
            }

            ActionButton(icon: "viewfinder") {
                // TODO: Scan receipt
            }

            ActionButton(icon: "target") {
                // TODO: Goals
            }

            ActionButton(icon: "chart.line.uptrend.xyaxis") {
                // TODO: Analytics
            }
        }
        .padding(.horizontal, 24)
    }
}

struct ActionButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.4))
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(height: 48)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ActionButtonsRow()
    }
}
