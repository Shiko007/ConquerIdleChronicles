//
//  SettingsView.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25. (Updated for toggles on July 16, 2025.)

import SwiftUI

/// Separate view for the Settings menu.
/// Displays toggle switches for visual preferences (e.g., labels).
/// Presented as a sheet for modal popup.
struct SettingsView: View {
    @Binding var showGoldLabels: Bool  // Binding to PlayerModel flag
    @Binding var showDamageLabels: Bool  // Binding to PlayerModel flag

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .bold()

            Toggle("Show Gold Labels", isOn: $showGoldLabels)
                .padding()
                .font(.headline)

            Toggle("Show Damage Labels", isOn: $showDamageLabels)
                .padding()
                .font(.headline)

            // TODO: Add more settings toggles here later (e.g., sound, auto-save).

            Spacer()  // Pushes content up
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Full screen feel
        .background(Color.gray.opacity(0.2))  // Light background for menu
    }
}

#Preview {
    SettingsView(showGoldLabels: .constant(true), showDamageLabels: .constant(true))  // Sample preview
}
