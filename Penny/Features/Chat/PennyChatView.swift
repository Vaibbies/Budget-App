import SwiftUI

// MARK: - Main Chat View
struct PennyChatView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Int
    @Binding var showChat: Bool
    
    @State private var messages: [ChatMessage] = [
        ChatMessage(
            type: .ai,
            content: "Hey! I noticed you spent $59.99 at the Steam Store today.\n\nThat brings your weekly entertainment total to $84.50. You're currently $15 under budget for the month!"
        ),
        ChatMessage(
            type: .user,
            content: "Nice! Can I afford to go out for dinner tonight?"
        ),
        ChatMessage(
            type: .ai,
            content: "Based on your $45.50 remaining daily limit, you've got room for a nice meal! 🍽️",
            showTip: true
        )
    ]
    
    @State private var inputText = ""
    @State private var isTyping = true
    
    var body: some View {
        ZStack {
            // Background
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.04, blue: 0.05),
                        Color(red: 0.04, green: 0.04, blue: 0.04),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                RadialGradient(
                    colors: [
                        Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.45),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.25),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.05),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: -0.3),
                    startRadius: 50,
                    endRadius: 400
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ChatHeader(dismiss: dismiss)
                
                // Messages
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(messages.indices, id: \.self) { index in
                            if messages[index].type == .ai {
                                HStack(alignment: .top, spacing: 12) {
                                    PennyAvatar()
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        ChatBubbleAI(content: messages[index].content)
                                        
                                        if messages[index].showTip {
                                            SpendingTipCard()
                                        }
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                HStack {
                                    Spacer()
                                    ChatBubbleUser(content: messages[index].content)
                                }
                            }
                        }
                        
                        // Typing indicator
                        if isTyping {
                            HStack(alignment: .top, spacing: 12) {
                                PennyAvatar()
                                ChatBubbleAI(content: "", isTyping: true)
                            }
                        }
                        
                        // Bottom padding for bottom bar clearance
                        Color.clear
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)
                
                // Input area
                VStack(spacing: 16) {
                    // Suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            SuggestionButton(text: "Analyze coffee habit") {
                                inputText = "Analyze coffee habit"
                            }
                            SuggestionButton(text: "Set new goal") {
                                inputText = "Set new goal"
                            }
                            SuggestionButton(text: "Budget summary") {
                                inputText = "Budget summary"
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Input field
                    HStack {
                        TextField("Ask Penny anything...", text: $inputText)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .overlay(
                                HStack {
                                    Spacer()
                                    Button(action: sendMessage) {
                                        Image(systemName: "paperplane.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 18))
                                            .frame(width: 40, height: 40)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color(red: 1.0, green: 0.42, blue: 0.16))
                                                    .shadow(color: Color.orange.opacity(0.3), radius: 8)
                                            )
                                    }
                                    .padding(.trailing, 8)
                                }
                            )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 100)
            }
            
            // Fixed bottom bar overlay
            VStack {
                Spacer()
                BottomBarMock(selectedTab: $selectedTab, showChat: $showChat)
            }
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: selectedTab) { oldValue, newValue in
                // Close chat when user switches tabs
                if oldValue != newValue {
                    showChat = false
                }
            }
        }
    }
    
    func sendMessage() {
        if !inputText.isEmpty {
            messages.append(ChatMessage(type: .user, content: inputText))
            inputText = ""
            isTyping = true
        }
    }
}

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

// MARK: - Chat Bubbles
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
        
        // Highlight dollar amounts in orange
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
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8, alignment: .trailing)
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

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let type: MessageType
    let content: String
    var showTip: Bool = false
    
    enum MessageType {
        case ai
        case user
    }
}

#Preview {
    PennyChatView(selectedTab: .constant(1), showChat: .constant(true))
}
