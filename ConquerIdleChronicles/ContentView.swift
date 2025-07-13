//
//  ContentView.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import SwiftUI

struct ContentView: View {
    @State private var gold: Int = 0  // This is a variable that tracks gold; starts at 0

    var body: some View {
        VStack {  // VStack stacks elements vertically
            Text("Gold Earned: \(gold)")  // Displays current gold
                .font(.largeTitle)  // Makes text bigger
                .padding()  // Adds space around it

            Button("Start Grinding") {  // A button that runs code when tapped
                gold += 10  // Add 10 gold each tap (simulate grinding)
            }
            .padding()  // Space around button
            .background(Color.blue)  // Blue background
            .foregroundColor(.white)  // White text
            .cornerRadius(10)  // Rounded corners
        }
        .padding()  // Overall padding for the screen
    }
}

#Preview {
    ContentView()  // Shows preview in Xcode
}
