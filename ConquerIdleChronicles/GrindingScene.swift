//
//  GrindingScene.swift
//  ConquerIdleChronicles
//
//  Created by Sherif Yasser on 13.07.25.
//

import SpriteKit
import UIKit  // For UIImage, UIBezierPath, etc.

/// SpriteKit scene for the grinding view.
/// Handles monster spawning, movement, attacks, and health updates.
/// Runs auto (idle-style) when presented.
class GrindingScene: SKScene {
    // Closures for communicating with SwiftUI (avoids weak ref issues with structs)
    let onAddGold: (Int) -> Void
    let onAddExp: (Int) -> Void
    let onTakeDamage: (Int) -> Bool  // Returns true if player dead
    let getPlayerAttack: () -> Int
    let getPlayerHealth: () -> Int
    let getAutoCollectEnabled: () -> Bool  // New closure for auto-collect flag
    
    let playerSprite: SKSpriteNode
    var monsters: [MonsterModel] = []  // Active monsters
    var spawnTimer: Timer?  // For periodic spawning
    private var lastAttackTime: TimeInterval = 0  // Tracks time of last arrow shot for cooldown
    private var arrows: [SKShapeNode] = []  // Track active arrows for hit checks
    
    init(size: CGSize, onAddGold: @escaping (Int) -> Void, onAddExp: @escaping (Int) -> Void, onTakeDamage: @escaping (Int) -> Bool, getPlayerAttack: @escaping () -> Int, getPlayerHealth: @escaping () -> Int, getAutoCollectEnabled: @escaping () -> Bool) {
        self.onAddGold = onAddGold
        self.onAddExp = onAddExp
        self.onTakeDamage = onTakeDamage
        self.getPlayerAttack = getPlayerAttack
        self.getPlayerHealth = getPlayerHealth
        self.getAutoCollectEnabled = getAutoCollectEnabled
        
        // Player sprite: Use SF Symbol as placeholder (archer)
        let playerImage = UIImage(systemName: "figure.archery")?.withTintColor(.blue, renderingMode: .alwaysOriginal)
        playerSprite = SKSpriteNode(texture: SKTexture(image: playerImage ?? UIImage()))
        playerSprite.size = CGSize(width: 50, height: 50)
        playerSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)  // Center
        
        super.init(size: size)
        addChild(playerSprite)
        
        // Player health circle: Green ring
        let healthCircle = SKShapeNode(circleOfRadius: 30)
        healthCircle.position = playerSprite.position
        healthCircle.strokeColor = .green
        healthCircle.lineWidth = 5
        healthCircle.fillColor = .clear
        addChild(healthCircle)
        healthCircle.name = "playerHealthCircle"  // For updates
        
        startSpawning()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Starts timer to spawn multiple monsters periodically.
    private func startSpawning() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: GameConfig.monsterSpawnInterval, repeats: true) { [weak self] _ in
            let numToSpawn = Int.random(in: GameConfig.minMonstersPerSpawn...GameConfig.maxMonstersPerSpawn)  // Random count per cycle
            for _ in 0..<numToSpawn {
                self?.spawnMonster()
            }
        }
    }
    
    /// Spawns a single monster from a random edge.
    /// Called multiple times for waves.
    private func spawnMonster() {
        // Placeholder monster: Goblin SF Symbol
        let monsterImage = UIImage(systemName: "figure.walk")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        let monsterSprite = SKSpriteNode(texture: SKTexture(image: monsterImage ?? UIImage()))
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
        
        // Health bar: Red rectangle above monster
        let healthBar = SKShapeNode(rect: CGRect(x: -20, y: 25, width: 40, height: 5))
        healthBar.fillColor = .red
        healthBar.strokeColor = .clear
        healthBar.name = "healthBar"
        monsterSprite.addChild(healthBar)
        
        // Calculate direction and stop position (at configurable distance from player to avoid overlap)
        let direction = CGVector(dx: playerSprite.position.x - position.x, dy: playerSprite.position.y - position.y).normalized()
        let stopPosition = CGPoint(x: playerSprite.position.x - direction.dx * GameConfig.monsterStopDistance,
                                   y: playerSprite.position.y - direction.dy * GameConfig.monsterStopDistance)
        
        // Move to stop position
        let distanceToStop = sqrt(pow(stopPosition.x - position.x, 2) + pow(stopPosition.y - position.y, 2))
        let duration = TimeInterval(distanceToStop / GameConfig.monsterSpeed)
        let moveAction = SKAction.move(to: stopPosition, duration: duration)
        monsterSprite.run(moveAction) { [weak self] in
            self?.startRepeatedAttacks(for: monster)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update monster health bars (always, no cooldown needed)
        for monster in monsters {
            if let healthBar = monster.sprite.childNode(withName: "healthBar") as? SKShapeNode {
                let width = 40 * (CGFloat(monster.health) / CGFloat(monster.maxHealth))
                healthBar.path = UIBezierPath(rect: CGRect(x: -20, y: 25, width: width, height: 5)).cgPath
            }
        }
        
        // Update player health circle
        if let circle = childNode(withName: "playerHealthCircle") as? SKShapeNode {
            let healthPercent = CGFloat(getPlayerHealth()) / CGFloat(GameConfig.playerMaxHealth)
            circle.path = UIBezierPath(arcCenter: .zero, radius: 30, startAngle: 0, endAngle: 2 * .pi * healthPercent, clockwise: true).cgPath
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
                    if targetMonster.takeDamage(self.getPlayerAttack()) {
                        // Dead: Remove monster, add rewards, stop any attacks
                        targetMonster.sprite.removeAllActions()  // Stop repeated attacks
                        targetMonster.sprite.removeFromParent()
                        if let index = self.monsters.firstIndex(where: { $0 === targetMonster }) {
                            self.monsters.remove(at: index)
                        }
                        self.onAddExp(GameConfig.expPerMonster)  // Configurable EXP reward
                        self.dropGoldCoin(at: targetMonster.sprite.position)  // Drop coin instead of direct gold add
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
            if currentTime - lastAttackTime >= GameConfig.playerAttackInterval {
                attackMonster(nearest)
                lastAttackTime = currentTime  // Reset cooldown timer
            }
        }
    }
    
    /// Drops a tappable gold coin at the given position.
    private func dropGoldCoin(at position: CGPoint) {
        let coinImage = UIImage(systemName: "dollarsign.circle.fill")?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
        let coinSprite = SKSpriteNode(texture: SKTexture(image: coinImage ?? UIImage()))
        coinSprite.size = CGSize(width: 30, height: 30)
        coinSprite.position = position
        coinSprite.name = "coin"
        coinSprite.userData = ["value": GameConfig.goldPerMonster]  // Configurable gold value
        addChild(coinSprite)
        
        // Always add disappear timer with fade (fade after delay, then remove at end)
        let fadeStartDelay = GameConfig.coinFadeStartDelay
        let fadeStartAction = SKAction.wait(forDuration: fadeStartDelay)
        let fadeAction = SKAction.fadeOut(withDuration: GameConfig.coinFadeDuration)
        let removeAction = SKAction.removeFromParent()
        let disappearSequence = SKAction.sequence([fadeStartAction, fadeAction, removeAction])
        coinSprite.run(disappearSequence)
        
        // If auto-collect enabled, collect immediately
        if getAutoCollectEnabled() {
            let collectAction = SKAction.run { [weak self, weak coinSprite] in
                guard let self = self, let coinSprite = coinSprite, coinSprite.parent != nil else { return }  // Skip if already disappeared
                
                coinSprite.removeAllActions()  // Cancel disappear sequence
                
                let dx = self.playerSprite.position.x - coinSprite.position.x
                let dy = self.playerSprite.position.y - coinSprite.position.y
                let distance = hypot(dx, dy)
                let duration = TimeInterval(distance / GameConfig.coinCollectSpeed)
                
                let moveAction = SKAction.move(to: self.playerSprite.position, duration: duration)
                let removeAction = SKAction.removeFromParent()
                let sequence = SKAction.sequence([moveAction, removeAction])
                coinSprite.run(sequence) { [weak self] in
                    guard let self = self else { return }
                    if let value = coinSprite.userData?["value"] as? Int {
                        self.onAddGold(value)
                        self.showGoldLabel(value: value)
                    }
                }
            }
            coinSprite.run(collectAction)
        }
    }
    
    /// Player shoots an arrow at the monster.
    private func attackMonster(_ monster: MonsterModel) {
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
    private func startRepeatedAttacks(for monster: MonsterModel) {
        let attackAction = SKAction.sequence([
            SKAction.wait(forDuration: GameConfig.monsterAttackInterval),
            SKAction.run { [weak self] in
                _ = self?.onTakeDamage(GameConfig.monsterAttack)  // Apply damage; closure handles if dead
            }
        ])
        monster.sprite.run(SKAction.repeatForever(attackAction))
    }
    
    private func distanceToPlayer(_ sprite: SKSpriteNode) -> CGFloat {
        let dx = sprite.position.x - playerSprite.position.x
        let dy = sprite.position.y - playerSprite.position.y
        return sqrt(dx*dx + dy*dy)
    }
    
    private func distanceToTarget(_ position: CGPoint, target: CGPoint) -> CGFloat {
        let dx = target.x - position.x
        let dy = target.y - position.y
        return sqrt(dx*dx + dy*dy)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = nodes(at: location)
            for node in nodes {
                if node.name == "coin", let value = node.userData?["value"] as? Int {
                    // Stop any pending actions (e.g., disappear sequence, auto-collect delay)
                    node.removeAllActions()
                    
                    // Animate coin to player
                    let dx = playerSprite.position.x - node.position.x
                    let dy = playerSprite.position.y - node.position.y
                    let distance = hypot(dx, dy)
                    let duration = TimeInterval(distance / GameConfig.coinCollectSpeed)
                    
                    let moveAction = SKAction.move(to: playerSprite.position, duration: duration)
                    let removeAction = SKAction.removeFromParent()
                    let sequence = SKAction.sequence([moveAction, removeAction])
                    node.run(sequence) { [weak self] in
                        guard let self = self else { return }
                        self.onAddGold(value)
                        self.showGoldLabel(value: value)
                    }
                    return  // Stop after handling one coin per tap (avoids multiple if overlapping)
                }
            }
        }
    }
    
    /// Helper to show floating gold label above player.
    private func showGoldLabel(value: Int) {
        let label = SKLabelNode(text: "+\(value)")
        label.fontName = "Helvetica-Bold"
        label.fontSize = 20
        label.fontColor = .yellow
        label.position = CGPoint(x: self.playerSprite.position.x, y: self.playerSprite.position.y + 50)
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

// Helper extension for vector normalization
extension CGVector {
    func normalized() -> CGVector {
        let length = sqrt(dx * dx + dy * dy)
        guard length != 0 else { return self }
        return CGVector(dx: dx / length, dy: dy / length)
    }
}
