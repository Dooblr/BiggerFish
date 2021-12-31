//
//  EnemyNode.swift
//  BiggerFish
//
//  Created by admin on 12/26/21.
//

import SpriteKit

enum EnemyTypes {
    case fish
    case redFish
    case pinkFish
    case blueFish
    case orangeFish
    case grayFish
    case puffer
    case rock
}

class EnemyNode: SKSpriteNode {
    
    var enemyScale:Double
    var enemySpeed:Int
    var enemyType:EnemyTypes
    
    init(enemyScale:Double,enemySpeed:Int) {
        self.enemyScale = enemyScale
        self.enemySpeed = enemySpeed
        
        var fishId = ""
        
        self.enemyType = .fish
        
        let randomPufferNum = Int.random(in: 0...14)
        if randomPufferNum == 0 {
            fishId = "fishTile_100"
            self.enemyType = .puffer
        } else {
            let randomFishNum = Int.random(in: 0...4)
            switch randomFishNum {
            case 0: fishId = "fishTile_078"; self.enemyType = .redFish
            case 1: fishId = "fishTile_074"; self.enemyType = .pinkFish // pink
            case 2: fishId = "fishTile_076"; self.enemyType = .blueFish // blue
            case 3: fishId = "fishTile_080"; self.enemyType = .orangeFish // orange
            case 4: fishId = "fishTile_102"; self.enemyType = .grayFish // gray
            default:
                fishId = "fishTile_078"
            }
        }

        let enemyTexture = SKTexture(imageNamed: fishId)
        
        super.init(texture: enemyTexture, color:.white, size: CGSize(width: enemyTexture.size().width * enemyScale,
                                                                height: enemyTexture.size().height * enemyScale))
        
        // Create a physics body with texture/hitbox encompassing the image
        physicsBody = SKPhysicsBody(texture: enemyTexture, size: enemyTexture.size())
        // Set self bitmask
        physicsBody?.categoryBitMask = CollisionType.enemy.rawValue
        // Set physics collision bitmask
        physicsBody?.collisionBitMask = CollisionType.player.rawValue
        // Set collision notification bitmask
        physicsBody?.contactTestBitMask = CollisionType.player.rawValue
        // Set name
        name = "enemy"
        let startX = Int.random(in: 0...Int(UIScreen.main.bounds.width))
        position = CGPoint(x: startX, y: Int(UIScreen.main.bounds.height) + 100)
        

        configureMovement(moveStraight:true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMovement(moveStraight:Bool) {
        let path = UIBezierPath()
        path.move(to: .zero)
        
        path.addLine(to: CGPoint(x: 0, y: -10000))
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(enemySpeed))
        let sequence = SKAction.sequence([movement,.removeFromParent()])
        run(sequence)
        
    }
}
