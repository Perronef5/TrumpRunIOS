//
//  GameScene.swift
//  Flappy trump
//
//  Created by Rob Percival on 05/07/2016.
//  Copyright © 2016 Appfish. All rights reserved.
//

import SpriteKit
import GameplayKit

class TrumpRunScene: SKScene, SKPhysicsContactDelegate {
    
    var trump = SKSpriteNode()
    var scoreLabel = SKLabelNode(fontNamed:"PhosphateInline")
    var gameOverLabel = SKLabelNode(fontNamed:"Helvetica")
    var score = 0
    var timer = Timer()
    var gameStarted = false
    var pauseNode = SKSpriteNode()
    var pauseButton = UIButton()
    var pauseChildren: [SKNode] = []
    var pauseButtonTouched = false
    
    var bg = SKSpriteNode()
    
    enum ColliderType: UInt32{
        
        case Trump = 1
        case Object = 2
        case Ground = 4
        case Gap = 8
    }
    
    var gameOver = false
    var jumpCounter = 0
    var speedVariable: CGFloat = -2.0
    
    override func sceneDidLoad() {
        
        let pauseTexture = SKTexture(image: #imageLiteral(resourceName: "pause_button"))
        pauseNode = SKSpriteNode(texture: pauseTexture )
        
        pauseNode.position = CGPoint(x: (-self.frame.width/2) + 80, y: (self.frame.height/2) - 80)
        pauseNode.name = "pauseButton"
        self.addChild(pauseNode)
        
    }
    
    @objc func makewalls() {
        
        let movewalls = SKAction.move(by: CGVector(dx: speedVariable * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removewalls = SKAction.removeFromParent()
        let moveAndRemovewalls = SKAction.sequence([movewalls, removewalls])
        
        
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        
        let wallOffset = CGFloat(movementAmount) - self.frame.height / 4
        
//        let wallTexture = SKTexture(imageNamed: "wall_wall.png")
        
        let wallTexture = SKTexture(imageNamed: "brick_wall.png")
        
        let wall2 = SKSpriteNode(texture: wallTexture)
        
//        let gapHeight = trump.size.height
        
        wall2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - (wallTexture.size().height / 1.5) + wallOffset)
        
        wall2.run(moveAndRemovewalls)
        
        wall2.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
        
        wall2.physicsBody!.isDynamic = false
        
        wall2.physicsBody!.contactTestBitMask = ColliderType.Trump.rawValue
        wall2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        wall2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(wall2)

        let gap = SKSpriteNode.init(color: UIColor.clear, size: CGSize(width: wallTexture.size().width, height: wallTexture.size().height))
//        gap.color = UIColor.green
        
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + wallOffset)
        
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wall2.size.width, height: wallTexture.size().height))
        print(wallOffset)
        print(gap.frame)
        
        gap.physicsBody?.isDynamic = false
        
        gap.run(moveAndRemovewalls)

        gap.physicsBody!.contactTestBitMask = ColliderType.Trump.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Trump.rawValue
        
        self.addChild(gap)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if gameOver == false {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            
            score += 1
            scoreLabel.text = String(score)
            speedVariable -= 0.5
            
        } else if contact.bodyA.categoryBitMask == ColliderType.Ground.rawValue || contact.bodyB.categoryBitMask == ColliderType.Ground.rawValue {
            jumpCounter = 0
        } else {
            
            self.speed = 0
            jumpCounter = 0
            speedVariable = -2.0
            gameOver = true
            gameStarted = false
            timer.invalidate()
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over. Tap to play again."
            gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            gameOverLabel.fontColor = UIColor.black
            self.insertChild(gameOverLabel, at: self.children.count - 1)
            
        }
            
        }
        
    }
    
    
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        setupGame()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
      let touch:UITouch = touches.first! as UITouch
      let positionInScene = touch.location(in: self)
      let touchedNode = self.atPoint(positionInScene)
      var resumeClicked = false
        
        if let name = touchedNode.name
        {
            if name == "pauseButton"
            {
                print("pause Button touched")
                trump.physicsBody?.isDynamic = false
                self.speed = 0
                setupPauseScreen()
                pauseButtonTouched = true
            } else if name == "resumeButton" || name == "resumeLabel" {
                trump.physicsBody?.isDynamic = true
                removePauseScreen()
                pauseButtonTouched = false
                resumeClicked = true
            } else if name == "restartButton" || name == "restartLabel" {
                removePauseScreen()
                gameOver = false
                score = 0
                self.children.filter { $0.name != "pauseButton" }.forEach { $0.removeFromParent() }
                setupGame()
                self.speed = 1
                trump.physicsBody?.isDynamic = true
                pauseButtonTouched = false
                resumeClicked = true
            } else if name == "quitButton" || name == "quitLabel" {
                let vc = self.view?.window?.rootViewController
                if let nav = vc?.navigationController {
                    nav.popViewController(animated: true)
                } else {
                    vc?.dismiss(animated: false, completion: nil)
                }
            }
        }

        if pauseButtonTouched == false && resumeClicked == false {
            
            if gameStarted == false {
                timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makewalls), userInfo: nil, repeats: true)
                gameStarted = true
            }
        
            if gameOver == false {
               
                if jumpCounter < 5 {
                
                    trump.physicsBody?.isDynamic = true
                    trump.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                    trump.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 80))
                    jumpCounter += 1
                }
                
            } else {
                gameOver = false
                score = 0
                self.speed = 1
                self.children.filter { $0.name != "pauseButton" }.forEach { $0.removeFromParent() }
                setupGame()
                trump.physicsBody?.isDynamic = true
            }
            
        }
        
    }
    
    func setupPauseScreen() {
        
        let restartButton = SKShapeNode(rect: CGRect(x: -self.frame.width/4, y: -70, width: self.frame.width/2, height: 140), cornerRadius: 6)
        restartButton.fillColor = UIColor.black
        restartButton.name = "restartButton"
        
        let restartLabel = SKLabelNode(fontNamed:"Helvetica Bold")
        restartLabel.fontSize = 36
        restartLabel.text = "RESTART"
        restartLabel.position = CGPoint(x: 0, y: (restartButton.frame.height/2) - (restartLabel.frame.height/2) - 70)
        restartLabel.name = "restartLabel"
        
        let resumeButton = SKShapeNode(rect: CGRect(x: -self.frame.width/4, y: restartButton.frame.height - 40, width: self.frame.width/2, height: 140), cornerRadius: 6)
        resumeButton.fillColor = UIColor.black
        resumeButton.name = "resumeButton"
        
        let resumeLabel = SKLabelNode(fontNamed:"Helvetica Bold")
        resumeLabel.fontSize = 36
        resumeLabel.text = "RESUME"
        resumeLabel.position = CGPoint(x: 0, y: resumeButton.frame.height + (resumeButton.frame.height/2) - (resumeLabel.frame.height/2) - 40)
        resumeLabel.name = "resumeLabel"
        
        let quitButton = SKShapeNode(rect: CGRect(x: -self.frame.width/4, y: -restartButton.frame.height - 40 - restartButton.frame.height/2, width: self.frame.width/2, height: 140), cornerRadius: 6)
        quitButton.fillColor = UIColor.black
        quitButton.name = "quitButton"
        
        let quitLabel = SKLabelNode(fontNamed:"Helvetica Bold")
        quitLabel.fontSize = 36
        quitLabel.text = "QUIT"
        let y = -quitButton.frame.height - (quitButton.frame.height/2) + (quitLabel.frame.height/2)
        quitLabel.position = CGPoint(x: 0, y: y)
        quitLabel.name = "quitLabel"
       
        restartButton.addChild(restartLabel)
        self.addChild(restartButton)
        resumeButton.addChild(resumeLabel)
        self.addChild(resumeButton)
        quitButton.addChild(quitLabel)
        self.addChild(quitButton)
        
        pauseChildren.append(restartButton)
        pauseChildren.append(resumeButton)
        pauseChildren.append(quitButton)

    }
    
    func removePauseScreen() {
        self.removeChildren(in: pauseChildren)
        self.speed = 1
        pauseChildren = []
    }
    
    func setupGame() {
        let bgTexture = SKTexture(imageNamed: "desert_BG.png")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i: CGFloat = 0
        
        while i < 3 {
            
            bg = SKSpriteNode(texture: bgTexture)
            
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            
            bg.size.height = self.frame.height
            
            bg.run(moveBGForever)
            
            bg.zPosition = -1
            
            self.addChild(bg)
            
            i += 1
        }
        
        
        let trumpTexture = SKTexture(imageNamed: "trump_running1.png")
        let trumpTexture2 = SKTexture(imageNamed: "trump_running2.png")
        
        let animation = SKAction.animate(with: [trumpTexture, trumpTexture2], timePerFrame: 0.1)
        let maketrumpFlap = SKAction.repeatForever(animation)
        
        trump = SKSpriteNode(texture: trumpTexture)
        
        trump.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 3.5)
        
        trump.run(maketrumpFlap)
        
        trump.physicsBody = SKPhysicsBody(circleOfRadius: trumpTexture.size().height / 8)
        
        trump.physicsBody?.isDynamic = false
        
        trump.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        trump.physicsBody!.contactTestBitMask = ColliderType.Gap.rawValue
        trump.physicsBody!.categoryBitMask = ColliderType.Trump.rawValue
        trump.physicsBody!.collisionBitMask = ColliderType.Ground.rawValue
        
        self.addChild(trump)
        
        // Right wall
        //        node = [SKNode node];
        //        node.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(CGRectGetWidth(self.frame) - 1.0f, 0.0f, 1.0f, CGRectGetHeight(self.view.frame))];
        //        [self addChild:node];
        
        let ground = SKSpriteNode()
        ground.color = UIColor.red
        ground.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: self.frame.width, height: 10))
        ground.physicsBody?.categoryBitMask = ColliderType.Ground.rawValue
        
        ground.position = CGPoint(x: 0, y: (-self.frame.height / 3.5) - 40)
        
        //        let ground = SKNode()
        //
        //        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2.28)
        //
        //        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        //
        //        ground.physicsBody!.isDynamic = false
        //
        ground.physicsBody!.contactTestBitMask = ColliderType.Trump.rawValue
        //        ground.physicsBody!.categoryBitMask = ColliderType.Ground.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Trump.rawValue
        
        
        self.addChild(ground)
        
        //        scoreLabel.fontName = "6809-chargen"
        scoreLabel.fontSize = 100
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 200)
        scoreLabel.fontColor = UIColor.black
        self.addChild(scoreLabel)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    
}

