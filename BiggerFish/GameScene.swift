//
//  GameScene.swift
//  BiggerFish
//
//  Created by admin on 12/26/21.
//

import SpriteKit
import CoreMotion
import AVFoundation

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
    @Published var isShowingGameOverScreen = false
    @Published var isShowingTitleScreen = true
    @Published var score = 0
    
    var runCount = 0
    var spawnTimerInterval = 3.0
    var spawnTimer:Timer?
    var spawnRateIncreaseTimer:Timer?
    
    // Audio players
    var backgroundAudioPlayer:AVAudioPlayer?
    var foregroundAudioPlayer:AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        
        playBackgroundMusic()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        self.size = CGSize(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
        
        motionManager.startAccelerometerUpdates()
        
        createGradient()
        createBubbles()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.isPaused.toggle()
    }
    
    // Creates player and starts creating enemies
    func startGame() {
        
        // Reset spawn interval
        spawnTimerInterval = 3.0
        
        // Reset score
        score = 0
        
        // Remove any enemy nodes left from a previous game
        for child in children {
            if child.name == "enemy" {
                child.removeFromParent()
            }
        }
        
        createPlayer()
        
        // Create a new spawn timer
        spawnTimer = Timer.scheduledTimer(timeInterval: spawnTimerInterval, target: self, selector: #selector(spawnTimerFunc), userInfo: nil, repeats: true)
        
        // Create a spawn rate increase timer
        spawnRateIncreaseTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(increaseSpawnRate), userInfo: nil, repeats: true)
    }
    
    func gameOver(){
        playDeathSound()
        player.removeFromParent()
        self.isShowingGameOverScreen = true
        spawnTimer?.invalidate()
        spawnRateIncreaseTimer?.invalidate()
    }
    
    @objc func increaseSpawnRate() {
        // Decrease the spawn interval
        spawnTimerInterval *= 0.95
        // Create a new timer with the new interval
        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(timeInterval: spawnTimerInterval, target: self, selector: #selector(spawnTimerFunc), userInfo: nil, repeats: true)
    }
    
    @objc func spawnTimerFunc() {
        let randomSize = Double.random(in: 0.25...3)
        let randomSpeed = Double.random(in: 50...200)
        self.createEnemy(enemyScale: randomSize, enemySpeed: randomSpeed)
    }
    
    // MARK: - Physics/Collision
    
    func didBegin(_ contact: SKPhysicsContact) {
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
        
        var enemySizeKillMargin = 0.95
        
        if enemy?.enemyType == .pinkFish {
            enemySizeKillMargin = 0.70
        }
        
        // Player is bigger than fish
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
//        player.physicsBody?.allowsRotation = false
    }
    
    func createEnemy(enemyScale:Double, enemySpeed:Double) {
        let enemy = EnemyNode(enemyScale: enemyScale, enemySpeed: enemySpeed)
        addChild(enemy)
    }
    
    // MARK: - Background visuals
    
    func createGradient() {
        // MARK: - Gradient
        let color1: CGColor = UIColor(red: 68/255, green: 198/255, blue: 198/255, alpha: 1).cgColor
        let color2: CGColor = UIColor.blue.cgColor
        let startPoint = CGPoint(x: 0.5, y: 0)
        let endPoint = CGPoint(x: 0.5, y: 1)
        
        let myImage: UIImage = UIImage.gradientImage(withBounds: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2),
                                                     startPoint: startPoint, endPoint: endPoint, colors: [color1, color2])
        let gradientTexture = SKTexture(image: myImage)
        let gradientNode = SKSpriteNode(texture: gradientTexture)
        gradientNode.zPosition = -2
        addChild(gradientNode)
    }
    
    func createBubbles() {
        // MARK: - Bubbles
        if let bubbles = SKEmitterNode(fileNamed: "Bubbles") {
            bubbles.position = CGPoint(x: 0, y: 0)
            // Set particles behind other elements
            bubbles.zPosition = -1
            // Advance particle simulation so stars fill screen on launch
            bubbles.advanceSimulationTime(60)
            addChild(bubbles)
        }
    }
    
    // MARK: - Audio
    
    func playBackgroundMusic() {
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
        let randomGulpNumber = Int.random(in: 0...4)
        let gulpSoundUrl = Bundle.main.url(forResource: "gulp\(randomGulpNumber)", withExtension: "mp3")
        try! foregroundAudioPlayer = AVAudioPlayer(contentsOf: gulpSoundUrl!)
        foregroundAudioPlayer?.play()
    }
}

