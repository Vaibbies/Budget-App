import SwiftUI

// MARK: - Settle Up Modal
struct SettleUpModal: View {
    @Binding var isPresented: Bool
    
    let requests: [PendingRequest] = FriendsData.pendingRequests
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Settle Up")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Choose a friend to settle expenses with")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        
                        VStack(spacing: 12) {
                            ForEach(requests) { request in
                                Button(action: {}) {
                                    HStack {
                                        HStack(spacing: 12) {
                                            AvatarView(seed: request.seed, size: 40, hasGradient: false)
                                            Text(request.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("$\(String(format: "%.2f", abs(request.amount)))")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white.opacity(0.05))
                                    )
                                }
                            }
                        }
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1.0, green: 0.55, blue: 0.36),
                                                    Color(red: 1.0, green: 0.42, blue: 0.16)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.95))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Add Friend Modal
struct AddFriendModal: View {
    @Binding var isPresented: Bool
    @State private var emailText = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack {
                Spacer()
                
                VStack(spacing: 0) {
                    // Drag indicator
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 48, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Add Friend")
                            .font(.system(size: 20, weight: .semibold))
                        
                        TextField("Email or username", text: $emailText)
                            .foregroundColor(.white)
                            .padding()
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.05))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Send Request")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 1.0, green: 0.55, blue: 0.36),
                                                    Color(red: 1.0, green: 0.42, blue: 0.16)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }
                    .padding(24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.95))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Menu Modal
struct MenuModal: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Menu")
                    .font(.system(size: 18, weight: .semibold))
                
                VStack(spacing: 8) {
                    MenuButton(title: "Settings", action: {})
                    MenuButton(title: "Profile", action: {})
                    MenuButton(title: "Help", action: {})
                    MenuButton(title: "Logout", action: {}, isDestructive: true)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.07, green: 0.07, blue: 0.09).opacity(0.95))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .frame(width: 256)
            .padding(24)
        }
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(isDestructive ? .red.opacity(0.8) : .white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.0))
                )
        }
    }
}
