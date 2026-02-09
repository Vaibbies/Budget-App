import SwiftUI

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isImpulsePurchase = true
    @State private var tags = ["#gaming", "#weekend", "#unplanned"]
    @State private var showAddTag = false
    @State private var newTag = ""
    
    var body: some View {
        ZStack {
            // Background gradient
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
                        Color(red: 1.0, green: 0.53, blue: 0.25).opacity(0.95),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.75),
                        Color(red: 1.0, green: 0.38, blue: 0.13).opacity(0.1),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.5, y: -0.3),
                    startRadius: 50,
                    endRadius: 420
                )
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                TransactionDetailHeader()
                
                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Transaction Info
                        TransactionInfoSection()
                        
                        // Impulse & Tags Card
                        ImpulseTagsCard(
                            isImpulse: $isImpulsePurchase,
                            tags: $tags,
                            onAddTag: { showAddTag = true }
                        )
                        
                        // Digital Receipt
                        DigitalReceiptSection()
                        
                        // Action Buttons
                        ActionButtonsSection()
                        
                        // Bottom padding
                        Color.clear.frame(height: 120)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                }
            }
            
            // Close Button Footer
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close Details")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                Capsule()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                            )
                    }
                    .padding(.horizontal, 30)
                    
                    // Home indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 36, height: 4)
                }
                .padding(.bottom, 24)
                .background(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(red: 0.04, green: 0.04, blue: 0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                )
            }
            .ignoresSafeArea(edges: .bottom)
            
            // Add Tag Alert
            if showAddTag {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showAddTag = false
                    }
                
                VStack(spacing: 16) {
                    Text("Add Tag")
                        .font(.system(size: 18, weight: .semibold))
                    
                    TextField("Enter tag (without #)", text: $newTag)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack(spacing: 12) {
                        Button("Cancel") {
                            showAddTag = false
                            newTag = ""
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button("Add") {
                            if !newTag.isEmpty {
                                tags.append("#\(newTag.replacingOccurrences(of: "#", with: ""))")
                            }
                            showAddTag = false
                            newTag = ""
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(16)
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    TransactionDetailView()
}
