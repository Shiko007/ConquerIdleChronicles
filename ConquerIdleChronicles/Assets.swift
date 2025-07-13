//
//  Assets.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import UIKit  // For UIImage; used in SpriteKit for textures.

/// Centralized configuration for game assets (images, textures).
/// Currently uses SF Symbols as placeholders; easy to replace with custom UIImage(named: "assetName") later.
/// All assets return UIImage for flexibility (tint, rendering); convert to SKTexture when creating sprites.
/// This avoids inline asset creation in scenes, making swaps (e.g., to PNGs) a one-file change.
struct Assets {
    // MARK: - Player
    /// Player archer image (tinted blue).
    static let playerImage: UIImage = {
        UIImage(systemName: "figure.archery")?.withTintColor(.blue, renderingMode: .alwaysOriginal) ?? UIImage()
    }()
    
    // MARK: - Monster
    /// Basic monster image (tinted red).
    static let monsterImage: UIImage = {
        UIImage(systemName: "figure.walk")?.withTintColor(.red, renderingMode: .alwaysOriginal) ?? UIImage()
    }()
    
    // MARK: - Rewards
    /// Gold coin image (tinted yellow).
    static let coinImage: UIImage = {
        UIImage(systemName: "dollarsign.circle.fill")?.withTintColor(.yellow, renderingMode: .alwaysOriginal) ?? UIImage()
    }()
    
    // MARK: - Helpers (if needed later)
    // Add more as game expands, e.g., static let bowImage: UIImage = UIImage(named: "bow") ?? UIImage()
}
