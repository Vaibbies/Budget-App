import SwiftUI

// MARK: - Theme
enum MeTheme {
    static let canvas = Color(red: 0.039, green: 0.043, blue: 0.051)
    static let surface = Color.white.opacity(0.03)
    static let surfaceHighlight = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.06)
    static let ink = Color(red: 0.957, green: 0.961, blue: 0.969)
    static let muted = Color(red: 0.643, green: 0.655, blue: 0.682)
    static let accent = Color(red: 1.0, green: 0.416, blue: 0.165)
    static let accentLight = Color(red: 1.0, green: 0.553, blue: 0.361)
    static let success = Color(red: 0.063, green: 0.725, blue: 0.506)
}

struct PennyWarmBackground: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            LinearGradient(
                colors: [
                    Color(red: 0.20, green: 0.12, blue: 0.08),
                    Color(red: 0.08, green: 0.05, blue: 0.04),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 0.85, green: 0.45, blue: 0.20).opacity(0.9),
                    Color(red: 0.75, green: 0.35, blue: 0.15).opacity(0.6),
                    Color(red: 0.50, green: 0.25, blue: 0.12).opacity(0.3),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: -0.1),
                startRadius: 20,
                endRadius: 380
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Data Models
struct MeStatItem: Identifiable {
    let id = UUID()
    let emoji: String
    let value: String
    let label: String
}

struct MeMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    var badge: String? = nil
}

struct MeAchievement: Identifiable {
    let id = UUID()
    let emoji: String
    let name: String
    let date: String
    let unlocked: Bool
    var gradientColors: [Color] = []
}
    
    
