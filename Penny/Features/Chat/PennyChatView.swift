import SwiftUI

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
                        
                        if isTyping {
                            HStack(alignment: .top, spacing: 12) {
                                PennyAvatar()
                                ChatBubbleAI(content: "", isTyping: true)
                            }
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)
                
                // Input area
                VStack(spacing: 16) {
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
            
            VStack {
                Spacer()
                TabBarView(selectedTab: $selectedTab, showChat: $showChat)
            }
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: selectedTab) { oldValue, newValue in
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

#Preview {
    PennyChatView(selectedTab: .constant(1), showChat: .constant(true))
}
