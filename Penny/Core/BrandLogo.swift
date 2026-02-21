import SwiftUI

let brandDomains: [String: String] = [
    // Music & Audio
    "spotify": "spotify.com",
    "spotify premium": "spotify.com",
    "apple music": "apple.com",
    "tidal": "tidal.com",
    "soundcloud": "soundcloud.com",
    "audible": "audible.com",

    // Video
    "netflix": "netflix.com",
    "hulu": "hulu.com",
    "disney": "disneyplus.com",
    "disney+": "disneyplus.com",
    "hbo": "max.com",
    "hbo max": "max.com",
    "max": "max.com",
    "amazon prime": "amazon.com",
    "prime video": "amazon.com",
    "youtube": "youtube.com",
    "youtube premium": "youtube.com",
    "peacock": "peacocktv.com",
    "paramount": "paramountplus.com",
    "paramount+": "paramountplus.com",
    "crunchyroll": "crunchyroll.com",
    "funimation": "funimation.com",
    "apple tv": "apple.com",
    "apple tv+": "apple.com",

    // Cloud & Storage
    "icloud": "apple.com",
    "google one": "one.google.com",
    "dropbox": "dropbox.com",
    "onedrive": "microsoft.com",

    // Productivity
    "notion": "notion.so",
    "slack": "slack.com",
    "zoom": "zoom.us",
    "figma": "figma.com",
    "github": "github.com",
    "linear": "linear.app",
    "microsoft": "microsoft.com",
    "office 365": "microsoft.com",
    "office": "microsoft.com",
    "adobe": "adobe.com",
    "adobe creative cloud": "adobe.com",

    // Gaming
    "steam": "store.steampowered.com",
    "steam store": "store.steampowered.com",
    "xbox": "xbox.com",
    "xbox game pass": "xbox.com",
    "playstation": "playstation.com",
    "ps plus": "playstation.com",
    "nintendo": "nintendo.com",
    "twitch": "twitch.tv",
    "discord": "discord.com",
    "epic games": "epicgames.com",

    // Food & Delivery
    "sweetgreen": "sweetgreen.com",
    "sweetgreen salads": "sweetgreen.com",
    "chipotle": "chipotle.com",
    "doordash": "doordash.com",
    "uber eats": "ubereats.com",
    "grubhub": "grubhub.com",
    "instacart": "instacart.com",

    // Transport
    "uber": "uber.com",
    "lyft": "lyft.com",
    "caltrain": "caltrain.com",
    "caltrain ticket": "caltrain.com",
    "bart": "bart.gov",
    "metro": "metro.net",

    // Fitness
    "equinox": "equinox.com",
    "peloton": "onepeloton.com",
    "headspace": "headspace.com",
    "calm": "calm.com",
    "duolingo": "duolingo.com",
    "strava": "strava.com",

    // Shopping
    "amazon": "amazon.com",
    "target": "target.com",
    "walmart": "walmart.com",
    "costco": "costco.com",
    "apple": "apple.com",

    // Gas & Utilities
    "shell": "shell.com",
    "shell gas": "shell.com",
    "chevron": "chevron.com",
    "bp": "bp.com",
    "exxon": "exxon.com",
    "pg&e": "pge.com",
    "at&t": "att.com",
    "verizon": "verizon.com",
    "comcast": "comcast.com",
    "xfinity": "xfinity.com",
    "t-mobile": "t-mobile.com",

    // Finance
    "venmo": "venmo.com",
    "paypal": "paypal.com",
    "cashapp": "cash.app",
    "cash app": "cash.app",
    "robinhood": "robinhood.com",
    "coinbase": "coinbase.com",

    // News & Reading
    "nytimes": "nytimes.com",
    "new york times": "nytimes.com",
    "wsj": "wsj.com",
    "medium": "medium.com",
    "substack": "substack.com",

    // AI & Tech
    "chatgpt": "openai.com",
    "openai": "openai.com",
    "claude": "anthropic.com",
    "1password": "1password.com",
    "nordvpn": "nordvpn.com",
    "expressvpn": "expressvpn.com",
    "patreon": "patreon.com",
]

// Category fallback icons
let categoryFallbackIcons: [String: String] = [
    "Dining": "fork.knife",
    "Transport": "car.fill",
    "Shopping": "bag.fill",
    "Entertainment": "gamecontroller.fill",
    "Groceries": "cart.fill",
    "Utilities": "bolt.fill",
    "Fitness": "dumbbell.fill",
    "Subscriptions": "music.note",
    "Lifestyle": "cup.and.saucer.fill",
    "Other": "ellipsis.circle.fill",
]

func brandLogoURL(for name: String) -> URL? {
    let key = name.lowercased().trimmingCharacters(in: .whitespaces)

    // Only look up known brands — no guessing
    if let domain = brandDomains[key] {
        return URL(string: "https://www.google.com/s2/favicons?domain=\(domain)&sz=128")
    }

    // Try first word match — "Spotify Premium" → "spotify"
    let firstWord = key.components(separatedBy: " ").first ?? key
    if let domain = brandDomains[firstWord] {
        return URL(string: "https://www.google.com/s2/favicons?domain=\(domain)&sz=128")
    }

    // Unknown — return nil, show nothing
    return nil
}

struct BrandLogoView: View {
    let name: String
    let size: CGFloat
    let fallbackIcon: String
    let fallbackColor: Color
    var showFallback: Bool = false

    @State private var debouncedName = ""
    @State private var debounceTask: Task<Void, Never>? = nil

    var body: some View {
        Group {
            if debouncedName.isEmpty {
                Color.clear
            } else {
                AsyncImage(url: brandLogoURL(for: debouncedName)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.62, height: size * 0.62)
                            .clipShape(RoundedRectangle(cornerRadius: size * 0.12))
                    default:
                        if showFallback {
                            Image(systemName: fallbackIcon)
                                .font(.system(size: size * 0.38, weight: .medium))
                                .foregroundColor(fallbackColor)
                        } else {
                            Color.clear
                        }
                    }
                }
            }
        }
        .onAppear {
            debouncedName = name
        }
        .onChange(of: name) { _, newValue in
            // Cancel previous debounce and start a new one
            debounceTask?.cancel()
            debounceTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 600_000_000) // 600ms
                guard !Task.isCancelled else { return }
                debouncedName = newValue.trimmingCharacters(in: .whitespaces)
            }
        }
        .onDisappear {
            debounceTask?.cancel()
            debounceTask = nil
        }
    }
}
