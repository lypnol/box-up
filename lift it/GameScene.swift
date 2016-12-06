//
//  GameScene.swift
//  lift it
//
//  Created by Ayoub Sbai on 05/12/2016.
//  Copyright © 2016 Ayoub Sbai. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var newGame : SKLabelNode!
    var scoreView: SKLabelNode!
    var finalScore: SKLabelNode!
    var score = 0
    var scoreLabel: SKLabelNode!
    var cube = SKSpriteNode()
    var ground = SKSpriteNode()
    var pointer = SKSpriteNode()
    var started = false
    
    private var gameState : String = "First"
    
    override func didMove(to view: SKView) {
        newGame = self.childNode(withName: "newGame") as! SKLabelNode!
        scoreLabel = self.childNode(withName: "ScoreLabel") as! SKLabelNode!
        scoreView = self.childNode(withName: "score") as! SKLabelNode!
        finalScore = self.childNode(withName: "FinalScore") as! SKLabelNode!
        scoreLabel.alpha = 0.0
        finalScore.alpha = 0.0
        scoreView.alpha = 0.0
        newGame.alpha = 0.0
        newGame.run(SKAction.fadeIn(withDuration: 2.0))
        
        cube = self.childNode(withName: "cube") as! SKSpriteNode
        ground = self.childNode(withName: "ground") as! SKSpriteNode
        pointer = self.childNode(withName: "pointer") as! SKSpriteNode

        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.affectedByGravity = false
        border.isDynamic = false
        border.friction = 0.5
        border.restitution = 0.1
        
        self.physicsBody = border
        self.physicsWorld.contactDelegate = self
    }
        
    func didBeginContact(contact: SKPhysicsContact) {
        if gameState == "On" {
            if !started {
                if contact.bodyA.node?.name == "cube" && contact.bodyB.node?.name == "pointer" {
                    started = true
                }
            } else {
                if contact.bodyA.node?.name == "cube" &&
                   (contact.bodyB.node?.name == "scene" ||
                    contact.bodyB.node?.name == "ground") {
                    gameOver()
                }
            }
        }
    }
    
    func startGame() {
        if gameState != "On" {
            started = false
            gameState = "On"
            scoreLabel.alpha = 1.0
            scoreView.alpha = 1.0
            newGame.alpha = 0.0
            finalScore.alpha = 0.0
            cube.run(SKAction.moveTo(x: 0, duration: 0.1))
            score = 0
            scoreView.text = String(score)
            pointer.run(SKAction.move(to: CGPoint(x: -5000, y: -5000), duration: 0))
        }
    }
    
    func gameOver() {
        if gameState == "On" && started {
            pointer.run(SKAction.move(to: CGPoint(x: -5000, y: -5000), duration: 0))
            started = false
            gameState = "Over"
            scoreLabel.alpha = 0.0
            scoreView.alpha = 0.0
            finalScore.text = "Score: " + String(score)
            newGame.text = "Retry"
            finalScore.alpha = 1.0
            newGame.alpha = 1.0
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == "On" {
            if let first = touches.first {
                let location = first.location(in: self)
                pointer.run(SKAction.move(to: location, duration: 0))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != "On" {
            newGame.run(SKAction.scale(to: 0.5, duration: 0.5))
        } else {
            if let first = touches.first {
                let location = first.location(in: self)
                pointer.run(SKAction.move(to: location, duration: 0))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != "On" {
            newGame.run(SKAction.scale(to: 1, duration: 0.5))
            startGame()
        } else {
            pointer.run(SKAction.move(to: CGPoint(x: -5000, y: -5000), duration: 0))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState == "On" {
            score += 1
            scoreView.text = String(score)
        }
    }
}
