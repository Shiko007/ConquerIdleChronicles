//
//  GameConfig.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import Foundation

/// Centralized configuration for game tunables.
/// Organized into nested structs for better readability and grouping (e.g., Player, Monster).
/// All values are static for easy access without instantiation.
/// This keeps balancing in one place, avoiding scattered constants.
struct GameConfig {
    // MARK: - Progression
    /// Base EXP required for level 1. Scales exponentially.
    static let baseExpPerLevel: Int = 100
    
    /// Exponent for level difficulty (higher = steeper curve).
    static let expGrowthExponent: Double = 2.0
    
    // MARK: - Player
    struct Player {
        /// Starting and maximum health.
        static let maxHealth: Int = 100
        
        /// Default attack damage (modifiable by gear/upgrades).
        static let defaultAttack: Int = 10
        
        /// Interval (seconds) between attacks.
        static let attackInterval: TimeInterval = 0.5  // Adjust for balance; lower for faster attacks.
    }
    
    // MARK: - Monster
    struct Monster {
        /// Base health for monsters.
        static let baseHealth: Int = 50
        
        /// Attack damage dealt to player.
        static let attack: Int = 5
        
        /// Time interval (seconds) between monster attacks.
        static let attackInterval: TimeInterval = 1.0
        
        /// Time interval (seconds) between spawn waves.
        static let spawnInterval: TimeInterval = 3.0
        
        /// Minimum number of monsters per spawn wave.
        static let minPerSpawn: Int = 1
        
        /// Maximum number of monsters per spawn wave (random between min-max).
        static let maxPerSpawn: Int = 3  // Increase for harder waves; tie to level later.
        
        /// Movement speed (points per second).
        static let speed: CGFloat = 100.0
        
        /// Distance from player where monsters stop to avoid overlap.
        static let stopDistance: CGFloat = 40.0  // Slightly beyond player health circle radius (30).
    }
    
    // MARK: - Projectiles
    /// Arrow projectile speed (points per second).
    static let arrowSpeed: CGFloat = 300.0
    
    // MARK: - Rewards
    /// Gold dropped per monster.
    static let goldPerMonster: Int = 10
    
    /// EXP gained per monster.
    static let expPerMonster: Int = 20
    
    // MARK: - Coin Mechanics
    /// Speed at which coins move to player during collection (points per second).
    static let coinCollectSpeed: Double = 1000.0  // Higher = faster.
    
    /// Lifetime (seconds) before coin disappears if not collected.
    static let coinLifetime: Double = 5.0
    
    /// Delay (seconds) after drop before fade starts.
    static let coinFadeStartDelay: Double = 2.0
    
    /// Duration (seconds) of fade until disappear.
    static let coinFadeDuration: Double = 3.0
}
