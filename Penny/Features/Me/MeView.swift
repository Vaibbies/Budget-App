import SwiftUI

struct MeView: View {

    @State private var showNotifications = false
    @State private var showSettings = false

    private let stats = [
        MeStatItem(emoji: "🔥", value: "14", label: "Streak"),
        MeStatItem(emoji: "💰", value: "$348", label: "Saved"),
        MeStatItem(emoji: "🎯", value: "23", label: "Impulses"),
    ]

    private let achievements = [
        MeAchievement(
            emoji: "🏔️",
            name: "Peak Saver",
            date: "Unlocked Oct 12",
            unlocked: true,
            gradientColors: [Color.orange, Color(red: 1.0, green: 0.55, blue: 0.0)]
        ),
        MeAchievement(
            emoji: "💎",
            name: "Diamond Hands",
            date: "Unlocked Sep 28",
            unlocked: true,
            gradientColors: [Color.cyan, Color.blue]
        ),
        MeAchievement(emoji: "🚀", name: "To The Moon", date: "Save $1,000", unlocked: false),
        MeAchievement(emoji: "🧘", name: "Zen Master", date: "30 Day Streak", unlocked: false),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection

                    MeProfileHeader()

                    MeStatsGrid(stats: stats)
                    MeInsightCard()

                    MeMenuGroup(items: menuItems1, onTap: handleMenuTap1)
                        .padding(.bottom, 24)

                    MeAchievementsSection(achievements: achievements)

                    MeMenuGroup(items: menuItems2, onTap: handleMenuTap2)
                        .padding(.bottom, 16)

                    MeMenuGroup(items: menuItems3, onTap: { _ in })
                        .padding(.bottom, 24)

                    MeFooter()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            .background(backgroundGradient)
            .navigationDestination(isPresented: $showNotifications) {
                NotificationsSettingsView()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    // MARK: - Menu Items
    private let menuItems1 = [
        MeMenuItem(icon: "chart.pie.fill",  label: "Budget & Goals"),
        MeMenuItem(icon: "lock.fill",       label: "Connected Banks", badge: "3 Active"),
        MeMenuItem(icon: "bell.fill",       label: "Notifications"),
    ]

    private let menuItems2 = [
        MeMenuItem(icon: "gearshape.fill",  label: "Settings"),
        MeMenuItem(icon: "sparkles",        label: "Penny AI Settings"),
        MeMenuItem(icon: "shield.fill",     label: "Privacy & Security"),
        MeMenuItem(icon: "person.2.fill",   label: "Friends & Community"),
    ]

    private let menuItems3 = [
        MeMenuItem(icon: "questionmark.circle.fill", label: "Help & FAQs"),
        MeMenuItem(icon: "envelope.fill",           label: "Contact Support"),
    ]

    private func handleMenuTap1(_ item: MeMenuItem) {
        if item.label == "Notifications" {
            showNotifications = true
        }
    }

    private func handleMenuTap2(_ item: MeMenuItem) {
        if item.label == "Settings" {
            showSettings = true
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Spacer()
            Text("PROFILE")
                .font(.system(size: 13, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        ZStack {
            MeTheme.canvas.ignoresSafeArea()
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.25),
                    Color(red: 1.0, green: 0.376, blue: 0.125).opacity(0.05),
                    Color.clear
                ],
                center: .init(x: 0.5, y: 0.0),
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MeView()
        .preferredColorScheme(.dark)
}
