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
    var enemySpeed:Double
    var enemyType:EnemyTypes
    
    init(enemyScale:Double,enemySpeed:Double) {
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
            case 1: fishId = "fishTile_074"; self.enemyType = .pinkFish
            case 2: fishId = "fishTile_076"; self.enemyType = .blueFish
            case 3: fishId = "fishTile_080"; self.enemyType = .orangeFish
            case 4: fishId = "fishTile_102"; self.enemyType = .grayFish
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
        
        configureMovement(type: self.enemyType)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureMovement(type: EnemyTypes) {
        
        let path = UIBezierPath()
        path.move(to: .zero)
        
        if type == .grayFish {
            let zigZagX = UIScreen.main.bounds.width / 5
            path.addLine(to: CGPoint(x: zigZagX, y: -zigZagX * 2))
            path.addLine(to: CGPoint(x: -zigZagX, y: -zigZagX * 4))
            path.addLine(to: CGPoint(x: zigZagX, y: -zigZagX * 6))
            path.addLine(to: CGPoint(x: -zigZagX, y: -zigZagX * 8))
            path.addLine(to: CGPoint(x: zigZagX, y: -zigZagX * 10))
        }
        if type == .redFish {
            self.enemyScale *= 1.25
            self.enemySpeed *= 0.75
        }
        if type == .orangeFish {
            self.enemyScale *= 0.75
            self.enemySpeed *= 0.75
        }
        if type == .blueFish {
            let startYBias:CGFloat = 200
            
            path.addCurve(to: CGPoint(x: 0, y: (-UIScreen.main.bounds.height - startYBias)/2),
                          controlPoint1: CGPoint(x: -UIScreen.main.bounds.width*0.33, y: (-UIScreen.main.bounds.height - startYBias) * 0.125),
                          controlPoint2: CGPoint(x: UIScreen.main.bounds.width*0.33, y: (-UIScreen.main.bounds.height - startYBias) * 0.375))
            
            path.addCurve(to: CGPoint(x: 0, y: -UIScreen.main.bounds.height - startYBias),
                          controlPoint1: CGPoint(x: -UIScreen.main.bounds.width*0.33, y: (-UIScreen.main.bounds.height - startYBias) * 0.625),
                          controlPoint2: CGPoint(x: UIScreen.main.bounds.width*0.33, y: (-UIScreen.main.bounds.height - startYBias) * 0.825))
        }
        
        path.addLine(to: CGPoint(x: 0, y: -10000))
        
        let movement = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: CGFloat(enemySpeed))
        let sequence = SKAction.sequence([movement,.removeFromParent()])
        run(sequence)
        
    }
}
