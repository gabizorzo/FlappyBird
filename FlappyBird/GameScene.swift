//
//  GameScene.swift
//  FlappyBird
//
//  Created by Gabriela Zorzo on 01/09/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var lastCurrentTime: Double = -1
    
    private var didStartGame: Bool = false
    
    // MARK: - Nodes
    
    private var background: SKSpriteNode = SKSpriteNode()
    private var bird: SKSpriteNode = SKSpriteNode()
    private var startLabel: SKLabelNode = SKLabelNode()
    private var gameLabel: SKLabelNode = SKLabelNode()
    
    // MARK: - Animation
    
    private var birdFlyingFrames: [SKTexture] = []
    
    // MARK: - Collision
    
    let birdCategory: UInt32 = 1 << 2
    let pipeCategory: UInt32 = 1 << 1
    
    // MARK: - Init
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        createBackground()
        createBird()
        animateBird()
        createFloor()
        createLabel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(jump))
        self.view?.addGestureRecognizer(tapGesture)
        
        physicsWorld.contactDelegate = self
        
    }
    
    // MARK: - Handlers
    
    @objc func jump() {
        if didStartGame {
            bird.physicsBody?.isDynamic = false
            bird.physicsBody?.isDynamic = true
            bird.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 10.0))
        } else {
            gameLabel.removeFromParent()
            startLabel.removeFromParent()
            setPhysics()
            didStartGame = true
        }
    }
    
    // MARK: - Functions
    
    func setPhysics() {
        let birdPhysicsBody = SKPhysicsBody(rectangleOf: bird.frame.size)
        birdPhysicsBody.isDynamic = true
        birdPhysicsBody.affectedByGravity = true
        birdPhysicsBody.restitution = 0
        birdPhysicsBody.usesPreciseCollisionDetection = true
        birdPhysicsBody.categoryBitMask = birdCategory
        birdPhysicsBody.collisionBitMask = birdCategory | pipeCategory
        birdPhysicsBody.contactTestBitMask = birdCategory | pipeCategory
        bird.physicsBody = birdPhysicsBody
        
        let floor = SKSpriteNode(color: .clear, size: CGSize(width: (self.scene?.size.width)!, height: 130.0))
        floor.position = CGPoint(x: 0, y: -((self.scene?.size.height)! / 2))
        floor.zPosition = 0
        
        let floorPhysicsBody = SKPhysicsBody(rectangleOf: floor.frame.size)
        floorPhysicsBody.isDynamic = false
        floor.physicsBody = floorPhysicsBody
        
        let ceiling = SKSpriteNode(color: .clear, size: CGSize(width: (self.scene?.size.width)!, height: 130.0))
        ceiling.position = CGPoint(x: 0, y: ((self.scene?.size.height)! / 2))
        ceiling.zPosition = 0
        
        let ceilingPhysicsBody = SKPhysicsBody(rectangleOf: ceiling.frame.size)
        ceilingPhysicsBody.isDynamic = false
        ceiling.physicsBody = ceilingPhysicsBody
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        
        addChild(floor)
        addChild(ceiling)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("didBegin")
        
        if (contact.bodyA.categoryBitMask == birdCategory) &&
            (contact.bodyB.categoryBitMask == pipeCategory) {

            print("Hit")
        }
    }
    
    func createBackground() {
        for index in 0...3 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.name = "Background"
            
            let backgroundSize = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
            background.size = backgroundSize
            
            let backgroundPosition = CGPoint(x: (CGFloat(index) * (self.scene?.size.width)!), y: 0)
            background.position = backgroundPosition
            
            addChild(background)
        }
    }
    
    func createFloor() {
        for index in 0...3 {
            let floor = SKSpriteNode(imageNamed: "Floor")
            floor.name = "Floor"
            
            let floorSize = CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!)
            floor.size = floorSize
            
            let floorPosition = CGPoint(x: (CGFloat(index) * (self.scene?.size.width)!), y: 0)
            floor.position = floorPosition
            floor.zPosition = 0.9
            
            addChild(floor)
        }
    }
    
    func createBird() {
        let birdAnimatedAtlas = SKTextureAtlas(named: "Bird")
        var flyFrames: [SKTexture] = []
        
        let numImages = birdAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let birdTextureName = "Bird\(i)"
            flyFrames.append(birdAnimatedAtlas.textureNamed(birdTextureName))
        }
        
        birdFlyingFrames = flyFrames
        
        let firstFrameTexture = birdFlyingFrames[0]
        bird = SKSpriteNode(texture: firstFrameTexture)
        
        let birdSize = CGSize(width: 35, height: 35)
        bird.size = birdSize
        
        let birdPosition = CGPoint(x: -((self.scene?.size.width)! / 2) * 0.6, y: 0)
        bird.position = birdPosition
        bird.zPosition = 0.8
        
        addChild(bird)
    }
    
    func animateBird() {
        bird.run(SKAction.repeatForever(SKAction.animate(with: birdFlyingFrames, timePerFrame: 0.1, resize: false, restore: true)),withKey: "FlyingInPlaceBird")
    }
    
    func createLabel() {
        gameLabel.text = "Almost FlappyBird"
        startLabel.text = "Tap to start"

        gameLabel.fontSize = 40
        startLabel.fontSize = 25
        
        let gamePosition = CGPoint(x: 0, y: 60)
        gameLabel.position = gamePosition
        gameLabel.zPosition = 1
        
        let startPosition = CGPoint(x: 0, y: 0)
        startLabel.position = startPosition
        startLabel.zPosition = 1
        
        addChild(gameLabel)
        addChild(startLabel)
    }
    
    func createTopPipe(yPosition: Int) {
        let topPipe = SKSpriteNode(imageNamed: "Pipe")
        topPipe.name = "TopPipe"
        
        let pipeSize = CGSize(width: 83, height: 628)
        topPipe.size = pipeSize
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.frame.size)
        topPipe.physicsBody!.affectedByGravity = false
        topPipe.physicsBody!.isDynamic = false
        
        topPipe.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let y = CGFloat(yPosition)
        let pipePosition = CGPoint(x: ((self.scene?.size.width)!)/2 + 42, y: y)
        topPipe.position = pipePosition
        topPipe.zPosition = 0.8
        
        addChild(topPipe)
    }
    
    func createBottomPipe(yPosition: Int) {
        let bottomPipe = SKSpriteNode(imageNamed: "Pipe")
        bottomPipe.name = "BottomPipe"
        
        let pipeSize = CGSize(width: 83, height: 628)
        bottomPipe.size = pipeSize
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.frame.size)
        bottomPipe.physicsBody!.affectedByGravity = false
        bottomPipe.physicsBody!.isDynamic = false
        
        bottomPipe.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        bottomPipe.yScale = bottomPipe.yScale * -1
        
        let y = CGFloat(yPosition)
        let pipePosition = CGPoint(x: ((self.scene?.size.width)!)/2 + 42, y: -y)
        bottomPipe.position = pipePosition
        bottomPipe.zPosition = 0.8
        
        addChild(bottomPipe)
    }
    
    func moveGrounds() {
        self.enumerateChildNodes(withName: "Background") { node, error in
            node.position.x -= 2
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
        self.enumerateChildNodes(withName: "Floor") { node, error in
            node.position.x -= 2
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
        self.enumerateChildNodes(withName: "TopPipe") { node, error in
            node.position.x -= 2
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
        self.enumerateChildNodes(withName: "BottomPipe") { node, error in
            node.position.x -= 2
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
    }
    
    
    
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if lastCurrentTime == -1 {
            lastCurrentTime = currentTime
        }
        
        let deltaTime = currentTime - lastCurrentTime
       
        
        moveGrounds()
        
        if deltaTime > 2.5 {
            let maxTop = (self.scene?.size.height)! - 80 - 200
            let topValue = Int.random(in: 230..<Int(maxTop))
            let bottomValue = Int(maxTop) + 200 - topValue
            
            createTopPipe(yPosition: topValue)
            createBottomPipe(yPosition: bottomValue)
            
            lastCurrentTime = currentTime
        }
        
        self.enumerateChildNodes(withName: "TopPipe") { node, error in
            guard let body = node.physicsBody else { return }
                body.usesPreciseCollisionDetection = true
                body.categoryBitMask = self.pipeCategory
        }

        self.enumerateChildNodes(withName: "BottomPipe") { node, error in
            guard let body = node.physicsBody else { return }
                body.usesPreciseCollisionDetection = true
                body.categoryBitMask = self.pipeCategory
        }
        
        self.enumerateChildNodes(withName: "TopPipe") { node, error in
            if node.position.x <= -((self.scene?.size.width)!)/2 - 42{
                node.removeFromParent()
            }
        }
        
        self.enumerateChildNodes(withName: "BottomPipe") { node, error in
            if node.position.x <= -((self.scene?.size.width)!)/2 - 42 {
                node.removeFromParent()
            }
        }
    }
}

