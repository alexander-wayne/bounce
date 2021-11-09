//
//  GameScene.swift
//  Bounce
//
//  Created by Alex Wayne on 4/4/20.
//  Copyright © 2020 Wayne Apps. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion
import AudioToolbox

enum GameState {
    case playing
    case menu
    static var current = GameState .playing
}

struct pc {
    static let none: UInt32 = 0x1 << 0
    static let paddle: UInt32 = 0x1 << 1
    static let ball: UInt32 = 0x1 << 2
    static let item: UInt32 = 0x1 << 3
    static let top: UInt32 = 0x1 << 4
    static let ballCheck: UInt32 = 0x1 << 5
    static let enemy: UInt32 = 0x1 << 6
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var grids = false;
    
    public var controller = GameViewController()
    
    var helpView = UIView()
    
    var helpMenu = SKShapeNode()
    var htp = SKLabelNode(text: "How to Play")
    var help1 = SKLabelNode(text: "Tilt your phone to move the ball")
    var help2 = SKLabelNode(text: "Dont let the ball get past the paddle")
    var help3 = SKLabelNode(text: "Don't let the ball leave the screen entirely")
    var help4 = SKLabelNode(text: "Avoid the red squares!")
    
    var ball = SKSpriteNode(imageNamed: "ball")
    
    var pBall = SKShapeNode()
    
    var paddle = SKSpriteNode(imageNamed: "paddle")
    
    var pPaddle = SKShapeNode()
    
    var top = SKShapeNode()
    var right = SKShapeNode()
    var left = SKShapeNode()
    var bottom = SKShapeNode()
    
    var ballTooLow = false
    
    var ballSpeed: CGFloat = 10
    var paddleSpeed: CGFloat = 4
    
    var goingDown = true
    var goingRight = true
    
    var score: Int = 0
    let scoreLabel = SKLabelNode(text: "0")
        
    var canScore = true
    
    var gameOver = false
    var gameOverMenu = SKShapeNode()
    let gameOverText = SKLabelNode(text: "Game Over")
    let restartText = SKLabelNode(text: "tap to restart")
    let gameOverScore = SKLabelNode(text: "Score: 0")
    let highScoreLabel = SKLabelNode(text: "Highscore: 0")
    
    let outlineAttrib = [
    NSAttributedString.Key.strokeColor : UIColor.black,
    NSAttributedString.Key.foregroundColor : UIColor.white,
    NSAttributedString.Key.strokeWidth : -4.0,
    NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 38)]
    as [NSAttributedString.Key : Any]
    
    var shouldShowAd = false
    
    var enemy = SKShapeNode()
    var enemy2 = SKShapeNode()
    var moveEnemy = false
    
    var center: CGPoint?
    
    var helpButton = SKSpriteNode()
    var shareButton = SKSpriteNode()
    
    private let motionManager = CMMotionManager()
    
    var canCloseHelp = false
    
    var pause = false
    
    @objc func tapScreen(){
        if canCloseHelp {
            if !helpView.isHidden{
                helpView.isHidden = true
            }
        }
        
    }
    
    func getHighScore() {
        
        
        
    }
    
    func newHighScore(){
        UserDefaults.standard.set(score, forKey:"HighScore")
        UserDefaults.standard.synchronize()
        
        highScoreLabel.attributedText = NSMutableAttributedString(string: "High Score: \(score)", attributes: outlineAttrib )

        highScoreLabel.fontColor = .yellow
    }
    
    
    func die(){
        
        ball.position = CGPoint(x: 3000, y: 3000)
        enemy.position = CGPoint(x: 4000, y: 3000)
        enemy2.position = CGPoint(x: 5000, y: 3000)
        
        gameOverScore.attributedText = NSMutableAttributedString(string: "Score: \(score)", attributes: outlineAttrib )
        let highscore: Int = UserDefaults.standard.object(forKey: "HighScore") as! Int
        if score > highscore {
            newHighScore()
        } else {
            highScoreLabel.attributedText = NSMutableAttributedString(string: "High Score: \(highscore)", attributes: outlineAttrib)
        }
        
        gameOver = true
        gameOverMenu.isHidden = false
        
        
        
//        ball.zPosition = -10
//        enemy.zPosition = -10
//        enemy2.zPosition = -10
        
        if score >= 5 {
            shouldShowAd = true
        }
    }
    
    func Pause(){
        ball.physicsBody?.velocity = CGVector.zero
    }
    
                //MARK: - Analyse the collision/contact set up.
        func checkPhysics() {

            // Create an array of all the nodes with physicsBodies
            var physicsNodes = [SKNode]()

            //Get all physics bodies
            enumerateChildNodes(withName: "//.") { node, _ in
                if let _ = node.physicsBody {
                    physicsNodes.append(node)
                } else {
                    print("\(node.name) does not have a physics body so cannot collide or be involved in contacts.")
                }
            }

    //For each node, check it's category against every other node's collion and contctTest bit mask
            for node in physicsNodes {
                let category = node.physicsBody!.categoryBitMask
                // Identify the node by its category if the name is blank
                let name = node.name != nil ? node.name : "Category \(category)"
                let collisionMask = node.physicsBody!.collisionBitMask
                let contactMask = node.physicsBody!.contactTestBitMask

                // If all bits of the collisonmask set, just say it collides with everything.
                if collisionMask == UInt32.max {
                    print("\(name) collides with everything")
                }

                for otherNode in physicsNodes {
                    if (node != otherNode) && (node.physicsBody?.isDynamic == true) {
                        let otherCategory = otherNode.physicsBody!.categoryBitMask
                        // Identify the node by its category if the name is blank
                        let otherName = otherNode.name != nil ? otherNode.name : "Category \(otherCategory)"

                        // If the collisonmask and category match, they will collide
                        if ((collisionMask & otherCategory) != 0) && (collisionMask != UInt32.max) {
                            print("\(name) collides with \(otherName)")
                        }
                        // If the contactMAsk and category match, they will contact
                        if (contactMask & otherCategory) != 0 {print("\(name) notifies when contacting \(otherName)")}
                    }
                }
            }
        }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        
        
        motionManager.startAccelerometerUpdates()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapScreen)))
        
        helpView = controller.getHelp()
        //helpView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapScreen)))

        
        center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            
        } else {
            
        }
        
        
        setupGame()
        checkPhysics()
        
    }
    
    func resetGame(){
        GameState.current = .playing
                
        goingDown = true
        goingRight = true
        ballTooLow = false
        
        score = 0
        
        gameOver = false
        gameOverMenu.isHidden = true
        
        shouldShowAd = false
        
        view?.backgroundColor = .black
        
        highScoreLabel.fontColor = .white

        
        ball.position = CGPoint(x: view!.frame.width / 2, y: view!.frame.height * 0.7)
        paddle.position = CGPoint(x: center!.x / 3, y: 100)
        enemy.position = CGPoint(x: 1000, y: 10000)
        enemy2.position = CGPoint(x: 10000, y: 10000)
              
        scoreLabel.attributedText = NSMutableAttributedString(string: "\(score)", attributes: outlineAttrib )

        paddleSpeed = 4
        
    }
    
    func resetGameWithHelp(){
        GameState.current = .playing
                
        goingDown = true
        goingRight = true
        ballTooLow = false
        
        score = 0
        
        gameOver = false
        gameOverMenu.isHidden = true
        
        helpMenu.isHidden = false
        
        shouldShowAd = false
        
        view?.backgroundColor = .black
        
        highScoreLabel.fontColor = .white

        
        ball.position = CGPoint(x: view!.frame.width / 2, y: view!.frame.height * 0.7)
        ball.physicsBody?.velocity = CGVector.zero
        paddle.position = CGPoint(x: center!.x / 3, y: 100)
        enemy.position = CGPoint(x: 1000, y: 10000)
        enemy2.position = CGPoint(x: 10000, y: 10000)
              
        scoreLabel.attributedText = NSMutableAttributedString(string: "\(score)", attributes: outlineAttrib )

        paddleSpeed = 4
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.canCloseHelp = true
        }
    }
    
    func setupGame(){
        GameState.current = .playing
        
        let helpView = controller.getHelp()
        helpView.isHidden = false
        
        anchorPoint = CGPoint(x: 0, y: 0)
        
        goingDown = true
        goingRight = true
        
        score = 0
        
        gameOver = false
        
        canCloseHelp = true
        
        view?.backgroundColor = .black
        
        if UserDefaults.standard.object(forKey: "HighScore") == nil {
            newHighScore()
        }
        

        
        ball.size.height = 50
        ball.size.width = 50
        ball.position = CGPoint(x: view!.frame.width / 2, y: view!.frame.height * 0.7)
        ball.zPosition = 2
        ball.color = .green
        
        
        ball.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "ball"), size: ball.frame.size)
        ball.physicsBody?.categoryBitMask = pc.ball
        ball.physicsBody?.contactTestBitMask = pc.paddle | pc.enemy | pc.top
        ball.physicsBody?.collisionBitMask = pc.paddle | pc.top | pc.enemy
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = false
        
        self.addChild(ball)
        
        paddle.size.width = 100
        paddle.size.height = 50
        paddle.position = CGPoint(x: center!.x, y: 100)
        paddle.zPosition = 2
        
        paddle.physicsBody = SKPhysicsBody(texture: SKTexture(imageNamed: "paddle"), size: paddle.frame.size)
        paddle.physicsBody?.categoryBitMask = pc.paddle
        paddle.physicsBody?.collisionBitMask = pc.ball
        paddle.physicsBody?.contactTestBitMask = pc.ball
        paddle.physicsBody?.isDynamic = false
        paddle.physicsBody?.affectedByGravity = false
        
        self.addChild(paddle)
        
        
        
        top = SKShapeNode(rectOf: CGSize(width: (view?.frame.width)! * 2, height: 4))
        top.fillColor = .black
        top.strokeColor = .clear
        top.position = CGPoint(x: (view?.frame.width)! / 2, y: (view?.frame.height)! - 10)
        top.zPosition = 2
        
        top.physicsBody = SKPhysicsBody(rectangleOf: top.frame.size)
        top.physicsBody?.categoryBitMask = pc.top
        top.physicsBody?.contactTestBitMask = pc.ball
        top.physicsBody?.collisionBitMask = pc.ball
        top.physicsBody?.affectedByGravity = false
        top.physicsBody?.isDynamic = false
        
        self.addChild(top)
        
        scoreLabel.attributedText = NSMutableAttributedString(string: "\(score)", attributes: outlineAttrib )
        scoreLabel.position = CGPoint(x: center!.x, y: (view?.frame.height)! - 100)
        scoreLabel.zPosition = 100
        scoreLabel.fontName = "AvenirNext-Bold"
//        scoreLabel.physicsBody?.collisionBitMask = pc.none
//        scoreLabel.physicsBody?.contactTestBitMask = pc.none
//        scoreLabel.physicsBody?.categoryBitMask = pc.none
        
        self.addChild(scoreLabel)
        
        enemy = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
        enemy.fillColor = #colorLiteral(red: 1, green: 0.2859963886, blue: 0.3100823969, alpha: 1)
        enemy.strokeColor = .clear
        enemy.position = CGPoint(x: 1000, y: 10000)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.frame.size)
        enemy.physicsBody?.categoryBitMask = pc.enemy
        enemy.physicsBody?.contactTestBitMask = pc.ball
        enemy.physicsBody?.collisionBitMask = pc.ball
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.isDynamic = false
        enemy.isHidden = true
        
        enemy2 = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
        enemy2.fillColor = #colorLiteral(red: 1, green: 0.2859963886, blue: 0.3100823969, alpha: 1)
        enemy2.strokeColor = .clear
        enemy2.position = CGPoint(x: 10000, y: 10000)
        
        enemy2.physicsBody = SKPhysicsBody(rectangleOf: enemy2.frame.size)
        enemy2.physicsBody?.categoryBitMask = pc.enemy
        enemy2.physicsBody?.contactTestBitMask = pc.ball
        enemy2.physicsBody?.collisionBitMask = pc.ball
        enemy2.physicsBody?.affectedByGravity = false
        enemy2.physicsBody?.isDynamic = false
        enemy2.isHidden = true
        
        
        self.addChild(enemy)
        self.addChild(enemy2)
        
        gameOverMenu = SKShapeNode(rectOf: CGSize(width: (view?.frame.width)! , height: (view?.frame.height)!))
        gameOverMenu.fillColor = .clear
        gameOverMenu.strokeColor = .clear
        
        gameOverMenu.position = center!
        gameOverMenu.zPosition = 50
        gameOverMenu.isHidden = true
        
        self.addChild(gameOverMenu)
        
        
        gameOverText.position = CGPoint(x: 0, y: view!.frame.height / 4)
        gameOverText.fontSize = 48
        gameOverText.fontName = "AvenirNext-Bold"
        gameOverText.horizontalAlignmentMode = .center
        gameOverMenu.addChild(gameOverText)
        
        restartText.position = CGPoint(x: 0, y: -view!.frame.height / 3.5)
        restartText.horizontalAlignmentMode = .center
        restartText.fontName = "AvenirNext-Bold"
        gameOverMenu.addChild(restartText)
        
        gameOverScore.position = CGPoint(x: 0, y: 75)
        gameOverScore.fontSize = 32
        gameOverScore.fontName = "AvenirNext-Bold"
        gameOverScore.horizontalAlignmentMode = .center
        gameOverScore.attributedText = NSMutableAttributedString(string: "Score: 0", attributes: outlineAttrib )
        
        gameOverMenu.addChild(gameOverScore)
        
        highScoreLabel.position = CGPoint(x: 0, y: 0)
        highScoreLabel.fontSize = 32
        highScoreLabel.fontName = "AvenirNext-Bold"
        highScoreLabel.horizontalAlignmentMode = .center
        highScoreLabel.attributedText = NSMutableAttributedString(string: "High Score: 0", attributes: outlineAttrib )
        gameOverMenu.addChild(highScoreLabel)

        
        helpButton = SKSpriteNode(imageNamed: "question")
        helpButton.size = CGSize(width: 75, height: 75)
        helpButton.name = "help"
        helpButton.position = CGPoint(x: -view!.frame.width / 4, y: -(view?.frame.height)! / 8)
        gameOverMenu.addChild(helpButton)
        
        shareButton = SKSpriteNode(imageNamed: "share")
        shareButton.size = CGSize(width: 75, height: 75)
        shareButton.name = "share"
        shareButton.position = CGPoint(x: view!.frame.width / 4, y: -(view?.frame.height)! / 8)
        gameOverMenu.addChild(shareButton)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if !ballTooLow {
            if (contact.bodyA.node?.physicsBody?.categoryBitMask == pc.ball && contact.bodyB.node?.physicsBody?.categoryBitMask == pc.paddle) || (contact.bodyA.node?.physicsBody?.categoryBitMask == pc.paddle &&
                contact.bodyB.node?.physicsBody?.categoryBitMask == pc.ball) {
                
                if goingDown {
                    goingDown = false
                } else {
                    goingDown = true
                }
                
                if canScore {
                    if !gameOver {
                        score += 1
                        scoreLabel.attributedText = NSMutableAttributedString(string: "\(score)", attributes: outlineAttrib )

                    }
                    
//                    AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
                    
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    paddleSpeed += paddleSpeed * 0.02
                    if score >= 5 {
                        moveEnemy = true
                    }
                }
                canScore = false
                
            }
        }
        
        if (contact.bodyA.node?.physicsBody?.categoryBitMask == pc.ball && contact.bodyB.node?.physicsBody?.categoryBitMask == pc.enemy) || (contact.bodyA.node?.physicsBody?.categoryBitMask == pc.enemy &&
        contact.bodyB.node?.physicsBody?.categoryBitMask == pc.ball) {
            
            die()
            ball.physicsBody?.velocity = CGVector.zero
            
        }
        
        
        if (contact.bodyA.node?.physicsBody?.categoryBitMask == pc.ball && contact.bodyB.node?.physicsBody?.categoryBitMask == pc.top) || (contact.bodyA.node?.physicsBody?.categoryBitMask == pc.top &&
            contact.bodyB.node?.physicsBody?.categoryBitMask == pc.ball) {
            
            
            if goingDown {
                goingDown = false
            } else {
                goingDown = true
            }
        }
        
    }
    
    func runGame(){
       
        
        if goingRight {
           paddle.position.x += paddleSpeed
        } else {
           paddle.position.x -= paddleSpeed
        }
        
        if paddle.position.x + paddle.frame.width / 2 > view!.frame.width {
            goingRight = false
        }
        
        if paddle.position.x - paddle.frame.width / 2 < 0 {
            goingRight = true
        }
        
        if !gameOver {
            
            if goingDown {
                       ball.position.y -= ballSpeed
                   } else {
                       ball.position.y += ballSpeed
                   }
            
            if let accelerometerData = motionManager.accelerometerData {
                
                ball.physicsBody?.velocity = CGVector(dx: accelerometerData.acceleration.x * 1500, dy: accelerometerData.acceleration.y)
            }
            
            if ball.position.y < -50 {
                die()
            }
            
            if ball.position.y < 110 {
                ballTooLow = true
            }
            
            if ball.position.y > view!.frame.height / 2 && !canScore{
                canScore = true
            }
            
            if ball.position.x < -100 || ball.position.x > (view?.frame.width)! + 100 {
                die()
            }
        }
        
    }
    
    func positionEnemy() -> CGFloat {
        
        var x : CGFloat = 0
        x = CGFloat.random(in: 0 ..< (view?.frame.width)!)
        enemy.isHidden = false
        
        return x
    }
    
    func getScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view!.scene!.size, true, 1)
        view!.layer.render(in: UIGraphicsGetCurrentContext()!)
        self.scene?.view?.drawHierarchy(in: (self.scene?.view?.bounds)!, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { print("ERROR"); return UIImage()}
        UIGraphicsEndImageContext()

        
        return image
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let positionInScene = touch.location(in: self)
            let touchedNode = self.atPoint(positionInScene)

            if let name = touchedNode.name
            {
                if name == "help"
                {
                    print("Touched Help")
                    resetGameWithHelp()
                    canCloseHelp = false
                    helpView.isHidden = false
                }
                
                if name == "share"
                {
                    print("Touched Share")
                    controller.share(image: getScreenshot())
                }
            } else {

                if gameOver {
                    resetGame()
                }
            }
            
        }
    }
    
    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake && gameOver{
            print("Why are you shaking me?")
         //   resetGame()
        }
    }
    
    
    
    @objc func updateCanCloseHelp(){
        if !canCloseHelp {
            canCloseHelp = true
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
                
        if helpView.isHidden {
            
            runGame()
            if moveEnemy {
                if score >= 5{
                    if enemy.isHidden {
                        enemy.isHidden = false
                    }
                    enemy.position = CGPoint(x: positionEnemy(), y: (view?.frame.height)! * 0.6)
                }
                if score >= 15 {
                    if enemy2.isHidden {
                        enemy2.isHidden = false
                    }
                    enemy2.position = CGPoint(x: positionEnemy(), y: (view?.frame.height)! * 0.9)
                }
                
                moveEnemy = false
            }

            if shouldShowAd {
                controller.showAd()
                shouldShowAd = false
            }
            

        } else {
            
        }
        
        
    }
}
