# 🪙 Penny - SwiftUI Budget App

A modern, AI-powered budgeting app built with SwiftUI featuring glassmorphism design and impulse spending tracking.

## ✨ Features Implemented

### 🎨 Custom UI Components
- **Custom Bottom Navigation**: 4 standard tabs + elevated Penny AI chat button
- **Radial Gradient Background**: Multi-layer orange glow effect
- **Frosted Glass Cards**: Modern glassmorphism design
- **Weekly Activity Visualization**: Dot-matrix spending tracker
- **Action Buttons**: Quick access to Add, Scan, Goals, and Analytics

### 🏗️ Architecture
- **SwiftUI-Native**: Built entirely with SwiftUI (iOS 17+)
- **Custom Navigation**: No TabView - full control over bottom bar
- **State Management**: @State and @Binding for reactive UI
- **Component-Based**: Modular, reusable components

## 📁 Project Structure

```
Penny/
├── Home/
│   ├── HomeView.swift              # Main spending dashboard
│   ├── WeeklyActivityCard.swift    # Dot-matrix activity tracker
│   ├── TransactionsCard.swift      # Transaction list
│   ├── TransactionRow.swift        # Individual transaction
│   ├── ActionButtonsRow.swift      # Quick action buttons ⭐ NEW
│   └── BalanceHeaderView.swift     
│
├── Navigation/
│   ├── BottomBar.swift             # Custom bottom navigation
│   ├── BottomBarItem.swift         # Nav items + center button
│   ├── Tab.swift                   # Tab enum (AppTab)
│   └── Navigation.swift            # Header buttons
│
├── Penny/
│   ├── PennyApp.swift              # App entry point
│   ├── ContentView.swift           # Main navigation controller
│   └── Assets.xcassets/
│
└── Documentation/
    ├── SETUP.md                    # Quick setup guide
    ├── IMPLEMENTATION_GUIDE.md     # Detailed architecture docs
    └── COMPONENT_REFERENCE.md      # SwiftUI patterns reference
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ target
- macOS for development

### Setup Instructions

1. **Clone the repository**
   ```bash
   cd /Users/andrewyu/Documents/GitHub/Penny
   ```

2. **Open in Xcode**
   ```bash
   open Penny.xcodeproj
   ```

3. **⚠️ IMPORTANT: Add new files to Xcode**
   - Right-click "Home" folder in Project Navigator
   - Select "Add Files to Penny..."
   - Add: `ActionButtonsRow.swift`
   - Ensure "Add to targets: Penny" is checked

4. **Build and Run**
   - Press `Cmd + R`
   - Test on iOS 17+ simulator

### Quick Reference
- 📖 See **SETUP.md** for detailed setup steps
- 🏗️ See **IMPLEMENTATION_GUIDE.md** for architecture details
- 🔧 See **COMPONENT_REFERENCE.md** for SwiftUI patterns

## 🎨 Design System

### Color Palette
```swift
// Primary Orange (Accent)
#FF6A29 - Color(red: 1.0, green: 0.42, blue: 0.16)

// Gradients
#FF8C40 - Lighter orange
#FF6121 - Darker orange

// Backgrounds
#0A0B0D - Near black
rgba(0, 0, 0, 0.4) - Frosted glass
```

### Typography
- **Balance**: 64pt Serif Light (Playfair-inspired)
- **Headers**: 12pt Caps with letter spacing
- **Body**: 14pt Medium
- **Captions**: 10-12pt Regular

### Components
- **Corner Radius**: 22px for cards
- **Glass Effect**: ultraThinMaterial + 0.4 opacity
- **Shadows**: Multiple layers for depth
- **Spacing**: 12-24pt standard gaps

## 🛠️ Technology Stack

- **Framework**: SwiftUI
- **Language**: Swift 5.9+
- **Min iOS**: 17.0
- **Target**: iPhone (portrait)

## 📱 App Structure

### Navigation Flow
```
ContentView (Root)
  ├─ Friends Tab (Placeholder)
  ├─ Spending Tab (HomeView) ⭐ Default
  ├─ Me Tab (Placeholder)
  ├─ Bank Tab (Placeholder)
  └─ Penny AI (Center button - Modal)
```

### HomeView Layout
```
Header (Menu | BALANCE | Profile)
  ↓
Balance Display ($124.50)
  ↓
Weekly Activity Card (M-S dots)
  ↓
Action Buttons (Add | Scan | Goals | Analytics)
  ↓
Transactions List (Scrollable)
```

## 🎯 Key Features Explained

### 1. Custom Bottom Navigation
**Why not use TabView?**
- Need elevated center button (Penny AI chat)
- Custom frosted glass styling
- Orange glow effect on center button
- Full control over animations

**Implementation**: ZStack with overlay pattern

### 2. Radial Gradient Background
**Why radial over linear?**
- Creates depth and focus
- Simulates lighting from top
- Modern, sophisticated look
- Matches original HTML design

**Layers**:
1. Dark base gradient (near black)
2. Top orange glow (above screen)
3. Bottom-right accent glow

### 3. Impulse Tracking
**Feature**: Toggle to mark purchases as "impulse"
- Toggles change amount color to orange
- Shows in weekly activity as filled dots
- Helps identify spending patterns

### 4. Weekly Activity Visualization
**Dot Matrix Design**:
- 7 columns (M-S) × up to 12 rows
- Each dot represents spending threshold
- Filled orange = impulse spending
- Filled low opacity = regular spending
- Empty = no spending at that level

## 🔮 Roadmap

### Phase 1: Core UI ✅ (Current)
- [x] Custom bottom navigation
- [x] Home view with gradient
- [x] Weekly activity visualization
- [x] Transaction list UI
- [x] Action buttons

### Phase 2: Data Layer (Next)
- [ ] Transaction data model
- [ ] Local persistence (SwiftData)
- [ ] Mock data service
- [ ] CRUD operations

### Phase 3: AI Integration
- [ ] Penny chat interface
- [ ] Modal presentation
- [ ] Message bubbles
- [ ] AI backend integration

### Phase 4: Features
- [ ] Receipt scanning (Vision)
- [ ] Budget goals
- [ ] Analytics charts
- [ ] Push notifications
- [ ] Widget support

### Phase 5: Additional Tabs
- [ ] Friends (split bills)
- [ ] Me (profile/settings)
- [ ] Bank (account linking)

## 🤝 Contributing

### Code Style
- Use SwiftUI best practices
- Follow existing component patterns
- Add comments for complex logic
- Update documentation

### Adding New Components
1. Create file in appropriate folder
2. Add to Xcode project target
3. Follow naming conventions
4. Add preview
5. Update documentation

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **SETUP.md** | Quick start guide and troubleshooting |
| **IMPLEMENTATION_GUIDE.md** | Detailed architecture and patterns |
| **COMPONENT_REFERENCE.md** | SwiftUI cheat sheet and examples |

## 🐛 Known Issues

- [ ] Files need to be manually added to Xcode (not automated)
- [ ] No data persistence yet (static data)
- [ ] Penny AI button has no action yet
- [ ] Other tabs are placeholders

## 💡 Tips

1. **Always test on device**: Gradients look different on simulators
2. **Check target membership**: New files must be added to Xcode
3. **Use previews**: Speed up development with #Preview
4. **Read COMPONENT_REFERENCE.md**: Quick patterns and fixes

## 📄 License

[Your License Here]

## 👥 Authors

- Andrew Yu (@andrewyu)
- [Contributors]

---

**Last Updated**: February 5, 2026  
**SwiftUI Version**: iOS 17+  
**Status**: Phase 1 Complete ✅

