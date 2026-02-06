import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            // Multi-layer radial gradient background (matching HTML design)
            ZStack {
                // Base gradient
                RadialGradient(
                    colors: [
                        Color(red: 0.04, green: 0.04, blue: 0.05),
                        Color(red: 0.03, green: 0.04, blue: 0.04),
                        Color(red: 0.03, green: 0.04, blue: 0.04)
                    ],
                    center: .center,
                    startRadius: 50,
                    endRadius: 600
                )
                
                // Top orange glow
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.95),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.75),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.18),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: -0.15),
                    startRadius: 10,
                    endRadius: 300
                )
                
                // Bottom-right accent glow
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.47, blue: 0.23).opacity(0.35),
                        Color(red: 1.0, green: 0.47, blue: 0.23).opacity(0.15),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.82, y: 0.82),
                    startRadius: 10,
                    endRadius: 180
                )
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with menu and profile buttons
                HStack {
                    Button(action: {
                        // TODO: Menu action
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 44, height: 44)
                                .background(Material.ultraThinMaterial)
                                .clipShape(Circle())
                            
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                    
                    Text("BALANCE")
                        .font(.caption2)
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Button(action: {
                        // TODO: Profile action
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
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 8)

                // Balance section
                VStack(spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("$")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("124")
                            .font(.system(size: 64, weight: .light, design: .serif))
                            .foregroundColor(.white)
                        
                        Text(".50")
                            .font(.system(size: 40, weight: .light, design: .serif))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 10)
                    .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.15), radius: 30, x: 0, y: 0)
                    
                    Text("DAILY SPENT")
                        .font(.caption)
                        .tracking(3)
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Remaining pill
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.42, blue: 0.16))
                            .frame(width: 6, height: 6)
                            .shadow(color: Color(red: 1.0, green: 0.42, blue: 0.16), radius: 3)
                        
                        Text("$45.50 remaining")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                }
                .padding(.top, 24)
                .padding(.bottom, 32)

                // Weekly Activity Card
                WeeklyActivityCard()
                    .padding(.bottom, 16)

                // Action buttons row
                ActionButtonsRow()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                // Scrollable transactions
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        TransactionsCard()
                    }
                }
                
                // Bottom padding for navigation bar
                Spacer().frame(height: 100)
            }
        }
    }
}

#Preview {
    HomeView()
}
