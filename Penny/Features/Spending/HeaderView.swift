import SwiftUI

struct HeaderView: View {
    @Binding var showDrawer: Bool
    
    var body: some View {
        HStack {
            // Menu button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showDrawer.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: Circle())

                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }
            }

            Spacer()

            // Title
            Text("BALANCE")
                .font(.caption2)
                .tracking(3)
                .foregroundColor(.white.opacity(0.55))

            Spacer()

            // Profile button
            Button(action: {
                // TODO: profile action
            }) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.65, blue: 0.25),
                                Color(red: 1.0, green: 0.75, blue: 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HeaderView(showDrawer: .constant(false))
    }
}
