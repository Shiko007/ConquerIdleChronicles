//
//  GrindingScene.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import SpriteKit
import UIKit  // For UIBezierPath; images now from Assets.

/// SpriteKit scene for the grinding view.
/// Handles monster spawning, movement, attacks, and health updates.
/// Runs auto (idle-style) when presented.
///
/// This file contains the core class definition and init; functionalities are extended in separate files for clean code (SRP).
class GrindingScene: SKScene {
    // Closures for communicating with SwiftUI (avoids weak ref issues with structs)
    let onAddGold: (Int) -> Void
    let onAddExp: (Int) -> Void
    let onTakeDamage: (Int) -> Bool  // Returns true if player dead
    let getPlayerAttack: () -> Int
    let getPlayerHealth: () -> Int
    let getAutoCollectEnabled: () -> Bool  // Flag for auto-collect
    let getShowGoldLabels: () -> Bool  // New: Flag for gold labels
    let getShowDamageLabels: () -> Bool  // New: Flag for damage labels
    
    let playerSprite: SKSpriteNode
    var monsters: [MonsterModel] = []  // Active monsters
    var spawnTimer: Timer?  // For periodic spawning
    var lastAttackTime: TimeInterval = 0  // Tracks time of last arrow shot for cooldown
    var arrows: [SKShapeNode] = []  // Track active arrows for hit checks
    
    init(size: CGSize, onAddGold: @escaping (Int) -> Void, onAddExp: @escaping (Int) -> Void, onTakeDamage: @escaping (Int) -> Bool, getPlayerAttack: @escaping () -> Int, getPlayerHealth: @escaping () -> Int, getAutoCollectEnabled: @escaping () -> Bool, getShowGoldLabels: @escaping () -> Bool, getShowDamageLabels: @escaping () -> Bool) {
        self.onAddGold = onAddGold
        self.onAddExp = onAddExp
        self.onTakeDamage = onTakeDamage
        self.getPlayerAttack = getPlayerAttack
        self.getPlayerHealth = getPlayerHealth
        self.getAutoCollectEnabled = getAutoCollectEnabled
        self.getShowGoldLabels = getShowGoldLabels
        self.getShowDamageLabels = getShowDamageLabels
        
        // Player sprite: Use centralized asset
        playerSprite = SKSpriteNode(texture: SKTexture(image: Assets.playerImage))
        playerSprite.size = CGSize(width: 50, height: 50)
        playerSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)  // Center
        
        super.init(size: size)
        addChild(playerSprite)
        
        startSpawning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
