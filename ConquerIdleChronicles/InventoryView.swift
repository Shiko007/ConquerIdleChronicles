//
//  InventoryView.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import SwiftUI

/// Separate view for the Inventory menu.
/// This displays gold and can be expanded later for items/gear.
/// Presented as a sheet for modal popup.
struct InventoryView: View {
    let gold: Int  // Passed from parent; read-only for simplicity

    var body: some View {
        VStack(spacing: 20) {
            Text("Inventory")
                .font(.largeTitle)
                .bold()

            HStack {
                Text("\(gold)")  // Just the gold value as text
                    .font(.title)
                Image(systemName: "dollarsign.circle.fill")  // Icon on the right
                    .foregroundColor(.yellow)
                    .font(.largeTitle)
            }

            // TODO: Add more inventory slots/items here later.

            Spacer()  // Pushes content up
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Full screen feel
        .background(Color.gray.opacity(0.2))  // Light background for menu
    }
}

#Preview {
    InventoryView(gold: 100)  // Sample preview
}
