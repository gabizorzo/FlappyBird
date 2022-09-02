//
//  GameScene.swift
//  FlappyBird
//
//  Created by Gabriela Zorzo on 01/09/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Time
    private var lastCurrentTime: Double = -1
    
    // MARK: - Game
    
    private var didStartGame: Bool = false
    private var score: Int = 0
    private var outsidePipe: Bool = true
    private var isGameOver: Bool = false
    
    // MARK: - Nodes
    
    private var background: SKSpriteNode = SKSpriteNode()
    private var bird: SKSpriteNode = SKSpriteNode()
    
    // MARK: - Labels Nodes
    
    private var startLabel: SKLabelNode = SKLabelNode()
    private var gameLabel: SKLabelNode = SKLabelNode()
    private var scoreLabel: SKLabelNode = SKLabelNode()
    private var gameOverLabel: SKLabelNode = SKLabelNode()
    private var yourScoreLabel: SKLabelNode = SKLabelNode()
    private var restartLabel: SKLabelNode = SKLabelNode()
    private var highScoreLabel: SKLabelNode = SKLabelNode()
    private var yourHighScoreLabel: SKLabelNode = SKLabelNode()
    private var hsLabel: SKLabelNode = SKLabelNode()
    private var hsTextLabel: SKLabelNode = SKLabelNode()
    
    // MARK: - Animation
    
    private var birdFlyingFrames: [SKTexture] = []
    
    // MARK: - Collision
    
    let birdCategory: UInt32 = 1 << 3
    let pipeCategory: UInt32 = 1 << 2
    let floorCategory: UInt32 = 1 << 1
    
    // MARK: - Init
    
    override func didMove(to view: SKView) {
        
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        createBackground()
        createBird()
        animateBird()
        createFloor()
        createLabel()
        createHighScoreLabel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.view?.addGestureRecognizer(tapGesture)
        
        physicsWorld.contactDelegate = self
        
    }
    
    // MARK: - Handlers
    
    @objc func tap() {
        if didStartGame {
            jump()
        } else {
            gameLabel.removeFromParent()
            startLabel.removeFromParent()
            hsLabel.removeFromParent()
            hsTextLabel.removeFromParent()
            createScoreLabel()
            setPhysics()
            didStartGame = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            let newScene = GameScene(size: self.size)
                newScene.scaleMode = self.scaleMode
                let animation = SKTransition.fade(withDuration: 1.0)
                self.view?.presentScene(newScene, transition: animation)
                self.view?.isPaused = false
            
            isGameOver = false
        }
    }
    
    
    func jump() {
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 15.0))
    }
    
    // MARK: - Physics
    
    func setPhysics() {
        let birdPhysicsBody = SKPhysicsBody(rectangleOf: bird.frame.size)
        birdPhysicsBody.isDynamic = true
        birdPhysicsBody.affectedByGravity = true
        birdPhysicsBody.restitution = 0
        birdPhysicsBody.usesPreciseCollisionDetection = true
        birdPhysicsBody.categoryBitMask = birdCategory
        birdPhysicsBody.collisionBitMask = birdCategory | pipeCategory | floorCategory
        birdPhysicsBody.contactTestBitMask = birdCategory | pipeCategory | floorCategory
        bird.physicsBody = birdPhysicsBody
        
        let floor = SKSpriteNode(color: .clear, size: CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!*0.15))
        floor.position = CGPoint(x: 0, y: -((self.scene?.size.height)! / 2))
        floor.zPosition = 0
        
        let floorPhysicsBody = SKPhysicsBody(rectangleOf: floor.frame.size)
        floorPhysicsBody.isDynamic = false
        floorPhysicsBody.affectedByGravity = false
        floorPhysicsBody.usesPreciseCollisionDetection = true
        floorPhysicsBody.categoryBitMask = floorCategory
        floor.physicsBody = floorPhysicsBody
        
        let ceiling = SKSpriteNode(color: .clear, size: CGSize(width: (self.scene?.size.width)!, height: (self.scene?.size.height)!*0.15))
        ceiling.position = CGPoint(x: 0, y: ((self.scene?.size.height)! / 2))
        ceiling.zPosition = 0
        
        let ceilingPhysicsBody = SKPhysicsBody(rectangleOf: ceiling.frame.size)
        ceilingPhysicsBody.isDynamic = false
        ceiling.physicsBody = ceilingPhysicsBody
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        
        addChild(floor)
        addChild(ceiling)
    }
    
    // MARK: - Collision
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == birdCategory) &&
            (contact.bodyB.categoryBitMask == pipeCategory) {
            gameOver()
        } else if (contact.bodyA.categoryBitMask == birdCategory) &&
                    (contact.bodyB.categoryBitMask == floorCategory) {
            gameOver()
        }
    }
    
    // MARK: - Speed
    func defineSpeed() -> CGFloat {
        if score > 10 {
            return 4.0
        } else if score > 6 {
            return 3.5
        } else if score > 3 {
            return 3.0
        }
        return 2.0
    }
    
    // MARK: - Time
    func defineTime() -> CGFloat {
        if score > 10 {
            return 1.6
        } else if score > 6 {
            return 1.7
        } else if score > 3 {
            return 2.25
        }
        return 2.5
    }
    
    // MARK: - Background and Floor
    
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
    
    func moveGrounds() {
        self.enumerateChildNodes(withName: "Background") { node, error in
            node.position.x -= self.defineSpeed()
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
        self.enumerateChildNodes(withName: "Floor") { node, error in
            node.position.x -= self.defineSpeed()
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
    }
    
    // MARK: - Bird
    
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
        
        let birdSize = CGSize(width: 40, height: 40)
        bird.size = birdSize
        
        let birdPosition = CGPoint(x: -((self.scene?.size.width)! / 2) * 0.6, y: 0)
        bird.position = birdPosition
        bird.zPosition = 0.8
        
        addChild(bird)
    }
    
    func animateBird() {
        bird.run(SKAction.repeatForever(SKAction.animate(with: birdFlyingFrames, timePerFrame: 0.1, resize: false, restore: true)),withKey: "FlyingInPlaceBird")
    }
    
    // MARK: - Labels
    
    func createLabel() {
        gameLabel.attributedText = NSAttributedString(string: "FlappyChicken",
                                                      attributes: [.font: UIFont.systemFont(ofSize: 40, weight: .semibold),
                                                                   .foregroundColor: UIColor.white])
        startLabel.attributedText = NSAttributedString(string: "Tap to start",
                                                       attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .light),
                                                                   .foregroundColor: UIColor.white])
        
        let gamePosition = CGPoint(x: 0, y: 60)
        gameLabel.position = gamePosition
        gameLabel.zPosition = 1
        
        let startPosition = CGPoint(x: 0, y: 0)
        startLabel.position = startPosition
        startLabel.zPosition = 1
        
        addChild(gameLabel)
        addChild(startLabel)
    }
    
    func createScoreLabel() {
        scoreLabel.attributedText = NSAttributedString(string: "0",
                                                       attributes: [.font: UIFont.systemFont(ofSize: 35, weight: .semibold),
                                                                   .foregroundColor: UIColor.white])
        
        let scorePosition = CGPoint(x: 0, y: 120)
        scoreLabel.position = scorePosition
        scoreLabel.zPosition = 1
        
        addChild(scoreLabel)
    }
    
    func createHighScoreLabel() {
        hsTextLabel.attributedText = NSAttributedString(string: "High score:",
                                                        attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                                                                    .foregroundColor: UIColor.white])
        hsLabel.attributedText = NSAttributedString(string: "\(GameDataBase.standard.getHighScore())",
                                                    attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold),
                                                                .foregroundColor: UIColor.white])
        
        let hsTextPosition = CGPoint(x: -(self.scene?.size.width)!/2 + 70, y: (self.scene?.size.height)!/2 * 0.85)
        hsTextLabel.position = hsTextPosition
        hsTextLabel.zPosition = 1
        
        let hsPosition = CGPoint(x: -(self.scene?.size.width)!/2 + 70, y: (self.scene?.size.height)!/2 * 0.77)
        hsLabel.position = hsPosition
        hsLabel.zPosition = 1
        
        addChild(hsTextLabel)
        addChild(hsLabel)
    }
    
    func createGameOverLabel() {
        gameOverLabel.attributedText = NSAttributedString(string: "Game Over!",
                                                          attributes: [.font: UIFont.systemFont(ofSize: 35, weight: .regular),
                                                                      .foregroundColor: UIColor.white])
        
        yourScoreLabel.attributedText = NSAttributedString(string: "Your score was:",
                                                           attributes: [.font: UIFont.systemFont(ofSize: 30, weight: .regular),
                                                                       .foregroundColor: UIColor.white])
        
        yourHighScoreLabel.attributedText = NSAttributedString(string: "The high score is:",
                                                              attributes: [.font: UIFont.systemFont(ofSize: 30, weight: .regular),
                                                                          .foregroundColor: UIColor.white])
        highScoreLabel.attributedText = NSAttributedString(string: "\(GameDataBase.standard.getHighScore())",
                                                           attributes: [.font: UIFont.systemFont(ofSize: 35, weight: .semibold),
                                                                       .foregroundColor: UIColor.white])
        
        restartLabel.attributedText = NSAttributedString(string: "Tap to restart",
                                                           attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .light),
                                                                       .foregroundColor: UIColor.white])
        
        
        let gameOverPosition = CGPoint(x: 0, y: 120)
        gameOverLabel.position = gameOverPosition
        gameOverLabel.zPosition = 1
        
        let yourScorePosition = CGPoint(x: 0, y: 60)
        yourScoreLabel.position = yourScorePosition
        yourScoreLabel.zPosition = 1
        
        self.scoreLabel.position = CGPoint(x: 0, y: 20)
        
        let yourHScorePosition = CGPoint(x: 0, y: -20)
        yourHighScoreLabel.position = yourHScorePosition
        yourHighScoreLabel.zPosition = 1
        
        let highScorePosition = CGPoint(x: 0, y: -60)
        highScoreLabel.position = highScorePosition
        highScoreLabel.zPosition = 1
        
        let restartPosition = CGPoint(x: 0, y: -120)
        restartLabel.position = restartPosition
        restartLabel.zPosition = 1
        
        addChild(gameOverLabel)
        addChild(yourScoreLabel)
        addChild(yourHighScoreLabel)
        addChild(highScoreLabel)
        addChild(restartLabel)
    }
    
    // MARK: - Pipes
    
    func createTopPipe(sizeTop: Int) {
        let topPipe = SKSpriteNode(imageNamed: "Pipe")
        topPipe.name = "TopPipe"
        
        let pipeHeight = (self.scene?.size.height)!
        
        let pipeSize = CGSize(width: 83, height: pipeHeight)
        topPipe.size = pipeSize
        
        topPipe.physicsBody = SKPhysicsBody(rectangleOf: topPipe.frame.size)
        topPipe.physicsBody!.affectedByGravity = false
        topPipe.physicsBody!.isDynamic = false
        
        topPipe.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let yInf = Int((self.scene?.size.height)!)/2 - sizeTop
        let yPipe = yInf + Int(pipeHeight/2)
        let xPipe = (self.scene?.size.width)!/2 + 42
        topPipe.position.x = xPipe
        topPipe.position.y = CGFloat(yPipe)
        topPipe.zPosition = 0.8
        
        addChild(topPipe)
    }
    
    func createBottomPipe(sizeBottom: Int) {
        let bottomPipe = SKSpriteNode(imageNamed: "Pipe")
        bottomPipe.name = "BottomPipe"
        
        let pipeHeight = (self.scene?.size.height)!
        
        let pipeSize = CGSize(width: 83, height: pipeHeight)
        bottomPipe.size = pipeSize
        
        bottomPipe.physicsBody = SKPhysicsBody(rectangleOf: bottomPipe.frame.size)
        bottomPipe.physicsBody!.affectedByGravity = false
        bottomPipe.physicsBody!.isDynamic = false
        
        bottomPipe.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        bottomPipe.yScale = bottomPipe.yScale * -1
        
        let yInf = -Int((self.scene?.size.height)!)/2 + sizeBottom
        let yPipe = yInf - Int(pipeHeight/2)
        let xPipe = (self.scene?.size.width)!/2 + 42
        bottomPipe.position.x = xPipe
        bottomPipe.position.y = CGFloat(yPipe)
        bottomPipe.zPosition = 0.8
        
        addChild(bottomPipe)
    }
    
    func movePipes() {
        self.enumerateChildNodes(withName: "TopPipe") { node, error in
            node.position.x -= self.defineSpeed()
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
        self.enumerateChildNodes(withName: "BottomPipe") { node, error in
            node.position.x -= self.defineSpeed()
            if node.position.x < -((self.scene?.size.width)!) {
                node.position.x += ((self.scene?.size.width)! * 3)
            }
        }
        
    }
    
    func setPipesPhysics() {
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
    }
    
    func removePipes() {
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
    
    // MARK: - Score
    
    func updateScore() {
        self.enumerateChildNodes(withName: "TopPipe") { node, error in
            if self.outsidePipe {
                if node.position.x - 41 <= self.bird.position.x && self.bird.position.x <= node.position.x + 41 {
                    self.outsidePipe = false
                }
            } else if self.bird.position.x >= node.position.x + 41 {
                self.score += 1
                self.scoreLabel.attributedText = NSAttributedString(string: "\(self.score)",
                                                                    attributes: [.font: UIFont.systemFont(ofSize: 35, weight: .semibold),
                                                                                .foregroundColor: UIColor.white])
                self.outsidePipe = true
            }
        }
    }
    
    // MARK: - Game Over
    
    func gameOver() {
        GameDataBase.standard.setHighScore(newHighScore: score)
        
        createGameOverLabel()
        isGameOver = true
        scene?.view?.isPaused = true
        sleep(1)
    }
    
    // MARK: - Update
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if lastCurrentTime == -1 {
            lastCurrentTime = currentTime
        }
        
        let deltaTime = currentTime - lastCurrentTime
        
        moveGrounds()
        
        if didStartGame {
            
            if deltaTime > defineTime() {
                let maxTop = (self.scene?.size.height)! - self.bird.size.height*3.5 - (self.scene?.size.height)!*0.15
                let topValue = Int.random(in: Int((self.scene?.size.height)!*0.15)..<Int(maxTop))
                let bottomValue = Int(maxTop) - topValue + Int((self.scene?.size.height)!*0.15)
                
                createTopPipe(sizeTop: topValue)
                createBottomPipe(sizeBottom: bottomValue)
                
                lastCurrentTime = currentTime
            }
            movePipes()
        }
        
        setPipesPhysics()
        
        removePipes()
        
        updateScore()

    }
}

