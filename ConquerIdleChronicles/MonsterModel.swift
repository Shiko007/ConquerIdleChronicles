//
//  MonsterModel.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import Foundation
import SpriteKit  // For SKNode integration

/// Model for a monster in the grinding scene.
/// Each monster has health and is tied to a sprite for visuals.
class MonsterModel: NSObject {
    var health: Int = GameConfig.Monster.baseHealth
    let maxHealth: Int = GameConfig.Monster.baseHealth
    var sprite: SKSpriteNode  // Visual representation
    
    init(sprite: SKSpriteNode) {
        self.sprite = sprite
        super.init()
    }
    
    /// Applies damage to monster health.
    /// - Parameter damage: Int amount.
    /// - Returns: True if dead (health <=0).
    func takeDamage(_ damage: Int) -> Bool {
        health -= damage
        if health < 0 { health = 0 }
        return health <= 0
    }
}
