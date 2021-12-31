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
    
    // Audio
    var audioPlayer:AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        
        // Run bubble audio loop
//        let bubbleBackgroundSound = SKAudioNode(fileNamed: "bubble")
//        bubbleBackgroundSound.autoplayLooped = true
//        addChild(bubbleBackgroundSound)
        
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
        let randomSpeed = Int.random(in: 50...200)
        self.createEnemy(enemyScale: randomSize, enemySpeed: randomSpeed)
    }
    
    // MARK: - Physics
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        // Kill on every pufferfish touch
        let enemy = nodeB as? EnemyNode
        if enemy?.enemyType == .puffer {
            gameOver()
            return
        }
        
        if nodeA.frame.width > (nodeB.frame.width * 0.95) || nodeA.frame.height > (nodeB.frame.height * 0.95){
            nodeB.removeFromParent()
            player.scale(to: CGSize(width: player.size.width + nodeB.frame.size.width/10,
                                    height: player.size.height + nodeB.frame.size.width/10))
            self.score += 1
        } else {
            gameOver()
        }
    }
    
    // MARK: - Nodes
    
    func createPlayer() {
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
    
    func createEnemy(enemyScale:Double, enemySpeed:Int) {
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
        try! audioPlayer = AVAudioPlayer(contentsOf: backgroundMusicUrl!)
        audioPlayer?.volume = 0.5
        audioPlayer?.numberOfLoops = -1
        audioPlayer?.play()
    }
    
    func playDeathSound() {
        let deathSoundUrl = Bundle.main.url(forResource: "chomp", withExtension: "mp3")
        try! audioPlayer = AVAudioPlayer(contentsOf: deathSoundUrl!)
        audioPlayer?.play()
    }
}

