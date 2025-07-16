//
//  GrindingScene_Helpers.swift
//  ConquerIdleChronicles
//
//  Extension for helper methods in GrindingScene.
//  Includes distances, damage labels, and scene cleanup.

import SpriteKit

extension GrindingScene {
    func distanceToPlayer(_ sprite: SKSpriteNode) -> CGFloat {
        let dx = sprite.position.x - playerSprite.position.x
        let dy = sprite.position.y - playerSprite.position.y
        return sqrt(dx*dx + dy*dy)
    }
    
    func distanceToTarget(_ position: CGPoint, target: CGPoint) -> CGFloat {
        let dx = target.x - position.x
        let dy = target.y - position.y
        return sqrt(dx*dx + dy*dy)
    }
    
    /// Helper to show floating damage label above monster.
    func showDamageLabel(on sprite: SKSpriteNode, damage: Int) {
        let label = SKLabelNode(text: "-\(damage)")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .white  // White for visibility; adjust as needed
        label.position = CGPoint(x: sprite.position.x, y: sprite.position.y + 50)  // Above head
        addChild(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([group, remove]))
    }
    
    /// Helper to show floating damage label above player (in red).
    func showPlayerDamageLabel(damage: Int) {
        let label = SKLabelNode(text: "-\(damage)")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .red
        label.position = CGPoint(x: self.playerSprite.position.x, y: self.playerSprite.position.y + 50)  // Above head
        addChild(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let group = SKAction.group([moveUp, fadeOut])
        let remove = SKAction.removeFromParent()
        label.run(SKAction.sequence([group, remove]))
    }
    
    /// Stops spawning and cleans up when grinding ends.
    func stopScene() {
        spawnTimer?.invalidate()
        for monster in monsters {
            monster.sprite.removeAllActions()  // Stop repeated attacks
            monster.sprite.removeFromParent()
        }
        monsters.removeAll()
        for arrow in arrows {
            arrow.removeFromParent()
        }
        arrows.removeAll()
        // Clean up coins and their actions
        for child in children {
            if child.name == "coin" {
                child.removeAllActions()
                child.removeFromParent()
            }
        }
        // Note: Player health reset is in PlayerModel; call if needed in ContentView
    }
}

// Helper extension for vector normalization (moved here as a general helper)
extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        guard length != 0 else { return self }
        return CGVector(dx: dx / length, dy: dy / length)
    }
}
