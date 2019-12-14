//
//  GameScene.swift
//  mazeGame
//
//  Created by Ketan Jogalekar on 10/11/19.
//  Copyright © 2019 Siddhika Ghaisas. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate{
//    public var TIMELEFT;
    
    //This framework holds functions for accessing gyrometer and other utilities of iphone
    let manager = CMMotionManager()
    var marble = SKSpriteNode()
    var blackHole = SKSpriteNode()
    var timerLabel = SKLabelNode()
    var livesLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var gameWonLabel = SKLabelNode()
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var timer:Timer?
    var timeLeft = 30
    var lives = 2
    var gameWon = false
    
    override func didMove(to view: SKView) {
        //Update the core motion manager, so it starts updating data immediately
        physicsWorld.contactDelegate = self
        marble = self.childNode(withName: "marble") as! SKSpriteNode
        blackHole = self.childNode(withName: "blackHole") as! SKSpriteNode
        
        //Create a text label to show game over
        gameOverLabel = self.childNode(withName: "gameOver") as! SKLabelNode
        //Initially it is hidden
        gameOverLabel.isHidden = true
        
        //Create a text to show game won
        gameWonLabel = self.childNode(withName: "gameWon") as! SKLabelNode
        //Initially it is hidden
        gameWonLabel.isHidden = true
        
        //Create a text label for showing timer on the screen
        timerLabel = self.childNode(withName: "timer") as! SKLabelNode
        timerLabel.text = String(timeLeft)
        
        //Create a text label for showing number of lives left on the screen
        livesLabel = self.childNode(withName: "lives") as! SKLabelNode
        livesLabel.text = String(lives)
        
        gameWon = false
        
        manager.startAccelerometerUpdates()
        //Grab data every 10th of a second
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main){
            (data,Error) in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 9.8, dy:CGFloat(( data?.acceleration.y)!) * 9.8)
        }
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let playerBody = contact.bodyA
        let blackHoleBody = contact.bodyB
        
        if playerBody.node?.name == "blackHole" ||
            blackHoleBody.node?.name == "blackHole"
        {
            //Let's mke the marble disappear in the black hole
            if playerBody.node?.name == "marble"
            {
                playerBody.node?.removeFromParent()
            }
            else
            {
                blackHoleBody.node?.removeFromParent()
            }
            //Display the game won text label
            gameWonLabel.isHidden = false
            gameWon = true
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if(timeLeft <= 0)
        {
            if(self.childNode(withName: "marble") != nil)
            {
                marble.removeFromParent()
                addMarble()
                timeLeft = 30
                timerLabel.text = String(timeLeft)
            }
        }
    }
    
    func addMarble(){
        if(lives > 0)
        {
            lives -= 1
            //Update the lives label
            livesLabel.text = String(lives)

            //Create a new marble SKSpriteNode
            marble = SKSpriteNode(imageNamed: "marble")
            marble.size = CGSize(width:50,height:50)
            marble.position = CGPoint(x:-250, y:-500)
            marble.physicsBody = SKPhysicsBody(circleOfRadius: 25)
            marble.physicsBody?.restitution = CGFloat(0.2)
            marble.physicsBody?.isDynamic = true
            marble.physicsBody?.contactTestBitMask = 0x00000002
            marble.physicsBody?.collisionBitMask = 0x00000001
            marble.physicsBody?.categoryBitMask = 0x00000001

            self.addChild(marble)
            timeLeft = 30
            timerLabel.text = String(timeLeft)
            
            //Retstart the 30 seconds timer after adding new marble
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    
        }
     }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //If user has enough lives left, Let's give the ability to add new marble
        // on touching the screen , so that user can play again
        if(lives > 0)
        {
            //A new marble can be added with touch, only when player
            //has won the previous game
            if(gameWon == true && self.childNode(withName: "marble") == nil)
            {
                gameWonLabel.isHidden = true
                addMarble()
                gameWon = false
            }
        }
    }
    
    @objc func onTimerFires()
    {
        timeLeft -= 1
        timerLabel.text = String(timeLeft)
        
        if timeLeft <= 0 {
            timer?.invalidate()
            timer = nil
            if(lives > 0)
            {
                if(gameWon == false)
                {
                    lives -= 1
                    //Update the lives label
                    livesLabel.text = String(lives)
                }
            }
            else
            {
                //Make sure that if the game is won at the last second
                if(gameWon == false)
                {
                    //0 lives, the game is over
                    //Get rid of the marble to stop the game then and there
                    marble.removeFromParent()
                    //Display the game over lable
                    gameOverLabel.isHidden = false
                    //Stop the accelerometer
                    manager.stopAccelerometerUpdates()
                }
            }
        }
        else
        {
            //If game won and there's time left, pause and show the left time
            if (gameWon == true)
            {
                timer?.invalidate()
            }
        }
    }

}
