import SwiftUI

// MARK: - Profile Header
struct MeProfileHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                MeTheme.accent.opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 45,
                            endRadius: 70
                        )
                    )
                    .frame(width: 130, height: 130)
                
                Circle()
                    .fill(Color(red: 0.071, green: 0.071, blue: 0.078))
                    .frame(width: 112, height: 112)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .overlay(
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white.opacity(0.3))
                            .clipShape(Circle())
                    )
                
                Button {
                    // edit photo
                } label: {
                    Circle()
                        .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                .offset(x: 40, y: 40)
            }
            
            Text("Alex Morgan")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.top, 16)
            
            Text("@alexm_organ")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .padding(.top, 4)
        }
        .padding(.bottom, 28)
    }
}

// MARK: - Stats Grid
struct MeStatsGrid: View {
    let stats: [MeStatItem]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(stats) { stat in
                VStack(spacing: 6) {
                    Text(stat.emoji)
                        .font(.system(size: 24))
                        .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                    
                    Text(stat.value)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                    
                    Text(stat.label.uppercased())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(MeTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(MeTheme.glassBorder, lineWidth: 1)
                )
            }
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Insight Card
struct MeInsightCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [MeTheme.accent, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 32, height: 32)
                .shadow(color: MeTheme.accent.opacity(0.3), radius: 8, y: 4)
                .overlay(
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("PENNY INSIGHT")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(MeTheme.accent)
                    .tracking(1.5)
                
                (Text("You've curbed your coffee spending by ")
                    .foregroundColor(.white.opacity(0.8))
                 + Text("18%")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                 + Text(" this month. That's enough for a nice dinner! 🍝")
                    .foregroundColor(.white.opacity(0.8)))
                    .font(.system(size: 12, weight: .medium))
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            MeTheme.accent.opacity(0.08),
                            MeTheme.accent.opacity(0.02)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(MeTheme.accent.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.bottom, 28)
    }
}

// MARK: - Menu Group
struct MeMenuGroup: View {
    let items: [MeMenuItem]
    var onTap: ((MeMenuItem) -> Void) = { _ in }  // ← added

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {
                    onTap(item)  // ← changed
                } label: {
                    HStack(spacing: 14) {
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: item.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            )
                        
                        Text(item.label)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Spacer()
                        
                        if let badge = item.badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(MeTheme.success)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(MeTheme.success.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(MeTheme.success.opacity(0.1), lineWidth: 1)
                                        )
                                )
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if index < items.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.05))
                        .padding(.leading, 56)
                }
            }
        }
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(MeTheme.glassBorder, lineWidth: 1)
        )
    }
}

// MARK: - Achievements Section
struct MeAchievementsSection: View {
    let achievements: [MeAchievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ACHIEVEMENTS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(2)
                
                Spacer()
                
                Button("View All") {
                    // view all
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(MeTheme.accent)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievements) { achievement in
                        achievementCard(achievement)
                    }
                }
            }
        }
        .padding(.bottom, 24)
    }
    
    private func achievementCard(_ achievement: MeAchievement) -> some View {
        VStack(spacing: 12) {
            ZStack {
                if achievement.unlocked {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: achievement.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)
                        .shadow(color: achievement.gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, y: 4)
                        .overlay(
                            Circle()
                                .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                                .padding(1)
                        )
                        .overlay(
                            Text(achievement.emoji)
                                .font(.system(size: 20))
                        )
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(achievement.emoji)
                                .font(.system(size: 20))
                                .grayscale(1.0)
                                .opacity(0.5)
                        )
                }
            }
            
            VStack(spacing: 2) {
                Text(achievement.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                
                Text(achievement.date)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .opacity(achievement.unlocked ? 1 : 0.5)
        }
        .frame(width: 130)
        .padding(.vertical, 16)
        .background(MeTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    achievement.unlocked
                        ? MeTheme.glassBorder
                        : Color.white.opacity(0.1),
                    style: achievement.unlocked
                        ? StrokeStyle(lineWidth: 1)
                        : StrokeStyle(lineWidth: 1, dash: [6, 4])
                )
        )
    }
}

// MARK: - Footer
struct MeFooter: View {
    var body: some View {
        VStack(spacing: 16) {
            Button("Sign Out") {
                // sign out
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white.opacity(0.6))
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .stroke(Color.clear, lineWidth: 1)
            )
            
            Text("VERSION 1.0.0")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.2))
                .tracking(2)
        }
        .padding(.bottom, 8)
    }
}
