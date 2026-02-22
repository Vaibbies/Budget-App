import SwiftUI

// MARK: - Mindful Spending Modal
struct MindfulSpendingView: View {
    @Binding var isPresented: Bool

    @State private var fadeIn = false
    @State private var ring1Scale: CGFloat = 0.95
    @State private var ring1Opacity: Double = 0.1
    @State private var ring2Scale: CGFloat = 0.95
    @State private var ring2Opacity: Double = 0.1
    @State private var dotOffsets: [CGFloat] = [0, 0, 0]
    @State private var dotOpacities: [Double] = [0.3, 0.3, 0.3]

    var body: some View {
        ZStack {
            // Dimmed blur backdrop
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }

            // Modal card
            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 24)

                // Breathing orb
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.455, blue: 0.086).opacity(ring2Opacity), lineWidth: 1)
                        .frame(width: 80 + 64, height: 80 + 64)
                        .scaleEffect(ring2Scale)

                    // Inner ring
                    Circle()
                        .stroke(Color(red: 1.0, green: 0.455, blue: 0.086).opacity(ring1Opacity), lineWidth: 1)
                        .frame(width: 80 + 32, height: 80 + 32)
                        .scaleEffect(ring1Scale)

                    // Orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.55, blue: 0.2),
                                    Color(red: 0.98, green: 0.38, blue: 0.05)
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.orange.opacity(0.4), radius: 24, y: 8)
                        .overlay(
                            Text("🌿")
                                .font(.system(size: 32))
                        )
                }
                .padding(.bottom, 32)

                // Heading
                Text("Take a breath")
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)

                // Subtitle
                Group {
                    Text("Let's sit with this for a moment. Does this purchase align with your ")
                        .foregroundColor(.white.opacity(0.5))
                    + Text("peace of mind")
                        .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.3))
                        .fontWeight(.medium)
                    + Text("?")
                        .foregroundColor(.white.opacity(0.5))
                }
                .font(.system(size: 14, weight: .light))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 8)
                .padding(.bottom, 28)

                // Purchase bubble
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.18, green: 0.16, blue: 0.15))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Text("🎧")
                                .font(.system(size: 24))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .top) {
                            Text("Gaming Headset")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.98, green: 0.97, blue: 0.96))

                            Spacer()

                            Text("JOYFUL")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(1)
                                .foregroundColor(Color(red: 1.0, green: 0.455, blue: 0.086))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 1.0, green: 0.455, blue: 0.086).opacity(0.1))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color(red: 1.0, green: 0.455, blue: 0.086).opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }

                        Text("$159.99")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(20)
                .background(Color(red: 0.153, green: 0.137, blue: 0.129))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(red: 0.22, green: 0.204, blue: 0.192), lineWidth: 1)
                )
                .padding(.bottom, 32)

                // Dot wave
                VStack(spacing: 10) {
                    Text("Mindful pause...")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.25))
                        .textCase(.uppercase)

                    HStack(spacing: 8) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color(red: 1.0, green: 0.455, blue: 0.086))
                                .frame(width: 6, height: 6)
                                .opacity(dotOpacities[i])
                                .offset(y: dotOffsets[i])
                        }
                    }
                }
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(red: 0.11, green: 0.098, blue: 0.09))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color(red: 0.16, green: 0.145, blue: 0.137), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 50, y: 25)
            )
            .padding(.horizontal, 16)
            .scaleEffect(fadeIn ? 1 : 0.94)
            .opacity(fadeIn ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                fadeIn = true
            }
            startBreathingRings()
            startDotWave()
        }
    }

    // MARK: - Animations
    private func startBreathingRings() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            ring1Scale = 1.05
            ring1Opacity = 0.4
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                ring2Scale = 1.05
                ring2Opacity = 0.15
            }
        }
    }

    private func startDotWave() {
        for i in 0..<3 {
            let delay = Double(i) * 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    dotOffsets[i] = -4
                    dotOpacities[i] = 1.0
                }
            }
        }
    }
}
