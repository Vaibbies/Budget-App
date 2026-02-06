import SwiftUI

struct ActionButtonsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            ActionButton(icon: "plus", action: {
                // TODO: Add expense action
            })
            
            ActionButton(icon: "viewfinder", action: {
                // TODO: Scan receipt action
            })
            
            ActionButton(icon: "target", action: {
                // TODO: Goals action
            })
            
            ActionButton(icon: "chart.line.uptrend.xyaxis", action: {
                // TODO: Analytics action
            })
        }
        .padding(.horizontal, 24)
    }
}

struct ActionButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.black.opacity(0.4))
                    .backdrop(Material.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isPressed ? Color(red: 1.0, green: 0.42, blue: 0.16) : .white.opacity(0.9))
            }
            .frame(height: 48)
        }
        .buttonStyle(ActionButtonStyle(isPressed: $isPressed))
    }
}

struct ActionButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ActionButtonsRow()
    }
}
