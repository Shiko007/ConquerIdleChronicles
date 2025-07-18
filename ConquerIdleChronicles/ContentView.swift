//
//  ContentView.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import SwiftUI
import SpriteKit  // For GrindingScene

/// Main view for the game screen.
/// This composes UI elements, using PlayerModel for data and GameConfig for tunables.
struct ContentView: View {
    @State private var player = PlayerModel()
    @State private var isGrinding: Bool = false
    @State private var showInventory: Bool = false
    @State private var showSettings: Bool = false  // New state for settings sheet
    @State private var grindingScene: GrindingScene?  // Store scene for access and cleanup

    var body: some View {
        ZStack {
            // Grinding scene or start button
            if isGrinding {
                if let scene = grindingScene {
                    SKSceneView(scene: scene)
                        .edgesIgnoringSafeArea(.all)  // Full screen for game scene
                }
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Button("Start Grinding") {
                        isGrinding.toggle()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.headline)
                    
                    Spacer()
                }
                .padding()
            }
            
            if isGrinding {
                // Top left: Player image + Level (visible only during grinding)
                VStack {
                    HStack {
                        Image(systemName: "person.circle.fill")  // SF Symbol for player avatar
                            .foregroundColor(.blue)
                            .font(.system(size: 40))  // Larger for visibility
                        Text("Level: \(player.level)")
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    .padding()
                    
                    Spacer()  // Push to top
                }
                
                // Top right: Settings and Inventory buttons (visible only during grinding)
                VStack {
                    HStack {
                        Spacer()  // Push buttons to the right
                        
                        Button(action: {
                            showSettings = true  // Open settings sheet
                        }) {
                            Image(systemName: "gearshape.fill")  // SF Symbol for settings (gear icon)
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                        }
                        
                        Button(action: {
                            showInventory = true  // Open inventory sheet
                        }) {
                            Image(systemName: "bag.fill")  // SF Symbol for inventory (bag icon)
                                .foregroundColor(.gray)
                                .font(.system(size: 40))  // Match player icon size
                        }
                    }
                    .padding()
                    
                    Spacer()  // Push to top
                }
                
                // Bottom: Health bar (red, with icon on left/values on right) and EXP progress bar (dark yellow, with icon on left/values on right) (visible only during grinding)
                VStack {
                    Spacer()  // Push to bottom
                    
                    VStack(spacing: 5) {
                        // Health row: Icon(left) + Bar(middle) + Values(right)
                        HStack {
                            Image(systemName: "heart.fill")  // SF Symbol for HP
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .frame(width: 50, alignment: .leading)  // Fixed width for symmetry
                            
                            ProgressView(value: Float(player.health), total: Float(player.maxHealth))
                                .progressViewStyle(LinearProgressViewStyle(tint: .red))
                                .frame(height: 10)  // Thinner bar
                            
                            Text("\(player.health) / \(player.maxHealth)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: 100, alignment: .trailing)  // Fixed width for symmetry
                        }
                        
                        // EXP row: Icon(left) + Bar(middle) + Values(right)
                        HStack {
                            Image(systemName: "star.fill")  // SF Symbol for EXP
                                .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.0))  // Dark yellow
                                .font(.subheadline)
                                .frame(width: 50, alignment: .leading)  // Fixed width for symmetry
                            
                            ProgressView(value: Float(player.exp), total: Float(player.expNeededForNextLevel()))
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(red: 0.8, green: 0.6, blue: 0.0)))  // Dark yellow tint
                                .frame(height: 10)  // Thinner bar
                            
                            Text("\(player.exp) / \(player.expNeededForNextLevel())")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(width: 100, alignment: .trailing)  // Fixed width for symmetry
                        }
                    }
                    .padding(.horizontal)  // Horizontal padding for bars
                    .background(Color.white.opacity(0.8))  // Semi-transparent bg for visibility
                }
            }
        }
        .sheet(isPresented: $showInventory) {  // Modal sheet for inventory
            InventoryView(gold: player.gold)
        }
        .sheet(isPresented: $showSettings) {  // New modal sheet for settings
            SettingsView(showGoldLabels: $player.showGoldLabels, showDamageLabels: $player.showDamageLabels, showPlayerDamageLabels: $player.showPlayerDamageLabels)
        }
        .onChange(of: isGrinding) { oldValue, newValue in
            if newValue {
                // Create and set up scene when starting
                grindingScene = GrindingScene(
                    size: UIScreen.main.bounds.size,
                    onAddGold: { amount in player.addGold(amount) },
                    onAddExp: { amount in player.addExp(amount) },
                    onTakeDamage: { damage in
                        let isDead = player.takeDamage(damage)
                        if isDead {
                            isGrinding = false  // Auto-stop if dead
                        }
                        return isDead
                    },
                    getPlayerAttack: { player.attack },
                    getPlayerHealth: { player.health },
                    getAutoCollectEnabled: { player.autoCollectEnabled },
                    getShowGoldLabels: { player.showGoldLabels },
                    getShowDamageLabels: { player.showDamageLabels },
                    getShowPlayerDamageLabels: { player.showPlayerDamageLabels }
                )
            } else {
                // Cleanup when stopping
                grindingScene?.stopScene()
                grindingScene = nil  // Release memory
                player.resetHealth()  // Reset health for next grind session
            }
        }
    }
}

#Preview {
    ContentView()
}
