# SwiftUI Component Quick Reference

## 🎯 When to Use What

### Custom Navigation vs TabView

**Use Custom Navigation (Current Approach) When:**
- ✅ Need elevated/special center button
- ✅ Want full control over styling
- ✅ Custom animations between tabs
- ✅ Non-standard tab bar design

**Use TabView When:**
- Standard iOS tab bar is sufficient
- Want automatic state restoration
- Need built-in tab bar badges
- Standard positioning is acceptable

---

## 🎨 Glass Morphism Pattern

### Standard Card Style
```swift
RoundedRectangle(cornerRadius: 22)
    .fill(Color.black.opacity(0.4))
    .backdrop(Material.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 22))
    .overlay(
        RoundedRectangle(cornerRadius: 22)
            .stroke(Color.white.opacity(0.06), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
```

**Opacity Guidelines:**
- Cards: 0.3 - 0.5
- Overlays: 0.05 - 0.1
- Borders: 0.06 - 0.1
- Text: 0.5 - 1.0

---

## 🌈 Gradient Patterns

### Linear Gradient (Simple)
```swift
LinearGradient(
    colors: [topColor, bottomColor],
    startPoint: .top,
    endPoint: .bottom
)
```

### Radial Gradient (Spotlight Effect)
```swift
RadialGradient(
    colors: [
        centerColor.opacity(0.95),
        centerColor.opacity(0.5),
        Color.clear
    ],
    center: UnitPoint(x: 0.5, y: 0.5),
    startRadius: 10,
    endRadius: 300
)
```

**UnitPoint Reference:**
- (0.0, 0.0) = Top Left
- (0.5, 0.5) = Center
- (1.0, 1.0) = Bottom Right
- (0.5, -0.15) = Above screen (for top glow)
- (0.82, 0.82) = Bottom-right accent

---

## 🔘 Button Patterns

### Icon Button with Glass Effect
```swift
Button {
    // action
} label: {
    ZStack {
        Circle()
            .fill(Color.black.opacity(0.4))
            .backdrop(Material.ultraThinMaterial)
            .clipShape(Circle())
        
        Image(systemName: "icon.name")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(.white)
    }
    .frame(width: 44, height: 44)
}
```

### Elevated Glow Button
```swift
ZStack {
    // Outer glow
    Circle()
        .fill(
            RadialGradient(
                colors: [orange.opacity(0.5), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 45
            )
        )
        .blur(radius: 15)
    
    // Main button
    Circle()
        .fill(orangeGradient)
        .shadow(color: orange.opacity(0.5), radius: 12)
    
    // Icon
    Image(systemName: "icon")
        .foregroundColor(.white)
}
.offset(y: -30) // Elevate
```

### Press Animation
```swift
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), 
                      value: configuration.isPressed)
    }
}

// Usage
Button { } label: { }
    .buttonStyle(ScaleButtonStyle())
```

---

## 📝 Typography

### Balance Display (Large Serif)
```swift
Text("124")
    .font(.system(size: 64, weight: .light, design: .serif))
    .foregroundColor(.white)
    .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 10)
```

### Section Headers (Small Caps)
```swift
Text("BALANCE")
    .font(.caption2)
    .tracking(3) // Letter spacing
    .foregroundColor(.white.opacity(0.5))
```

### Body Text
```swift
Text("Transaction Name")
    .font(.system(size: 14, weight: .medium))
    .foregroundColor(.white.opacity(0.9))
```

---

## 🎭 Common SF Symbols

**Navigation:**
- `line.3.horizontal` - Menu (hamburger)
- `person.circle.fill` - Profile
- `chevron.left` - Back button
- `xmark` - Close

**Actions:**
- `plus` - Add
- `viewfinder` - Scan
- `target` - Goals
- `chart.line.uptrend.xyaxis` - Analytics
- `bubble.left.and.bubble.right.fill` - Chat

**Finance:**
- `dollarsign.circle` - Money
- `creditcard` - Card
- `banknote` - Cash
- `chart.pie` - Budget

**Status:**
- `checkmark.circle` - Success
- `exclamationmark.triangle` - Warning
- `info.circle` - Info

---

## 🔄 State Management Patterns

### Local UI State
```swift
struct MyView: View {
    @State private var isPressed = false
    @State private var selectedIndex = 0
    
    var body: some View {
        // Use @State for local UI state
    }
}
```

### Shared State (Binding)
```swift
// Parent
struct Parent: View {
    @State private var selectedTab: AppTab = .spending
    
    var body: some View {
        ChildView(selectedTab: $selectedTab)
    }
}

// Child
struct ChildView: View {
    @Binding var selectedTab: AppTab
    
    var body: some View {
        // Can read AND write selectedTab
    }
}
```

### Observable Object (Advanced)
```swift
class TransactionStore: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    func addTransaction(_ t: Transaction) {
        transactions.append(t)
    }
}

struct MyView: View {
    @StateObject private var store = TransactionStore()
    // or
    @ObservedObject var store: TransactionStore
}
```

---

## 📱 Layout Patterns

### ZStack (Layering)
```swift
ZStack {
    BackgroundView()    // Layer 1 (bottom)
    ContentView()       // Layer 2
    OverlayView()       // Layer 3 (top)
}
```

### VStack (Vertical)
```swift
VStack(alignment: .leading, spacing: 16) {
    Header()
    Content()
    Footer()
}
.padding()
```

### HStack (Horizontal)
```swift
HStack(spacing: 12) {
    Icon()
    Text("Label")
    Spacer()
    Value()
}
```

### ScrollView with Padding
```swift
ScrollView(showsIndicators: false) {
    VStack(spacing: 16) {
        ForEach(items) { item in
            ItemRow(item)
        }
    }
}
.padding(.bottom, 100) // Space for bottom bar
```

---

## 🎨 Material Blur Effects

```swift
// Ultra thin (most transparent)
.backdrop(Material.ultraThin)

// Thin
.backdrop(Material.thin)

// Regular
.backdrop(Material.regular)

// Thick
.backdrop(Material.thick)

// Ultra thick (most opaque)
.backdrop(Material.ultraThick)
```

**For Penny App**: Use `.ultraThinMaterial` for frosted glass

---

## 🔍 Common Modifiers

### Frames
```swift
.frame(width: 100, height: 50)
.frame(maxWidth: .infinity)
.frame(maxWidth: .infinity, maxHeight: .infinity)
```

### Padding
```swift
.padding()                    // All sides, default 16
.padding(.horizontal, 24)     // Left + right
.padding(.vertical, 16)       // Top + bottom
.padding(.top, 8)             // Specific side
```

### Styling
```swift
.foregroundColor(.white)
.background(Color.black)
.clipShape(RoundedRectangle(cornerRadius: 12))
.overlay(border)
.shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
```

### Safe Areas
```swift
.ignoresSafeArea()                    // All edges
.ignoresSafeArea(.keyboard)           // Only keyboard
.ignoresSafeArea(edges: .bottom)      // Specific edge
```

---

## ⚡ Performance Tips

### LazyVStack for Long Lists
```swift
ScrollView {
    LazyVStack(spacing: 16) {
        ForEach(items) { item in
            ItemView(item)
        }
    }
}
```
**When to use**: Lists with 20+ items

### Avoid Heavy Gradients in Cells
❌ Don't put multi-layer radial gradients in list cells
✅ Use simple fills or linear gradients

### Minimize Blur Radius
```swift
// Heavy
.blur(radius: 50)

// Lighter
.blur(radius: 15)
```

---

## 🧪 Preview Patterns

### Basic Preview
```swift
#Preview {
    MyView()
}
```

### Preview with Dark Background
```swift
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        MyView()
    }
}
```

### Preview with Bindings
```swift
#Preview {
    struct PreviewWrapper: View {
        @State private var value = false
        
        var body: some View {
            MyView(isOn: $value)
        }
    }
    
    return PreviewWrapper()
}
```

---

## 🎯 Quick Fixes

### Center Content
```swift
VStack {
    Spacer()
    Content()
    Spacer()
}
```

### Equal Width Buttons
```swift
HStack {
    Button { } label: { Text("A") }
        .frame(maxWidth: .infinity)
    Button { } label: { Text("B") }
        .frame(maxWidth: .infinity)
}
```

### Overlay at Bottom
```swift
ZStack {
    MainContent()
    
    VStack {
        Spacer()
        BottomOverlay()
    }
}
```

---

**💡 Pro Tip**: Keep this file open while coding for quick reference!

