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
            
            // Top left: Player image + Level
            VStack {
                HStack {
                    Image(systemName: "person.circle.fill")  // SF Symbol for player avatar
                        .foregroundColor(.blue)
                        .font(.system(size: 40))  // Larger for visibility
                    Text("Level: \(player.level)")
                        .font(.title)
                        .bold()
                    Spacer()  // Push to left
                }
                .padding()
                
                Spacer()  // Push to top
            }
            
            // Top right: Inventory icon button
            VStack {
                HStack {
                    Spacer()  // Push to right
                    Button(action: {
                        showInventory = true  // Open sheet
                    }) {
                        Image(systemName: "bag.fill")  // SF Symbol for inventory (bag icon)
                            .foregroundColor(.gray)
                            .font(.system(size: 40))  // Match player icon size
                    }
                }
                .padding()
                
                Spacer()  // Push to top
            }
            
            // Bottom: EXP progress bar
            VStack {
                Spacer()  // Push to bottom
                
                VStack(spacing: 5) {
                    ProgressView(value: Float(player.exp), total: Float(player.expNeededForNextLevel()))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(height: 10)  // Thinner bar
                    Text("EXP: \(player.exp) / \(player.expNeededForNextLevel())")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)  // Horizontal padding for bar
                .background(Color.white.opacity(0.8))  // Semi-transparent bg for visibility
            }
        }
        .sheet(isPresented: $showInventory) {  // Modal sheet for inventory
            InventoryView(gold: player.gold)
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
                    getPlayerHealth: { player.health }
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
