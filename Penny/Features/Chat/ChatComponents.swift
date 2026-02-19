import SwiftUI

// MARK: - Header
struct ChatHeader: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 20))
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .shadow(color: .green, radius: 4)
                    
                    Text("PENNY AI")
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Text("Always thinking about your money")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 20))
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 56)
        .padding(.bottom, 16)
    }
}

// MARK: - Penny Avatar
struct PennyAvatar: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            
            Image(systemName: "briefcase.fill")
                .foregroundColor(.white)
                .font(.system(size: 14))
        }
    }
}

// MARK: - AI Chat Bubble
struct ChatBubbleAI: View {
    let content: String
    var isTyping: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            
            if isTyping {
                TypingIndicator()
                    .padding()
            } else {
                Text(attributedContent)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    var attributedContent: AttributedString {
        var attributed = AttributedString(content)
        
        if let range = attributed.range(of: "$59.99") {
            attributed[range].foregroundColor = Color(red: 1.0, green: 0.42, blue: 0.16)
            attributed[range].font = .system(size: 14, weight: .semibold)
        }
        if let range = attributed.range(of: "$84.50") {
            attributed[range].font = .system(size: 14, weight: .semibold)
        }
        if let range = attributed.range(of: "$15 under budget") {
            attributed[range].foregroundColor = Color.green
        }
        if let range = attributed.range(of: "$45.50 remaining") {
            attributed[range].foregroundColor = .white.opacity(0.6)
        }
        
        return attributed
    }
}

// MARK: - User Chat Bubble
struct ChatBubbleUser: View {
    let content: String
    
    var body: some View {
        Text(content)
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.9))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.2),
                                Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 1.0, green: 0.42, blue: 0.16).opacity(0.2), lineWidth: 1)
                    )
            )
            .containerRelativeFrame(.horizontal) { width, _ in
                width * 0.8
            }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color.gray)
                .frame(width: 4, height: 4)
                .opacity(animationAmount == 0 ? 0.2 : 1.0)
            
            Circle()
                .fill(Color.gray)
                .frame(width: 4, height: 4)
                .opacity(animationAmount == 1 ? 0.2 : 1.0)
            
            Circle()
                .fill(Color.gray)
                .frame(width: 4, height: 4)
                .opacity(animationAmount == 2 ? 0.2 : 1.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.4).repeatForever()) {
                animationAmount = 2
            }
        }
    }
}

// MARK: - Spending Tip Card
struct SpendingTipCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SPENDING TIP")
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundColor(.white.opacity(0.4))
            
            HStack(alignment: .top, spacing: 12) {
                Text("💡")
                    .font(.system(size: 20))
                
                Text("If you keep dinner under **$35**, you'll stay on track to hit your $500 savings goal by Friday.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.7))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Suggestion Button
struct SuggestionButton: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
        }
    }
}
