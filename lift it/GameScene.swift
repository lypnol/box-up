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
    var tutorialLabel: SKLabelNode!
    var finalScore: SKLabelNode!
    var bestScoreLabel: SKLabelNode!
    var score = 0
    var bestScore = 0
    var scoreLabel: SKLabelNode!
    var cube = SKSpriteNode()
    var ground = SKSpriteNode()
    var pointer = SKSpriteNode()
    
    var started = false
    var pushedStart = false
    var startDate = 0
    var initialTutorialLabelY = CGFloat(0.0)
        
    private var gameState : String = "First"
    
    override func didMove(to view: SKView) {
        newGame = self.childNode(withName: "newGame") as! SKLabelNode!
        scoreLabel = self.childNode(withName: "ScoreLabel") as! SKLabelNode!
        scoreView = self.childNode(withName: "score") as! SKLabelNode!
        tutorialLabel = self.childNode(withName: "tutorialLabel") as! SKLabelNode!
        finalScore = self.childNode(withName: "FinalScore") as! SKLabelNode!
        bestScoreLabel = self.childNode(withName: "BestScore") as! SKLabelNode!
        scoreLabel.isHidden = true
        finalScore.isHidden = true
        scoreView.isHidden = true
        finalScore.isHidden = true
        newGame.run(SKAction.fadeIn(withDuration: 2.0))
        
        cube = self.childNode(withName: "cube") as! SKSpriteNode
        ground = self.childNode(withName: "ground") as! SKSpriteNode
        pointer = self.childNode(withName: "pointer") as! SKSpriteNode
        
        cube.physicsBody?.usesPreciseCollisionDetection = true
        ground.physicsBody?.usesPreciseCollisionDetection = true
        pointer.physicsBody?.usesPreciseCollisionDetection = true

        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.affectedByGravity = false
        border.isDynamic = false
        border.friction = 0.5
        border.restitution = 0.5
        
        let defaults = UserDefaults.standard
        
        bestScoreLabel.isHidden = true
        self.bestScore = defaults.integer(forKey: "best_score")
        if self.bestScore > 0 {
            bestScoreLabel.isHidden = false
            bestScoreLabel.text = "High Score: "+String(self.bestScore)
        }
        
        self.physicsBody = border
        self.physicsWorld.contactDelegate = self
        
        initialTutorialLabelY = tutorialLabel.position.y
    }
        
    public func didBegin(_ contact: SKPhysicsContact) {
        if gameState == "On" {
            let nodeA = contact.bodyA.node!.name
            let nodeB = contact.bodyB.node!.name
            if started {
                if (nodeA == "cube" && (nodeB == "ground" || nodeB == "wall")) ||
                   (nodeB == "cube" && (nodeA == "ground" || nodeA == "wall")) {
                    gameOver()
                }
            }
        }
    }
    
    func startGame() {
        if gameState != "On" {
            started = false
            finalScore.isHidden = true
            tutorialLabel.position.y = initialTutorialLabelY
            tutorialLabel.isHidden = false
            tutorialLabel.run(SKAction(named: "arrow")!)
            pointer.run(SKAction.move(to: CGPoint(x: 5000, y: 5000), duration: 0))
            scoreLabel.isHidden = false
            scoreView.isHidden = false
            newGame.isHidden = true
            ground.physicsBody?.restitution = 0
            ground.physicsBody?.friction = 1
            bestScoreLabel.isHidden = true
            startDate = Int(NSDate().timeIntervalSince1970)
            cube.run(SKAction.rotate(toAngle: 0, duration: 0.1), completion: {() -> Void in
                self.cube.run(SKAction.move(to: CGPoint(x: 0, y: -159), duration: 0.1), completion: {() -> Void in
                    self.cube.run(SKAction.stop())
                    self.cube.physicsBody?.velocity.dx = 0
                    self.cube.physicsBody?.velocity.dy = 0
                    self.cube.physicsBody?.angularVelocity = 0
                    self.score = 0
                    self.scoreView.text = String(self.score)
                    self.gameState = "On"

                })
            })
        }
    }
    
    func gameOver() {
        if gameState == "On" && started {
            pointer.run(SKAction.move(to: CGPoint(x: 5000, y: 5000), duration: 0))
            started = false
            gameState = "Over"
            scoreLabel.isHidden = true
            scoreView.isHidden = true
            finalScore.text = "Score: " + String(score)
            newGame.text = "Retry"
            finalScore.isHidden = false
            newGame.isHidden = false
            if bestScore < score {
                bestScore = score
                let defaults = UserDefaults.standard
                defaults.set(bestScore, forKey: "best_score")
            }
            bestScoreLabel.text = "High Score: "+String(self.bestScore)
            bestScoreLabel.isHidden = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let first = touches.first {
            let location = first.location(in: self)
            if gameState == "On" {
                if started {
                    pointer.run(SKAction.move(to: location, duration: 0))
                } else {
                    if pointer.frame.maxY - 4 < ground.frame.maxY {
                        pointer.run(SKAction.move(to: location, duration: 0))
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let first = touches.first {
            let location = first.location(in: self)
            let touched = self.atPoint(location)
            if gameState != "On" {
                if touched.name == "newGame" && !pushedStart {
                    pushedStart = true
                    newGame.run(SKAction.scale(to: 0.8, duration: 0.1))
                }
            } else {
                if started {
                    pointer.run(SKAction.move(to: location, duration: 0))
                } else {
                    if location.y < ground.frame.maxY {
                        pointer.run(SKAction.move(to: location, duration: 0))
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState != "On" {
            if let first = touches.first {
                let location = first.location(in: self)
                let touched = self.atPoint(location)
                if pushedStart {
                    newGame.run(SKAction.scale(to: 1, duration: 0.1), completion: {() -> Void in
                        if touched.name == "newGame" && self.pushedStart {
                            self.newGame.isHidden = true
                            self.pushedStart = false
                            self.startGame()
                        }
                    })
                }
            }
        } else {
            pointer.run(SKAction.move(to: CGPoint(x: 5000, y: 5000), duration: 0))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if gameState == "On" && started {
            score = Int(NSDate().timeIntervalSince1970) - startDate
            scoreView.text = String(score)
            if cube.physicsBody?.velocity.dx == 0 && cube.physicsBody?.velocity.dy == 0 {
                cube.physicsBody?.applyAngularImpulse(CGFloat(5))
            }
        } else if gameState == "On" && !started {
            if cube.frame.minY > 5 + ground.frame.maxY {
                tutorialLabel.isHidden = true
                tutorialLabel.removeAllActions()
                startDate = Int(NSDate().timeIntervalSince1970)
                ground.physicsBody?.restitution = 0
                ground.physicsBody?.friction = 1
                started = true
            }
        }
    }
}
