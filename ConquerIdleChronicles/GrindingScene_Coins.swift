//
//  GrindingScene_Coins.swift
//  ConquerIdleChronicles
//
//  Extension for coin-related functionalities in GrindingScene.
//  Includes dropping, collecting (taps/auto), and gold labels.

import SpriteKit

extension GrindingScene {
    /// Drops a tappable gold coin at the given position.
    func dropGoldCoin(at position: CGPoint) {
        // Coin sprite: Use centralized asset
        let coinSprite = SKSpriteNode(texture: SKTexture(image: Assets.coinImage))
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
                        if self.getShowGoldLabels() {
                            self.showGoldLabel(value: value)
                        }
                    }
                }
            }
            coinSprite.run(collectAction)
        }
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
                        if self.getShowGoldLabels() {
                            self.showGoldLabel(value: value)
                        }
                    }
                    return  // Stop after handling one coin per tap (avoids multiple if overlapping)
                }
            }
        }
    }
    
    /// Helper to show floating gold label above player.
    func showGoldLabel(value: Int) {
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
}
