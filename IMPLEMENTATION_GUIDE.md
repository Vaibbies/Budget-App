# Penny Budget App - SwiftUI Implementation Guide

## Overview
This document provides a comprehensive guide to the SwiftUI architecture and implementation patterns used in the Penny budgeting app.

## Architecture

### Component Hierarchy

```
PennyApp (App Entry Point)
└── ContentView (Main Navigation Controller)
    ├── Tab Views
    │   ├── HomeView (Spending/Budget View)
    │   ├── PlaceholderView (Friends)
    │   ├── PlaceholderView (Me)
    │   └── PlaceholderView (Bank)
    └── BottomBar (Custom Navigation)
```

### Design Philosophy

**Custom Navigation over TabView**: We opted for a custom bottom navigation implementation instead of Apple's native `TabView` for several reasons:

1. **Elevated Center Button**: The AI chatbot button (Penny) needs to be prominently elevated above the navigation bar with a glowing effect
2. **Custom Styling**: Full control over the frosted glass effect, animations, and orange accent theme
3. **Flexible Layout**: Ability to position the center button outside the normal tab flow

## Core Components

### 1. ContentView (`Penny/ContentView.swift`)

**Purpose**: Main navigation controller that manages tab state and displays the appropriate view.

**Key Features**:
- Uses `@State` to track the currently selected tab
- Implements a `ZStack` with content views and bottom bar overlay
- Tab switching via `switch` statement on `selectedTab`

```swift
@State private var selectedTab: AppTab = .spending

var body: some View {
    ZStack {
        // Tab content
        Group {
            switch selectedTab {
            case .spending: HomeView()
            // ... other cases
            }
        }
        
        // Bottom navigation overlay
        VStack {
            Spacer()
            BottomBar(selectedTab: $selectedTab)
        }
    }
}
```

**Design Pattern**: Container View with Binding-based State Management

---

### 2. BottomBar (`Navigation/BottomBarItem.swift`)

**Purpose**: Custom bottom navigation bar with 4 standard tabs + 1 elevated center button.

**Key Features**:
- Takes `@Binding var selectedTab: AppTab` for two-way state communication
- Center button: Elevated 30pt with radial gradient glow effect
- Uses Material blur effect for frosted glass background
- Responsive button animations

**Visual Hierarchy**:
```
HStack
├── Friends Tab (barItem)
├── Spending Tab (barItem)
├── Spacer
├── CENTER BUTTON (Penny AI Chat - Elevated)
├── Spacer
├── Me Tab (barItem)
└── Bank Tab (barItem)
```

**Center Button Implementation**:
```swift
ZStack {
    // Outer glow (radial gradient blur)
    Circle()
        .fill(RadialGradient(...))
        .blur(radius: 15)
    
    // Main button (linear gradient)
    Circle()
        .fill(LinearGradient(...))
        .shadow(...)
    
    // Icon
    Image(systemName: "bubble.left.and.bubble.right.fill")
}
.offset(y: -30) // Elevate above bar
```

---

### 3. HomeView (`Home/HomeView.swift`)

**Purpose**: Main spending/budget dashboard with balance, activity tracking, and transactions.

**Key Features**:
- **Multi-layer Radial Gradient Background**: Matches the sophisticated orange-to-dark gradient from the HTML design
- **Header**: Menu button (left), "BALANCE" label (center), Profile avatar (right)
- **Balance Display**: Large serif font with shadow effects for depth
- **ScrollView**: Contains transactions list with proper bottom padding for navigation bar

**Layout Structure**:
```
ZStack
├── Background (3-layer radial gradients)
└── VStack
    ├── Header (Menu | BALANCE | Profile)
    ├── Balance Section ($124.50)
    ├── WeeklyActivityCard
    ├── ActionButtonsRow (Add, Scan, Goals, Analytics)
    └── ScrollView
        └── TransactionsCard
```

**Gradient Implementation**:
```swift
// Base dark gradient
RadialGradient(colors: [dark colors], ...)

// Top orange glow (simulates light source)
RadialGradient(
    colors: [orange.opacity(0.95), ..., clear],
    center: UnitPoint(x: 0.5, y: -0.15), // Above screen
    ...
)

// Bottom-right accent
RadialGradient(
    center: UnitPoint(x: 0.82, y: 0.82),
    ...
)
```

---

### 4. WeeklyActivityCard (`Home/WeeklyActivityCard.swift`)

**Purpose**: Dot-matrix visualization of spending activity across the week.

**Key Features**:
- 7 columns (M-S) with up to 12 dots each
- Active day (current day) highlighted in orange
- "IMPULSE" indicator with orange dot
- Frosted glass card with border

**Data Structure**:
```swift
private let activityLevels: [[Bool]] = [
    [true, false, false, ...], // Monday
    [true, true, false, ...],  // Tuesday
    // ... 7 days total
]
```

---

### 5. ActionButtonsRow (`Home/ActionButtonsRow.swift`)

**Purpose**: Quick action buttons for common tasks (Add expense, Scan, Goals, Analytics).

**Key Features**:
- 4 equal-width buttons in HStack
- Frosted glass effect with Material blur
- Interactive press animation (scales to 0.95)
- Hover state changes icon color to orange

**Button Structure**:
```swift
ActionButton(icon: "plus", action: { ... })

// Implementation
ZStack {
    RoundedRectangle(...)
        .fill(Color.black.opacity(0.4))
        .backdrop(Material.ultraThinMaterial)
    
    Image(systemName: icon)
        .foregroundColor(isPressed ? orange : white)
}
.buttonStyle(ActionButtonStyle(...))
```

---

### 6. TransactionsCard (`Home/TransactionsCard.swift`)

**Purpose**: Displays recent transactions with impulse toggle.

**Key Features**:
- Transaction rows with emoji icons
- Category labels (Coffee & Pastry, Entertainment, etc.)
- Toggle switches to mark impulse purchases
- Dividers between rows

---

### 7. AppTab Enum (`Navigation/Tab.swift`)

**Purpose**: Defines the 4 main navigation tabs.

```swift
enum AppTab: CaseIterable {
    case friends   // person.2
    case spending  // shield
    case me        // face.smiling
    case bank      // creditcard
}
```

**Note**: The 5th button (center Penny chat) is NOT a tab - it's a special action button.

---

## State Management

### Current Approach: @State and @Binding

**For this app size**, we use SwiftUI's basic state management:

- **@State**: Used in ContentView to hold `selectedTab`
- **@Binding**: Passed to BottomBar for two-way communication
- **@State**: Used in individual components for local UI state (e.g., button press)

### When to Scale Up

If the app grows to include:
- User authentication
- Real transaction data from APIs
- Multiple views needing shared state
- Data persistence

Consider migrating to:
- **@StateObject / @ObservedObject**: For view model pattern
- **@EnvironmentObject**: For app-wide shared state
- **SwiftData or Core Data**: For persistence

---

## Color System

### Primary Colors
```swift
// Orange accent (primary action color)
Color(red: 1.0, green: 0.42, blue: 0.16) // #FF6A29

// Gradient variants
Color(red: 1.0, green: 0.55, blue: 0.25) // Lighter
Color(red: 1.0, green: 0.38, blue: 0.13) // Darker

// Background darks
Color(red: 0.04, green: 0.04, blue: 0.05) // Near black
Color(red: 0.03, green: 0.04, blue: 0.04) // Darkest
```

### Text Colors
```swift
.white.opacity(0.9)  // Primary text
.white.opacity(0.7)  // Secondary text
.white.opacity(0.5)  // Tertiary/labels
.white.opacity(0.3)  // Disabled/placeholder
```

---

## Glass Morphism Effects

### Frosted Cards
```swift
RoundedRectangle(cornerRadius: 22)
    .fill(Color.black.opacity(0.4))
    .backdrop(Material.ultraThinMaterial) // iOS 15+ blur
    .clipShape(RoundedRectangle(cornerRadius: 22))
    .overlay(
        RoundedRectangle(cornerRadius: 22)
            .stroke(Color.white.opacity(0.06), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.35), radius: 8)
```

**Key Ingredients**:
1. Semi-transparent dark fill (0.3-0.5 opacity)
2. Material blur backdrop
3. Subtle white border (0.06-0.1 opacity)
4. Soft shadow for depth

---

## Animations

### Button Press Animation
```swift
struct ActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
```

### Smooth Tab Transitions
- Use `withAnimation` when changing `selectedTab`
- Consider `.transition(.opacity)` for view switching

---

## Accessibility Considerations

### Current Implementation
- Buttons use semantic `Button` views (VoiceOver compatible)
- System SF Symbols provide automatic scaling
- Color contrast meets WCAG guidelines (white on dark)

### Improvements Needed
- Add `.accessibilityLabel()` to icon-only buttons
- Add `.accessibilityHint()` for complex actions
- Support Dynamic Type for text sizes
- Test with VoiceOver enabled

---

## Performance Optimizations

### Current Best Practices
✅ `ScrollView` with `showsIndicators: false` for smooth scrolling
✅ `.ignoresSafeArea()` on background only (not interactive elements)
✅ Lazy loading potential for long transaction lists

### Future Optimizations
- Use `LazyVStack` instead of `VStack` in ScrollView when transaction count > 20
- Implement pagination for transaction history
- Cache gradient layers if performance issues arise

---

## Adding New Files to Xcode

**IMPORTANT**: Swift files created outside Xcode need to be manually added to the project.

### Steps:
1. In Xcode, right-click on the folder (e.g., "Home")
2. Select "Add Files to Penny..."
3. Navigate to and select the new file
4. Ensure "Add to targets: Penny" is checked
5. Click "Add"

### Files to Add:
- ✅ `/Home/ActionButtonsRow.swift`
- ✅ All existing files if not already in project

**Check if added**: Open `project.pbxproj` and search for filename

---

## Testing Checklist

### Visual Testing
- [ ] Test on iPhone 15 Pro (6.1")
- [ ] Test on iPhone 15 Pro Max (6.7")
- [ ] Test on iPhone SE (4.7")
- [ ] Dark mode appearance (primary design)
- [ ] Light mode appearance (if supported)

### Interaction Testing
- [ ] Tab switching responds instantly
- [ ] Center Penny button shows visual feedback
- [ ] Action buttons scale on press
- [ ] ScrollView smooth with 10+ transactions
- [ ] Impulse toggles update transaction color

### Edge Cases
- [ ] Very long transaction names
- [ ] Very large amounts ($10,000+)
- [ ] Empty transaction list
- [ ] Landscape orientation

---

## Next Steps / Roadmap

### Phase 1: Core UI (Current)
- ✅ Custom bottom navigation
- ✅ Home view with gradient
- ✅ Weekly activity visualization
- ✅ Transaction list

### Phase 2: Data Integration
- [ ] Create Transaction model
- [ ] Implement mock data service
- [ ] Add transaction creation form
- [ ] Implement impulse toggle logic

### Phase 3: AI Chat (Penny)
- [ ] Create chat interface
- [ ] Implement modal presentation
- [ ] Add message bubbles
- [ ] Integrate AI backend

### Phase 4: Additional Tabs
- [ ] Friends view (split bills)
- [ ] Me view (profile/settings)
- [ ] Bank view (account linking)

### Phase 5: Advanced Features
- [ ] Budget goals with progress tracking
- [ ] Receipt scanning (Vision framework)
- [ ] Analytics charts
- [ ] Notifications for spending alerts

---

## Common Issues & Solutions

### Issue: "Cannot find 'HomeView' in scope"
**Cause**: File not added to Xcode project target
**Solution**: Add file to target via Xcode (see "Adding New Files" section)

### Issue: Gradient looks different than design
**Cause**: Radial gradient center/radius values
**Solution**: Adjust `startRadius`, `endRadius`, and `center` UnitPoint

### Issue: Bottom bar overlaps content
**Cause**: No bottom padding in scroll view
**Solution**: Add `Spacer().frame(height: 100)` at end of VStack

### Issue: Center button not elevated enough
**Cause**: Offset value too small
**Solution**: Increase `.offset(y: -30)` to `.offset(y: -35)` or more

---

## Resources

### Apple Documentation
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [SF Symbols Browser](https://developer.apple.com/sf-symbols/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Design Resources
- [Figma Penny Design](link-to-design-file)
- [Color Palette](link-to-palette)
- [Typography Scale](link-to-type-scale)

---

**Last Updated**: February 2026
**SwiftUI Version**: iOS 17+
**Xcode Version**: 15.0+

