//
//  GameScene.swift
//  BiggerFish
//
//  Created by admin on 12/26/21.
//

import SpriteKit
import CoreMotion
import AVFoundation
import SwiftUI

// Bitmasks for collision
enum CollisionType: UInt32 {
    case player = 1
    case enemy = 2
    // TODO: - Powerups
    case powerUp = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    // Movement
    let motionManager = CMMotionManager()
    
    // Player node
    let player = SKSpriteNode(imageNamed: "fishTile_072")

    @Published var isHighScore = false
    @Published var highScoreNameInput = ""
    @Published var score = 0
    @Published var level = 1
    // Triggers UI reload from InterfaceControls changes
    @Published var reload = false
    
    var runCount = 0
    var spawnTimerInterval = 3.0
    var spawnTimer:Timer?
    var spawnRateIncreaseTimer:Timer?
    var initialPlayerSize:CGSize?
    
    // Camera zoom
    var zoomAmount = 1.0
    
    // Audio players
    var backgroundAudioPlayer:AVAudioPlayer?
    var foregroundAudioPlayer:AVAudioPlayer?
    var interfaceAudioPlayer:AVAudioPlayer?
    
    // Camera
    var cameraNode = SKCameraNode()
    
    // User defaults reference
    let userDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        
        // Set initial player size
        initialPlayerSize = player.size
        
        // Set SKScene size to device dimensions
        self.size = CGSize(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
        
        // Set an empty dictionary if userdefaults "HighScoresDict" hasn't already been set
        if userDefaults.dictionary(forKey: "HighScoresDict") == nil {
            let emptyDict = [String:Int]()
            userDefaults.set(emptyDict, forKey: "HighScoresDict")
        }
        
        // Start audio
        playBackgroundAudio()
        
        // Set gravity to zero
        physicsWorld.gravity = .zero
        
        // Use this class as the delegate for collisions
        physicsWorld.contactDelegate = self
        
        // Start gathering accelerometer data
        motionManager.startAccelerometerUpdates()
        
        // Create visuals
        createGradient()
        createBubbles()
        
        // Set camera for zooming
//        cameraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//        self.addChild(cameraNode)
//        self.camera = cameraNode
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Track motion
        if let accelerometerData = motionManager.accelerometerData {
            player.position.x += CGFloat(accelerometerData.acceleration.x * 50)

            if player.position.x < frame.minX {
                player.position.x = frame.minX
            } else if player.position.x > frame.maxX {
                player.position.x = frame.maxX
            }
        }
    }
    
    // Pause on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Only run this code while game is playing or paused
        if InterfaceControls.interfaceState == .playing || InterfaceControls.interfaceState == .paused {
            
            // If game is paused, switch it to playing, and vice versa
            if InterfaceControls.interfaceState == .paused {
                InterfaceControls.interfaceState = .playing
                createTimers()
            } else {
                InterfaceControls.interfaceState = .paused
                stopTimers()
            }
            
            // Pause timers
//            spawnTimer.invalidate()
            
            // Trigger interface reload
            reload.toggle()
            
            // Toggle SK game pause state
            self.isPaused.toggle()
            
            // Play pause audio
            playPauseSound()
        }
    }
    
    // MARK: - Game events
    
    // Creates player and starts creating enemies
    func startGame() {
        
        // Reset spawn interval
        spawnTimerInterval = 3.0
        
        // Reset score and level
        score = 0
        level = 1
        
        // Remove any enemy nodes left from a previous game
        for child in children {
            if child.name == "enemy" {
                child.removeFromParent()
            }
        }
        
        // Create player
        createPlayer()
        
        // Start timers
        createTimers()
    }
    
    func gameOver() {
        
        // Death audio
        playDeathSound()
        
        // Remove the player from the scene
        player.removeFromParent()
        
        // Get high scores and check if player score is greater
        if score > 0 {
            let highScores = userDefaults.dictionary(forKey: "HighScoresDict") as! [String:Int]
            // If there are 5 high scores, remove the lowest
            if highScores.count == 5 {
                let lowestScore = highScores.min { a, b in a.value < b.value }
                if score > lowestScore!.value {
                    isHighScore = true
                }
            } else {
                isHighScore = true
            }
        }
        
        // Show the game over screen
        InterfaceControls.interfaceState = .gameOver
        reload.toggle()
        
        // Stop timers
        stopTimers()
    }
    
    func levelUp() {
        
        let playerSize = player.size
        let sizeDifferential = initialPlayerSize!.width / playerSize.width
        
        // Scale player, enemies, and bubbles
        for node in self.children {
            if node.name == "player" {
                let action = SKAction.scale(to: initialPlayerSize!, duration: 4)
                node.run(action)
            }
            if node.name == "enemy" {
                let action = SKAction.scale(by: sizeDifferential, duration: 4)
                node.run(action)
            }
//            if node.name == "bubbles" {
////                let action = SKAction.scale(by: sizeDifferential, duration: 4)
////                node.run(action)
//                let bubbleNode = node as! SKEmitterNode
////                bubbleNode.particleAction
////                bubbleNode.particleSize
////                let newParticleSize = CGSize(width: bubbleNode.particleSize.width * 0.5, height: bubbleNode.particleSize.height * 0.5)
////                let particleScaleSequence = SKKeyframeSequence(keyframeValues: [bubbleNode.particleSize, newParticleSize], times: [0.0,4.0])
////                bubbleNode.particleScaleSequence = particleScaleSequence
//            }
        }
        
        // Zoom camera
//        let zoomInAction = SKAction.scale(to: 1.5, duration: 4)
//        cameraNode.run(zoomInAction)
        
        // Increment level
        level += 1
        
        // Timer to show level up dialogue
        InterfaceControls.levelUp = true
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            InterfaceControls.levelUp = false
            self.reload.toggle()
            timer.invalidate()
        }
        
    }
    
    // MARK: - Timers
    
    @objc func increaseSpawnRate() {
        // Decrease the spawn interval
        spawnTimerInterval *= 0.95
        // Create a new timer with the new interval
        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(timeInterval: spawnTimerInterval, target: self, selector: #selector(spawnTimerFunc), userInfo: nil, repeats: true)
    }
    
    @objc func spawnTimerFunc() {
        
        // Create an enemy with a random size and speed
        createEnemy()
    }
    
    func stopTimers() {
        // Stop the spawn timer and spawn rate timer
        spawnTimer?.invalidate()
        spawnRateIncreaseTimer?.invalidate()
    }
    
    // Creates the spawn timer and spawn rate timer
    func createTimers() {
        // Create a new spawn timer
        spawnTimer = Timer.scheduledTimer(timeInterval: spawnTimerInterval, target: self, selector: #selector(spawnTimerFunc), userInfo: nil, repeats: true)
        
        // Create a spawn rate increase timer
        spawnRateIncreaseTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(increaseSpawnRate), userInfo: nil, repeats: true)
    }
    
    // MARK: - Collision
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Use node name to compute a player node and enemy node variable
        var playerNode: SKNode {
            if contact.bodyA.node?.name == "player" {
                return contact.bodyA.node!
            } else if contact.bodyB.node?.name == "player" {
                return contact.bodyB.node!
            }
            return SKNode()
        }
        var enemyNode: SKNode {
            if contact.bodyA.node?.name == "enemy" {
                return contact.bodyA.node!
            } else if contact.bodyB.node?.name == "enemy" {
                return contact.bodyB.node!
            }
            return SKNode()
        }
        
        // Kill on every pufferfish touch
        let enemy = enemyNode as? EnemyNode
        if enemy?.enemyType == .puffer {
            gameOver()
            return
        }
        
        // Size margin of player:enemy to accept a kill
        var enemySizeKillMargin = 0.90
        
        // Fix pinkfish hitbox issue
        if enemy?.enemyType == .pinkFish {
            enemySizeKillMargin = 0.70
        }
        
        // Player is bigger than fish
        // If the player's width or height is greater than the enemy's width or height multiplied by the size margin
        if playerNode.frame.width > (enemyNode.frame.width * enemySizeKillMargin) || playerNode.frame.height > (enemyNode.frame.height * enemySizeKillMargin){
            playGulpSound()
            enemyNode.removeFromParent()
            player.scale(to: CGSize(width: player.size.width + enemyNode.frame.size.width/10,
                                    height: player.size.height + enemyNode.frame.size.width/10))
            self.score += 1
        // Fish is bigger than player
        } else {
            gameOver()
        }
        
        // If player is greater than a third of the screen, trigger a level up
        if player.size.width > UIScreen.main.bounds.width / 3 {
            levelUp()
        }
    }
    
    // MARK: - Nodes
    
    func createPlayer() {
        player.setScale(1.0)
        player.name = "player"
        player.position.x = frame.width / 2
        player.position.y = UIScreen.main.bounds.height/7
        player.zPosition = 0
        player.size = CGSize(width: player.size.width, height: player.size.height)
        player.zRotation = .pi / 2
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        // Which bitmask it is
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        // Which bitmask it can collide with
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue
        // What collisions trigger a notification
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue
        player.physicsBody?.allowsRotation = false
    }
    
    func createEnemy() {
        let enemy = EnemyNode()
        addChild(enemy)
    }
    
    // MARK: - Background visuals
    
    func createGradient() {
        // MARK: - Gradient
        let color1: CGColor = UIColor(red: 68/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        let color2: CGColor = UIColor.blue.cgColor
        let startPoint = CGPoint(x: 0.5, y: 0)
        let endPoint = CGPoint(x: 0.5, y: 1)
        
        let gradientImage: UIImage = UIImage.gradientImage(withBounds: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2),
                                                     startPoint: startPoint,
                                                     endPoint: endPoint,
                                                     colors: [color1, color2])
        
        let gradientTexture = SKTexture(image: gradientImage)
        let gradientNode = SKSpriteNode(texture: gradientTexture)
        gradientNode.zPosition = -2
        gradientNode.name = "gradient"
        addChild(gradientNode)
        
    }
    
    func createBubbles() {
        if let bubbles = SKEmitterNode(fileNamed: "Bubbles") {
            bubbles.position = CGPoint(x: 0, y: 0)
            // Set particles behind other elements
            bubbles.zPosition = -1
            // Advance particle simulation so stars fill screen on launch
            bubbles.advanceSimulationTime(60)
            bubbles.name = "bubbles"
            addChild(bubbles)
        }
    }
    
    // MARK: - Audio
    
    func playBackgroundAudio() {
        let backgroundMusicUrl = Bundle.main.url(forResource: "bubble", withExtension: "mp3")
        try! backgroundAudioPlayer = AVAudioPlayer(contentsOf: backgroundMusicUrl!)
        backgroundAudioPlayer?.volume = 0.5
        backgroundAudioPlayer?.numberOfLoops = -1
        backgroundAudioPlayer?.play()
    }
    
    func playDeathSound() {
        let deathSoundUrl = Bundle.main.url(forResource: "chomp", withExtension: "mp3")
        try! foregroundAudioPlayer = AVAudioPlayer(contentsOf: deathSoundUrl!)
        foregroundAudioPlayer?.play()
    }
    
    func playGulpSound() {
        // Picks a random number and plays gulp sound + the number
        let randomGulpNumber = Int.random(in: 0...4)
        let gulpSoundUrl = Bundle.main.url(forResource: "gulp\(randomGulpNumber)", withExtension: "mp3")
        try! foregroundAudioPlayer = AVAudioPlayer(contentsOf: gulpSoundUrl!)
        foregroundAudioPlayer?.play()
    }
    
    func playPauseSound() {
        var pauseSoundUrl:URL?
        if InterfaceControls.interfaceState == .paused {
            pauseSoundUrl = Bundle.main.url(forResource: "pauseOn", withExtension: "wav")
        } else {
            pauseSoundUrl = Bundle.main.url(forResource: "pauseOff", withExtension: "wav")
        }
        try! interfaceAudioPlayer = AVAudioPlayer(contentsOf: pauseSoundUrl!)
        interfaceAudioPlayer?.volume = 0.7
        interfaceAudioPlayer?.play()
    }
}

