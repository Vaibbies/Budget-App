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
