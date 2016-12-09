//
//  GameScene.swift
//  box up
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
    
    var BACKGROUNDB = CGFloat(0.98)
    var CUBEB = CGFloat(0.05)
    var GROUNDB = CGFloat(0.30)
    
    var GROUND_HEIGHT = CGFloat(0.25) // % of screen
        
    private var gameState : String = "First"
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.scaleMode = SKSceneScaleMode.aspectFit
        
        // Get Nodes from scene
        
        newGame = self.childNode(withName: "newGame") as! SKLabelNode!
        scoreLabel = self.childNode(withName: "ScoreLabel") as! SKLabelNode!
        scoreView = self.childNode(withName: "score") as! SKLabelNode!
        tutorialLabel = self.childNode(withName: "tutorialLabel") as! SKLabelNode!
        finalScore = self.childNode(withName: "FinalScore") as! SKLabelNode!
        bestScoreLabel = self.childNode(withName: "BestScore") as! SKLabelNode!
        
        cube = self.childNode(withName: "cube") as! SKSpriteNode
        pointer = self.childNode(withName: "pointer") as! SKSpriteNode

        // Set up labels
        
        scoreLabel.isHidden = true
        finalScore.isHidden = true
        scoreView.isHidden = true
        finalScore.isHidden = true
        
        initialTutorialLabelY = tutorialLabel.position.y
        
        // Get high score
        
        let defaults = UserDefaults.standard
        bestScoreLabel.isHidden = true
        self.bestScore = defaults.integer(forKey: "best_score")
        if self.bestScore > 0 {
            bestScoreLabel.isHidden = false
            bestScoreLabel.text = "High Score: "+String(self.bestScore)
        }
        
        // Set up scene borders
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = false
        self.physicsBody?.friction = 0.1
        self.physicsBody?.restitution = 0.5
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.collisionBitMask = 1
        self.physicsBody?.contactTestBitMask = 1

        // Set up ground
        
        ground = SKSpriteNode(color: UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(),
                                                              components: [CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), GROUNDB, CGFloat(1.0)])!),
                              size: CGSize(width: (self.scene?.frame.width)!,
                                           height: (self.scene?.frame.height)! * GROUND_HEIGHT))
        ground.name = "ground"
        ground.anchorPoint = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        ground.position.x = 0
        ground.position.y = (self.scene?.frame.minY)! + ground.size.height / 2
        
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: ground.size.width, height: ground.size.height))
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.categoryBitMask = 1
        ground.physicsBody?.collisionBitMask = 1
        ground.physicsBody?.contactTestBitMask = 1
        ground.physicsBody?.restitution = 0.5
        ground.physicsBody?.friction = 0.1
        
        self.addChild(ground)
        
        // Additional features
        
        cube.physicsBody?.usesPreciseCollisionDetection = true
        pointer.physicsBody?.usesPreciseCollisionDetection = true
        ground.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        // Set up cube
        
        cube.position.x = 0
        cube.position.y = ground.frame.maxY + cube.frame.height / 2
        
        // Set up colors
        
        grayScale()
    }
        
    public func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node!.name
        let nodeB = contact.bodyB.node!.name
        if (nodeA == "cube" && (nodeB == "ground" || nodeB == "scene")) ||
            (nodeB == "cube" && (nodeA == "ground" || nodeA == "scene")) {
            if gameState == "On" && started {
                gameOver()
            }
        }
    }
    
    func randomizeColors() {
        let cyan = CGFloat(Double(arc4random_uniform(100)) / 100.0)
        let yellow = CGFloat(Double(arc4random_uniform(100)) / 100.0)
        let magenta = CGFloat(Double(arc4random_uniform(100)) / 100.0)
        let one = CGFloat(1.0)
        
        self.scene?.backgroundColor = UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(),
                                            components: [cyan, magenta, yellow, BACKGROUNDB, one])!)
        cube.color = UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(),
                                            components: [cyan, magenta, yellow, CUBEB, one])!)
        ground.color = UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(),
                                            components: [cyan, magenta, yellow, GROUNDB, one])!)
    }
    
    func grayScale() {
        let one = CGFloat(1.0)
        let zero = CGFloat(0.0)
        
        self.scene?.backgroundColor = UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(),
                                              components: [zero, zero, zero, BACKGROUNDB, one])!)
        cube.color = UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(),
                                              components: [zero, zero, zero, CUBEB, one])!)
        ground.color = UIColor(cgColor: CGColor(colorSpace: CGColorSpaceCreateDeviceCMYK(),
                                              components: [zero, zero, zero, GROUNDB, one])!)
    }
    
    func actualStart() {
        tutorialLabel.isHidden = true
        tutorialLabel.removeAllActions()
        startDate = Int(NSDate().timeIntervalSince1970)
        started = true
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
            bestScoreLabel.isHidden = true
            startDate = Int(NSDate().timeIntervalSince1970)
            randomizeColors()
            self.cube.run(SKAction.rotate(toAngle: 0, duration: 0.1), completion: {() -> Void in
                self.cube.run(SKAction.move(to: CGPoint(x: 0, y: self.ground.frame.maxY + self.cube.frame.height / 2), duration: 0.1), completion: {() -> Void in
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
            grayScale()
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
                    if !(pointer.position.x == 5000 && pointer.position.y == 5000) {
                        pointer.run(SKAction.move(to: location, duration: 0))
                    }
                } else {
                    if !(pointer.position.x == 5000 && pointer.position.y == 5000) &&
                    (location.y + pointer.frame.height / 2 < ground.frame.maxY - 2 ||
                    (location.y + pointer.frame.height / 2 < cube.frame.maxY &&
                     location.x - pointer.frame.width / 2 < cube.frame.maxX &&
                     location.x + pointer.frame.width / 2 > cube.frame.minX)) {
                        pointer.run(SKAction.move(to: location, duration: 0))
                    } else {
                        pointer.run(SKAction.move(to: CGPoint(x: 0, y: 5000), duration: 0))
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
                    if !(location.y - pointer.frame.height / 2 < cube.frame.maxY &&
                        location.y + pointer.frame.height / 2 > cube.frame.minY &&
                        location.x - pointer.frame.width / 2 < cube.frame.maxX &&
                        location.x + pointer.frame.width / 2 > cube.frame.minX) {
                        pointer.run(SKAction.move(to: location, duration: 0))
                    }
                } else {
                    if location.y + pointer.frame.height / 2 < ground.frame.maxY - 2 {
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
            if cube.frame.minY > 5 + ground.frame.maxY &&
               cube.frame.minX > 20 + self.frame.minX &&
               cube.frame.maxX < self.frame.maxX - 20 {
                actualStart()
            }
        }
    }
}
