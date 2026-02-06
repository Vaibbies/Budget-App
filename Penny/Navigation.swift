import SwiftUI

struct HeaderOverlay: View {
    var body: some View {
        VStack {
            HStack {
                CircleButton(icon: "line.3.horizontal")
                Spacer()
                CircleButton(icon: "person.fill")
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct CircleButton: View {
    let icon: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: 44, height: 44)

            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
        }
    }
}
