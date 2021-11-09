////
//  MainMenu.swift
//  Bounce
//
//  Created by Alex Wayne on 4/4/20.
//  Copyright © 2020 Wayne Apps. All rights reserved.
//
//
import SpriteKit
import UIKit

class MainMenu: SKScene {
    
    var label = UILabel()
    
    var titleLabel = SKLabelNode(text: "Bounce\n& Dodge")
    var ttpLabel = SKLabelNode(text: "tap to play")
    
    var gameScene: GameScene?
 //   let gameScene = GameScene(fileNamed: "GameScene")
    
    public var controller = GameViewController()
    
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func didMove(to view: SKView) {
        titleLabel.position = CGPoint(x: 0, y: 0)
        titleLabel.zPosition = 0
        titleLabel.fontSize = 90
        
        titleLabel.numberOfLines = 2
        
        ttpLabel.position = CGPoint(x: 0, y: -view.frame.height / 3 )
        ttpLabel.zPosition = 0
        ttpLabel.fontSize = 44

        ttpLabel.numberOfLines = 2
        
        self.addChild(titleLabel)
        self.addChild(ttpLabel)
        
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 30
        pulseAnimation.fromValue = 0
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        
        
        pulseAnim(node: ttpLabel)
    }
    
    func pulseAnim(node:SKLabelNode) {
        let pulseIn = SKAction.fadeIn(withDuration: 1)
        pulseIn.timingMode = SKActionTimingMode.easeInEaseOut

        let pulseOut = SKAction.fadeOut(withDuration: 1)
        pulseOut.timingMode = SKActionTimingMode.easeInEaseOut

        node.run(SKAction.repeatForever(SKAction.sequence([pulseIn,pulseOut])))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        gameScene!.size = size
        gameScene!.scaleMode = scaleMode
        gameScene!.controller = controller
        
        let transition = SKTransition.fade(withDuration: 1)
        self.view?.presentScene(gameScene!, transition: transition)
    }
    
    
}
