import SwiftUI

// MARK: - Header
struct TransactionDetailHeader: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
            }
            
            Spacer()
            
            Text("TRANSACTION DETAIL")
                .font(.system(size: 10, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.5))
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "pencil")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                            .overlay(
                                Circle()
                   q                 .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }
}

// MARK: - Transaction Info Section
struct TransactionInfoSection: View {
    var body: some View {
        VStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.45), radius: 15, x: 0, y: 5)
                
                Text("🎮")
                    .font(.system(size: 30))
            }
            
            // Title
            Text("Steam Store")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
            
            Text("GAMES & ENTERTAINMENT")
                .font(.system(size: 11, weight: .medium))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
            
            // Amount
            HStack(alignment: .top, spacing: 2) {
                Text("-$")
                    .font(.system(size: 24, weight: .light))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.6))
                    .offset(y: 12)
                
                Text("59")
                    .font(.system(size: 52, weight: .light, design: .serif))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                
                Text(".99")
                    .font(.system(size: 30, weight: .light, design: .serif))
                    .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.6))
                    .offset(y: 16)
            }
            .shadow(color: .black.opacity(0.8), radius: 17, x: 0, y: 5)
            
            // Date
            Text("Nov 22, 2023 • 9:41 PM")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.3))
        }
    }
}

// MARK: - Impulse & Tags Card
struct ImpulseTagsCard: View {
    @Binding var isImpulse: Bool
    @Binding var tags: [String]
    let onAddTag: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Impulse Toggle
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Impulse Purchase")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Affects your daily vibe score")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Spacer()
                
                Toggle("", isOn: $isImpulse)
                    .labelsHidden()
                    .tint(Color(red: 1.0, green: 0.42, blue: 0.16))
            }
            
            Divider()
                .background(Color.white.opacity(0.05))
            
            // Tags
            VStack(alignment: .leading, spacing: 12) {
                Text("TAGS")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.3))
                
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagView(text: tag)
                    }
                    
                    Button(action: onAddTag) {
                        TagView(text: "+ Add", isDashed: true)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.45), radius: 15, x: 0, y: 5)
        )
    }
}

// MARK: - Tag View
struct TagView: View {
    let text: String
    var isDashed: Bool = false
    
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .tracking(0.5)
            .foregroundColor(isDashed ? .white.opacity(0.2) : .white.opacity(0.5))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(isDashed ? 0.2 : 0.06), lineWidth: 1)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: isDashed ? [4, 4] : []))
                    )
            )
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Digital Receipt Section
struct DigitalReceiptSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("DIGITAL RECEIPT")
                    .font(.system(size: 10, weight: .semibold))
                    .tracking(2)
                    .foregroundColor(.white.opacity(0.3))
                
                Spacer()
                
                Button(action: {}) {
                    Text("Download PDF")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.42, blue: 0.16))
                }
            }
            .padding(.horizontal, 4)
            
            ReceiptPaper()
        }
    }
}

// MARK: - Receipt Paper
struct ReceiptPaper: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                // Receipt content
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 4) {
                        Text("STEAM® POWERED")
                            .font(.system(size: 14, weight: .bold))
                            .tracking(-0.5)
                        
                        Text("Valve Corporation • Bellevue, WA")
                            .font(.system(size: 9))
                            .opacity(0.6)
                    }
                    
                    // Items
                    VStack(spacing: 8) {
                        HStack {
                            Text("Elden Ring: Shadow of the Erdtree")
                                .font(.system(size: 11))
                            Spacer()
                            Text("$39.99")
                                .font(.system(size: 11, weight: .bold))
                        }
                        
                        HStack {
                            Text("Steam Deck Docking Station")
                                .font(.system(size: 11))
                            Spacer()
                            Text("$15.00")
                                .font(.system(size: 11, weight: .bold))
                        }
                        
                        Divider()
                            .background(Color.black.opacity(0.1))
                            .padding(.vertical, 8)
                        
                        HStack {
                            Text("Subtotal")
                                .font(.system(size: 11))
                                .opacity(0.6)
                            Spacer()
                            Text("$54.99")
                                .font(.system(size: 11))
                                .opacity(0.6)
                        }
                        
                        HStack {
                            Text("Tax (9.1%)")
                                .font(.system(size: 11))
                                .opacity(0.6)
                            Spacer()
                            Text("$5.00")
                                .font(.system(size: 11))
                                .opacity(0.6)
                        }
                        
                        Rectangle()
                            .fill(Color.black.opacity(0.1))
                            .frame(height: 1)
                            .overlay(
                                GeometryReader { geometry in
                                    Path { path in
                                        let dashWidth: CGFloat = 4
                                        let dashSpacing: CGFloat = 4
                                        var x: CGFloat = 0
                                        while x < geometry.size.width {
                                            path.move(to: CGPoint(x: x, y: 0))
                                            path.addLine(to: CGPoint(x: x + dashWidth, y: 0))
                                            x += dashWidth + dashSpacing
                                        }
                                    }
                                    .stroke(Color.black.opacity(0.3), lineWidth: 1)
                                }
                            )
                            .padding(.vertical, 8)
                        
                        HStack {
                            Text("TOTAL")
                                .font(.system(size: 13, weight: .black))
                            Spacer()
                            Text("$59.99")
                                .font(.system(size: 13, weight: .black))
                        }
                    }
                    
                    // Barcode
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    stops: [
                                        .init(color: .black, location: 0),
                                        .init(color: .black, location: 0.5),
                                        .init(color: .clear, location: 0.5),
                                        .init(color: .clear, location: 1)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 32)
                            .opacity(0.4)
                        
                        Text("TXN-ID: 8829-441-VALVE")
                            .font(.system(size: 8))
                            .opacity(0.4)
                    }
                }
                .padding(24)
                .foregroundColor(.black)
                .background(Color.white)
            }
            .cornerRadius(8)
            
            // Perforated edge
            HStack(spacing: 10) {
                ForEach(0..<15, id: \.self) { _ in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
            .offset(y: -4)
        }
        .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 2)
        .padding(.horizontal, 8)
    }
}

// MARK: - Action Buttons Section
struct ActionButtonsSection: View {
    var body: some View {
        HStack(spacing: 12) {
            ActionButton(icon: "flag", title: "Flag Activity", action: {})
            ActionButton(icon: "square.and.arrow.up", title: "Share Split", action: {})
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.45), radius: 15, x: 0, y: 5)
            )
        }
    }
}
