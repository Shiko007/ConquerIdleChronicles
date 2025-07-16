//
//  GrindingScene_Spawning.swift
//  ConquerIdleChronicles
//
//  Extension for spawning-related functionalities in GrindingScene.
//  Follows SRP: Isolates monster creation and wave timing.

import SpriteKit

extension GrindingScene {
    /// Starts timer to spawn multiple monsters periodically.
    func startSpawning() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: GameConfig.Monster.spawnInterval, repeats: true) { [weak self] _ in
            let numToSpawn = Int.random(in: GameConfig.Monster.minPerSpawn...GameConfig.Monster.maxPerSpawn)  // Random count per cycle
            for _ in 0..<numToSpawn {
                self?.spawnMonster()
            }
        }
    }
    
    /// Spawns a single monster from a random edge.
    /// Called multiple times for waves.
    func spawnMonster() {
        // Monster sprite: Use centralized asset
        let monsterSprite = SKSpriteNode(texture: SKTexture(image: Assets.monsterImage))
        monsterSprite.size = CGSize(width: 40, height: 40)
        
        // Random edge position
        let edge = Int.random(in: 0..<4)
        var position: CGPoint
        switch edge {
        case 0: position = CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + 50)  // Top
        case 1: position = CGPoint(x: CGFloat.random(in: 0...size.width), y: -50)  // Bottom
        case 2: position = CGPoint(x: size.width + 50, y: CGFloat.random(in: 0...size.height))  // Right
        default: position = CGPoint(x: -50, y: CGFloat.random(in: 0...size.height))  // Left
        }
        monsterSprite.position = position
        
        let monster = MonsterModel(sprite: monsterSprite)
        monsters.append(monster)
        addChild(monsterSprite)
        
        // Health bar background: Grey rectangle
        let healthBg = SKShapeNode(rect: CGRect(x: -20, y: 25, width: 40, height: 5))
        healthBg.fillColor = .gray
        healthBg.strokeColor = .clear
        healthBg.name = "healthBg"
        monsterSprite.addChild(healthBg)
        
        // Health bar foreground: Red rectangle above background
        let healthBar = SKShapeNode(rect: CGRect(x: -20, y: 25, width: 40, height: 5))
        healthBar.fillColor = .red
        healthBar.strokeColor = .clear
        healthBar.name = "healthBar"
        monsterSprite.addChild(healthBar)
        
        // Calculate direction and stop position (at configurable distance from player to avoid overlap)
        let direction = CGVector(dx: playerSprite.position.x - position.x, dy: playerSprite.position.y - position.y).normalized()
        let stopPosition = CGPoint(x: playerSprite.position.x - direction.dx * GameConfig.Monster.stopDistance,
                                   y: playerSprite.position.y - direction.dy * GameConfig.Monster.stopDistance)
        
        // Move to stop position
        let distanceToStop = sqrt(pow(stopPosition.x - position.x, 2) + pow(stopPosition.y - position.y, 2))
        let duration = TimeInterval(distanceToStop / GameConfig.Monster.speed)
        let moveAction = SKAction.move(to: stopPosition, duration: duration)
        monsterSprite.run(moveAction) { [weak self] in
            self?.startRepeatedAttacks(for: monster)
        }
    }
}
