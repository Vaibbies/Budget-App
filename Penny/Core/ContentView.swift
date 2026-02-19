import SwiftUI

struct ContentView: View {
    var body: some View {
<<<<<<< Updated upstream:Penny/Core/ContentView.swift
        MainAppView()
=======
        ZStack {
            Color.red.ignoresSafeArea()
            Text("HELLO PENNY")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
>>>>>>> Stashed changes:Penny/ContentView.swift
    }
}

#Preview {
    ContentView()
}

 
