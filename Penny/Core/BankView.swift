import SwiftUI

struct BankView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            Text("Bank")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    BankView()
}
