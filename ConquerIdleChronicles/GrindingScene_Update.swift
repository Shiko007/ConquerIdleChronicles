//
//  GrindingScene_Update.swift
//  ConquerIdleChronicles
//
//  Extension for update loop in GrindingScene.
//  Handles health updates, arrow hits, and auto-attacks.

import SpriteKit
import UIKit  // For UIBezierPath in health updates.

extension GrindingScene {
    override func update(_ currentTime: TimeInterval) {
        // Update monster health bars (always, no cooldown needed)
        for monster in monsters {
            if let healthBar = monster.sprite.childNode(withName: "healthBar") as? SKShapeNode {
                let width = 40 * (CGFloat(monster.health) / CGFloat(monster.maxHealth))
                healthBar.path = UIBezierPath(rect: CGRect(x: -20, y: 25, width: width, height: 5)).cgPath
            }
        }
        
        // Check for arrow hits on their specific targets
        arrows = arrows.filter { arrow in
            if let targetMonster = arrow.userData?["target"] as? MonsterModel {
                // Check if monster is still alive before hit processing
                guard monsters.contains(where: { $0 === targetMonster }) else {
                    arrow.removeFromParent()
                    return false  // Skip if already dead/removed
                }
                
                let distance = self.distanceToTarget(arrow.position, target: targetMonster.sprite.position)
                if distance < 10 {  // Hit threshold (adjust for precision)
                    arrow.removeFromParent()
                    let damage = self.getPlayerAttack()
                    if targetMonster.takeDamage(damage) {
                        // Dead: Remove monster, add rewards, stop any attacks
                        targetMonster.sprite.removeAllActions()  // Stop repeated attacks
                        targetMonster.sprite.removeFromParent()
                        if let index = self.monsters.firstIndex(where: { $0 === targetMonster }) {
                            self.monsters.remove(at: index)
                        }
                        self.onAddExp(GameConfig.expPerMonster)  // Configurable EXP reward
                        self.dropGoldCoin(at: targetMonster.sprite.position)
                    } else {
                        // Not dead: Show damage label above monster if enabled
                        if self.getShowDamageLabels() {
                            self.showDamageLabel(on: targetMonster.sprite, damage: damage)
                        }
                    }
                    return false  // Remove from arrows array
                }
            }
            // Optional: Remove if off-screen (to clean up misses)
            if !self.frame.contains(arrow.position) {
                arrow.removeFromParent()
                return false
            }
            return true  // Keep arrow
        }
        
        // Auto-attack: Find nearest monster and shoot only if cooldown elapsed
        if let nearest = monsters.min(by: { self.distanceToPlayer($0.sprite) < self.distanceToPlayer($1.sprite) }) {
            if currentTime - lastAttackTime >= GameConfig.Player.attackInterval {
                attackMonster(nearest)
                lastAttackTime = currentTime  // Reset cooldown timer
            }
        }
    }
}
