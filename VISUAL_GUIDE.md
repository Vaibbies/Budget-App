# Visual Component Hierarchy

## 🎨 App Navigation Structure

```
┌─────────────────────────────────────────┐
│           PennyApp (@main)              │
│                  ↓                      │
│           ContentView                   │
│         (Tab Controller)                │
└─────────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┬─────────────┐
    ↓             ↓             ↓             ↓
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│ Friends │  │Spending │  │   Me    │  │  Bank   │
│  (Tab)  │  │  (Tab)  │  │  (Tab)  │  │  (Tab)  │
└─────────┘  └─────────┘  └─────────┘  └─────────┘
Placeholder    HomeView   Placeholder  Placeholder
                  ↓
                [ACTIVE VIEW]
```

## 🏠 HomeView Component Breakdown

```
┌────────────────────────────────────────────────────────┐
│                      HomeView                          │
│  ┌──────────────────────────────────────────────────┐ │
│  │            ZStack (Layout Container)             │ │
│  │  ┌────────────────────────────────────────────┐ │ │
│  │  │    Layer 1: Radial Gradient Background    │ │ │
│  │  │    • Base dark gradient                   │ │ │
│  │  │    • Top orange glow (y: -0.15)          │ │ │
│  │  │    • Bottom-right accent (x:0.82, y:0.82)│ │ │
│  │  └────────────────────────────────────────────┘ │ │
│  │  ┌────────────────────────────────────────────┐ │ │
│  │  │    Layer 2: Content VStack                │ │ │
│  │  │                                            │ │ │
│  │  │  ╔════════════════════════════════════╗   │ │ │
│  │  │  ║        Header HStack               ║   │ │ │
│  │  │  ║  [☰]  BALANCE  [👤]               ║   │ │ │
│  │  │  ╚════════════════════════════════════╝   │ │ │
│  │  │                                            │ │ │
│  │  │  ╔════════════════════════════════════╗   │ │ │
│  │  │  ║      Balance VStack                ║   │ │ │
│  │  │  ║         $ 124.50                   ║   │ │ │
│  │  │  ║       DAILY SPENT                  ║   │ │ │
│  │  │  ║    [•] $45.50 remaining           ║   │ │ │
│  │  │  ╚════════════════════════════════════╝   │ │ │
│  │  │                                            │ │ │
│  │  │  ╔════════════════════════════════════╗   │ │ │
│  │  │  ║    WeeklyActivityCard              ║   │ │ │
│  │  │  ║  Weekly Activity    [•] IMPULSE    ║   │ │ │
│  │  │  ║  ┌─┬─┬─┬─┬─┬─┬─┐                  ║   │ │ │
│  │  │  ║  │•│•│•│•│•│•│•│ ← 12 dots tall    ║   │ │ │
│  │  │  ║  │•│•│•│•│•│•│•│                   ║   │ │ │
│  │  │  ║  │•│•│•│•│•│•│•│                   ║   │ │ │
│  │  │  ║  └─┴─┴─┴─┴─┴─┴─┘                  ║   │ │ │
│  │  │  ║  M T W T F S S                     ║   │ │ │
│  │  │  ╚════════════════════════════════════╝   │ │ │
│  │  │                                            │ │ │
│  │  │  ╔════════════════════════════════════╗   │ │ │
│  │  │  ║     ActionButtonsRow               ║   │ │ │
│  │  │  ║  [+] [📷] [🎯] [📊]               ║   │ │ │
│  │  │  ╚════════════════════════════════════╝   │ │ │
│  │  │                                            │ │ │
│  │  │  ╔════════════════════════════════════╗   │ │ │
│  │  │  ║     ScrollView (Scrollable)        ║   │ │ │
│  │  │  ║  ┌──────────────────────────────┐ ║   │ │ │
│  │  │  ║  │   TransactionsCard           │ ║   │ │ │
│  │  │  ║  │  ┌────────────────────────┐  │ ║   │ │ │
│  │  │  ║  │  │ ☕ Blue Bottle -$12.50 │  │ ║   │ │ │
│  │  │  ║  │  │    Coffee & Pastry  [⚫]│  │ ║   │ │ │
│  │  │  ║  │  ├────────────────────────┤  │ ║   │ │ │
│  │  │  ║  │  │ 🎮 Steam Store -$59.99 │  │ ║   │ │ │
│  │  │  ║  │  │    Entertainment   [🟠]│  │ ║   │ │ │
│  │  │  ║  │  └────────────────────────┘  │ ║   │ │ │
│  │  │  ║  └──────────────────────────────┘ ║   │ │ │
│  │  │  ║                                    ║   │ │ │
│  │  │  ╚════════════════════════════════════╝   │ │ │
│  │  │                                            │ │ │
│  │  │     [Bottom Padding: 100pt]                │ │ │
│  │  └────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────┘
                         │
                         ↓
          [Overlayed by BottomBar]
```

## 🧭 BottomBar Structure

```
┌──────────────────────────────────────────────────────────┐
│                     BottomBar                            │
│  ┌────────────────────────────────────────────────────┐ │
│  │         HStack (Main Container)                    │ │
│  │                                                     │ │
│  │  ┌──────┐   ┌──────┐         ┌──────┐   ┌──────┐ │ │
│  │  │  👥  │   │  🛡️  │         │  😊  │   │  💳  │ │ │
│  │  │Friend│   │Spend │         │  Me  │   │ Bank │ │ │
│  │  └──────┘   └──────┘         └──────┘   └──────┘ │ │
│  │                                                     │ │
│  │                ┌─────────┐                         │ │
│  │                │         │                         │ │
│  │            ┌───┤    💬   ├───┐                    │ │
│  │            │   │  Penny  │   │ ← Elevated -30pt   │ │
│  │            │   │   AI    │   │                    │ │
│  │            │   └─────────┘   │                    │ │
│  │            │  Orange Glow    │                    │ │
│  │            └─────────────────┘                    │ │
│  │                                                     │ │
│  └────────────────────────────────────────────────────┘ │
│           Frosted Glass Capsule Background             │
└──────────────────────────────────────────────────────────┘

Legend:
  Standard Tabs: barItem() function
  Center Button: centerButton computed property
  Position: .offset(y: -30) for elevation
```

## 📊 Component Dependencies

```
ContentView
  ├─ Imports: HomeView, BottomBar, AppTab
  └─ State: @State selectedTab: AppTab

HomeView
  ├─ Imports: WeeklyActivityCard, ActionButtonsRow, TransactionsCard
  └─ State: None (stateless presentation)

BottomBar
  ├─ Imports: AppTab
  └─ State: @Binding selectedTab: AppTab

WeeklyActivityCard
  ├─ Imports: None
  └─ State: Hardcoded activityLevels data

ActionButtonsRow
  ├─ Imports: None
  └─ State: @State isPressed (per button)

TransactionsCard
  ├─ Imports: TransactionRow
  └─ State: None (hardcoded transactions)
```

## 🎨 Visual Element Sizes

```
┌─────────────────────────────────────────────┐
│  Component Size Reference                   │
├─────────────────────────────────────────────┤
│  • Header Buttons: 44×44 pt                 │
│  • Balance Dollar Sign: 32pt                │
│  • Balance Amount: 64pt Serif               │
│  • Balance Cents: 40pt                      │
│  • Remaining Pill: 6pt dot + caption        │
│  • Weekly Card: Full width - 48pt padding   │
│  • Activity Dots: 6×6 pt                    │
│  • Action Buttons: Height 48pt              │
│  • Transaction Icons: 40×40 pt              │
│  • Bottom Bar: Auto height + 24pt padding   │
│  • Center Button: 64×64 pt (90×90 glow)     │
└─────────────────────────────────────────────┘
```

## 🌈 Color Application Map

```
ORANGE ACCENT (#FF6A29) Used In:
  ✓ Center Penny button (main fill + glow)
  ✓ Remaining balance dot
  ✓ Current day label (W)
  ✓ Filled activity dots
  ✓ Impulse transaction amounts
  ✓ Active action button icon (on press)
  ✓ Top gradient glow layer

WHITE WITH OPACITY Used For:
  • 0.9 - Primary text (names, amounts)
  • 0.7 - Secondary text (subtitles)
  • 0.6 - Labels (BALANCE, categories)
  • 0.5 - Tertiary text, inactive tabs
  • 0.3 - Disabled/placeholder
  • 0.1 - Borders, subtle dividers
  • 0.05 - Background tints

BLACK WITH OPACITY Used For:
  • 0.4 - Glass card backgrounds
  • 0.35 - Button backgrounds
  • 0.3 - Lighter overlays
  • 0.8 - Text shadows (depth)
```

## 🔄 State Flow Diagram

```
┌─────────────────────────────────────────────┐
│          State Management Flow              │
└─────────────────────────────────────────────┘

User Taps Tab Button
       ↓
BottomBar receives tap
       ↓
Updates @Binding selectedTab
       ↓
ContentView's @State changes
       ↓
SwiftUI triggers re-render
       ↓
New tab view appears
       ↓
Old tab view disappears

┌─────────────────────────────────────────────┐
│   ContentView                               │
│   @State selectedTab = .spending            │
│             ↕ (Two-way binding)             │
│   BottomBar                                 │
│   @Binding selectedTab                      │
└─────────────────────────────────────────────┘

Local Button State (ActionButtons):
  User Presses → @State isPressed = true
              → Button scales to 0.95
  User Releases → @State isPressed = false
                → Button scales to 1.0
```

## 📱 Screen Regions

```
┌─────────────────────────────────────┐
│  Status Bar (System)                │ ← Safe Area Top
├─────────────────────────────────────┤
│  Header (44pt)                      │
│  [☰]  BALANCE  [👤]                │
├─────────────────────────────────────┤
│                                     │
│  Balance Display                    │
│  $ 124.50                           │
│  DAILY SPENT                        │
│  [•] Remaining                      │
│                                     │
├─────────────────────────────────────┤
│  Weekly Activity Card               │
│  (Fixed height ~180pt)              │
├─────────────────────────────────────┤
│  Action Buttons (48pt)              │
├─────────────────────────────────────┤
│                                     │
│  Transactions                       │
│  (Scrollable)                       │
│                                     │
│  ↕ User can scroll                  │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  Bottom Padding (100pt)             │ ← Space for BottomBar
├─────────────────────────────────────┤
│  Bottom Bar (Overlay)               │
│  [👥] [🛡️] [💬] [😊] [💳]         │ ← Safe Area Bottom
└─────────────────────────────────────┘
```

## 🎭 Animation Timeline

```
Button Press Interaction (300ms):
0ms   ──→  User touches button
           @State isPressed = true
50ms  ──→  Scale animates to 0.95
           Spring animation starts
300ms ──→  Animation complete
           
User Release:
0ms   ──→  User lifts finger
           @State isPressed = false
50ms  ──→  Scale animates back to 1.0
           Spring bounce effect
300ms ──→  Animation complete


Tab Switch (Instant):
0ms   ──→  User taps tab
           selectedTab changes
0ms   ──→  SwiftUI updates view
           (Consider adding .transition(.opacity)
            for smoother effect)
```

## 🏗️ File Creation Order (Recommended)

For new developers building similar apps:

```
1. Create Tab enum (AppTab)
   └─ Defines navigation structure

2. Create BottomBar
   └─ Navigation foundation

3. Create ContentView
   └─ Wires tabs together

4. Create HomeView shell
   └─ Main content container

5. Add child components:
   ├─ WeeklyActivityCard
   ├─ ActionButtonsRow
   └─ TransactionsCard

6. Polish gradients & styling
   └─ Fine-tune appearance
```

---

**💡 Use this diagram as reference when**:
- Adding new components
- Debugging layout issues
- Planning new features
- Explaining architecture to team

