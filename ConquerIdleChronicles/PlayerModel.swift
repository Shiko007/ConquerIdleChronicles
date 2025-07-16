//
//  PlayerModel.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import Foundation

/// Model representing the player's stats and progression.
/// This separates data from UI, making it reusable (e.g., for saving/loading later).
struct PlayerModel {
    var gold: Int = 0
    var exp: Int = 0
    var level: Int = 1
    var health: Int = GameConfig.Player.maxHealth  // Current health
    var maxHealth: Int = GameConfig.Player.maxHealth  // Max for resets
    var attack: Int = GameConfig.Player.defaultAttack  // Default attack (gear will modify later)
    var autoCollectEnabled: Bool = false  // Flag for auto-collect feature; default false, purchasable later
    var showGoldLabels: Bool = true  // Toggle for gold "+value" labels; default true
    var showDamageLabels: Bool = true  // Toggle for damage "-damage" labels on monsters; default true
    var showPlayerDamageLabels: Bool = true  // New toggle for damage on player head; default true
    
    /// Calculates EXP needed for the next level using exponential formula.
    /// - Returns: Int value for required EXP.
    func expNeededForNextLevel() -> Int {
        // Uses config for easy tuning; pow() for exponential growth.
        Int(pow(Double(level), GameConfig.expGrowthExponent) * Double(GameConfig.baseExpPerLevel))
    }
    
    /// Mutates the player by adding EXP and handling level-ups.
    /// - Parameter addedExp: Amount of EXP to add.
    mutating func addExp(_ addedExp: Int) {
        exp += addedExp
        // Check for level-up; loop in case multiple levels at once (rare but possible).
        while exp >= expNeededForNextLevel() {
            exp -= expNeededForNextLevel()
            level += 1
            // TODO: Add bonuses here later, like unlocking skills.
        }
    }
    
    /// Adds gold to the player.
    /// - Parameter addedGold: Int amount to add.
    mutating func addGold(_ addedGold: Int) {
        gold += addedGold
    }
    
    /// Applies damage to player health.
    /// - Parameter damage: Int amount to subtract.
    /// - Returns: True if health <=0 (game over condition).
    mutating func takeDamage(_ damage: Int) -> Bool {
        health -= damage
        if health < 0 { health = 0 }
        return health <= 0
    }
    
    /// Resets health to max (e.g., on level up or stop grinding).
    mutating func resetHealth() {
        health = maxHealth
    }
}
