//
//  GameScene.swift
//  Cave Hopper
//
//  Created by Marco Matamoros on 2017-01-03.
//  Copyright © 2017 Blue Stars. All rights reserved.
//

import SpriteKit

private var highScore = UserDefaults.standard.value(forKey: "highScore") as? Int ?? 0

class GameScene: SKScene {
    var gameStarted = false
    var gameEnded = false
    var score = 0 {
        didSet {
            scoreLabel.text = String(score)
        }
    }
    var scoreLabel: SKLabelNode!
    var playLabel: SKLabelNode!
    var title: SKLabelNode!
    var firstPaddleHit = false
    var animationFinished = false
    var gameManager: GameManager?
   
    
    override func didMove(to view: SKView) {       
        title = self.childNode(withName: "title") as! SKLabelNode
        scoreLabel = self.childNode(withName: "scoreLabel") as! SKLabelNode
        playLabel = self.childNode(withName: "playLabel") as! SKLabelNode
        
        playLabel.run(SKAction(named: "Pulse")!)
    }
    
    func gameOver() {
        gameEnded = true
        
        if score > highScore {
            highScore = score
            UserDefaults.standard.setValue(highScore, forKey: "highScore")
            UserDefaults.standard.synchronize()
        }
        
        let scoreBox = SKShapeNode(rectOf: CGSize(width: 365, height: 280), cornerRadius: 32)
        scoreBox.fillColor = SKColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1)
        scoreBox.strokeColor = .clear
        scoreBox.position = CGPoint(x: 0, y: 260)
        scoreBox.alpha = 0
        scoreBox.setScale(0)
        scoreBox.run(SKAction(named: "FadeIn")!) {
            self.animationFinished = true
        }
        self.addChild(scoreBox)
        
        scoreLabel.fontSize = 96
        scoreLabel.fontColor = .white
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.move(toParent: scoreBox)
        scoreLabel.fontName = "HelveticaNeue"
        scoreLabel.position = CGPoint(x: 0, y: (scoreBox.path?.boundingBox.height)!/6)
        
        let highScoreLabel = SKLabelNode(text: "Best: \(highScore)")
        highScoreLabel.fontSize = 48
        highScoreLabel.fontName = "HelveticaNeue"
        highScoreLabel.verticalAlignmentMode = .center
        highScoreLabel.fontColor = .black
        highScoreLabel.position = CGPoint(x: 0, y: -(scoreBox.path?.boundingBox.height)!/6)
        scoreBox.addChild(highScoreLabel)
        
        let retryLabel = SKLabelNode(text: "Tap to retry")
        retryLabel.fontSize = 72
        retryLabel.fontColor = SKColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        retryLabel.verticalAlignmentMode = .center
        retryLabel.position = CGPoint(x: 0, y: 0)
        retryLabel.alpha = 0
        retryLabel.setScale(0)
        retryLabel.run(SKAction.sequence([SKAction(named: "FadeIn")!, SKAction(named: "Pulse")!]))
        self.addChild(retryLabel)
    }
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if gameStarted {
            if !gameEnded {
                gameManager?.scrollPaddle()
            }
            else if animationFinished {
                gameManager?.restartScene()
            }
        }
        else {
            gameManager?.start()
            
            gameStarted = true
            
            title.removeFromParent()
            playLabel.removeFromParent()
            
            scoreLabel.setScale(0)
            scoreLabel.run(SKAction(named: "FadeIn")!)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

