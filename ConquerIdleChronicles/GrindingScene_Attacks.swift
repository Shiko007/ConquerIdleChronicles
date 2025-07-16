//
//  GrindingScene_Attacks.swift
//  ConquerIdleChronicles
//
//  Extension for attack-related functionalities in GrindingScene.
//  Includes player arrow attacks and monster repeated attacks.

import SpriteKit

extension GrindingScene {
    /// Player shoots an arrow at the monster.
    func attackMonster(_ monster: MonsterModel) {
        // Create arrow: Simple line as placeholder
        let arrow = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 20, height: 2))
        arrow.fillColor = .black
        arrow.position = playerSprite.position
        addChild(arrow)
        
        // Rotate arrow to face monster at shoot time
        let dx = monster.sprite.position.x - playerSprite.position.x
        let dy = monster.sprite.position.y - playerSprite.position.y
        arrow.zRotation = atan2(dy, dx)
        
        // Associate target with arrow
        arrow.userData = ["target": monster]
        
        // Move arrow in direction with constant speed (straight line)
        let direction = CGVector(dx: dx, dy: dy).normalized()
        let scaled = CGVector(dx: direction.dx * GameConfig.arrowSpeed / 60.0, dy: direction.dy * GameConfig.arrowSpeed / 60.0)
        let moveAction = SKAction.repeatForever(SKAction.move(by: scaled, duration: 1.0 / 60.0))  // Approximate frame rate
        arrow.run(moveAction)
        
        arrows.append(arrow)
    }
    
    /// Starts repeated attacks on the player at configurable interval.
    func startRepeatedAttacks(for monster: MonsterModel) {
        let attackAction = SKAction.sequence([
            SKAction.wait(forDuration: GameConfig.Monster.attackInterval),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let damage = GameConfig.Monster.attack
                _ = self.onTakeDamage(damage)  // Apply damage; closure handles if dead
                if self.getShowPlayerDamageLabels() {
                    self.showPlayerDamageLabel(damage: damage)
                }
            }
        ])
        monster.sprite.run(SKAction.repeatForever(attackAction))
    }
}
