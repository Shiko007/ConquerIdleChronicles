//
//  GameConfig.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import Foundation  // For basic types; no UI here

/// Configuration struct for game tunables.
/// This holds values that can be changed in one place to affect the whole game,
/// like balancing gold rates or EXP curves without hunting through code.
struct GameConfig {
    /// Base EXP required for level 1. Scales exponentially.
    static let baseExpPerLevel: Int = 100
    
    /// Exponent for level difficulty (higher = steeper curve).
    static let expGrowthExponent: Double = 2.0
    
    /// Gold earned per second during idle grinding.
    static let goldPerSecond: Int = 5
    
    /// EXP earned per second during idle grinding.
    static let expPerSecond: Int = 2
    
    /// Player starting health.
    static let playerMaxHealth: Int = 100
    
    /// Default player attack damage (no gear yet).
    static let playerDefaultAttack: Int = 10
    
    /// Monster base health.
    static let monsterBaseHealth: Int = 50
    
    /// Monster attack damage.
    static let monsterAttack: Int = 5
    
    /// Time interval (seconds) between monster spawns.
    static let monsterSpawnInterval: TimeInterval = 3.0
    
    /// Monster movement speed (points per second).
    static let monsterSpeed: CGFloat = 100.0
    
    /// Arrow projectile speed.
    static let arrowSpeed: CGFloat = 300.0
    
    /// Interval (seconds) between player attacks for realistic shooting rate.
    static let playerAttackInterval: TimeInterval = 0.5  // Adjust for bow "draw time"; lower for faster classes/gear.
    
    /// Minimum number of monsters to spawn per interval.
    static let minMonstersPerSpawn: Int = 1
    
    /// Maximum number of monsters to spawn per interval (random between min-max).
    static let maxMonstersPerSpawn: Int = 3  // Increase for harder waves; tie to level later.
    
    /// Distance from player where monsters stop to avoid overlap (pixels; adjust based on sprite sizes).
    static let monsterStopDistance: CGFloat = 40.0  // Slightly beyond health circle radius
    
    /// Interval (seconds) between monster attacks when at stop position.
    static let monsterAttackInterval: TimeInterval = 1.0  // Every second; balance for challenge.
    
    // New configs for rewards
    static let goldPerMonster: Int = 10
    static let expPerMonster: Int = 20
    
    // New config for coin collection
    static let coinCollectSpeed: Double = 1000.0  // Points per second; higher = faster
    
    // New config for auto-collect delay (seconds) if enabled
    static let coinAutoCollectDelay: Double = 2.0  // Tune for visibility vs. speed
    
    // New config for coin lifetime (seconds) before disappearing if not collected
    static let coinLifetime: Double = 5.0
    
    // New config for coin fade start delay (seconds after drop)
    static let coinFadeStartDelay: Double = 2.0  // Starts fading at this time
    
    // New config for coin fade duration (seconds) at end of lifetime
    static let coinFadeDuration: Double = 3.0  // Fades over this duration until disappear at lifetime
}
