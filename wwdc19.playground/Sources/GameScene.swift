import PlaygroundSupport
import SpriteKit
import Foundation
import AVFoundation

var firstTouch = true

public class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKSpriteNode()
    var enemy = SKSpriteNode()
    var player = SKSpriteNode()
    var leftWall = SKSpriteNode()
    var rightWall = SKSpriteNode()
    var youLose = SKSpriteNode()
    var youWin = SKSpriteNode()
    var allBlackBg = SKSpriteNode()
    var retry = SKSpriteNode()
    var counter:Int = 0
    var index = 0
    var playerLife = 5
    var enemyLife = 5
    var padColorIndex = 0
    var soundBg = AVAudioPlayer()
    var number = 3
    var numbers:SKSpriteNode?
    
    var padcolor = [SKTexture(imageNamed: "bluebar.png"), SKTexture(imageNamed: "greenbar.png"),SKTexture(imageNamed: "redbar.png"), SKTexture(imageNamed: "pinkbar.png")]
    
    var ballcolor = [SKTexture(imageNamed: "owl.png"), SKTexture(imageNamed: "frog.png"), SKTexture(imageNamed: "fox.png"), SKTexture(imageNamed: "egg.png"),]
    
    var playertouch:Bool = false
    private var label : SKLabelNode!
    private var spinnyNode : SKShapeNode!
    
    //Color match verify function
    func hitInNodes() -> Bool {
        
        if self.ball.texture == ballcolor[0] && self.player.texture == padcolor[0]{
            return true
        }
        else if self.ball.texture == ballcolor[1] && self.player.texture == padcolor[1]{
            return true
        }
        else if self.ball.texture == ballcolor[2] && self.player.texture == padcolor[2]{
            return true
        }
        else if self.ball.texture == ballcolor[3] && self.player.texture == padcolor[3]{
            return true
        }
        return false
    }
    
    //Number counter to start
    func restartTimer() {
        let secondWait: SKAction = SKAction.wait(forDuration: 1)
        let finishTimer: SKAction = SKAction.run {
            self.numbers?.texture = SKTexture(imageNamed: "num\(self.number).png")
            self.number -= 1
            if(self.number == 0){
                self.numbers!.run(SKAction.fadeOut(withDuration: 0.5))
            }else{
                self.restartTimer()
            }
        }
        let seq = SKAction.sequence([secondWait, finishTimer])
        self.run(seq)
    }
    
    override public func sceneDidLoad() {
        //finish screen
        self.youLose = childNode(withName: "youLose") as! SKSpriteNode
        self.retry = childNode(withName: "retry") as! SKSpriteNode
        self.allBlackBg = childNode(withName: "allBlackBg") as! SKSpriteNode
        
        //numbers caller
        self.numbers = self.childNode(withName: "numbers") as? SKSpriteNode
        restartTimer()
        
        firstTouch = true
        self.counter = 0
        physicsWorld.contactDelegate = self
        
        //nodes physicsBody
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.categoryBitMask = contactMaskType.ball
        
        ball.physicsBody?.collisionBitMask = contactMaskType.player | contactMaskType.enemy
        ball.physicsBody?.contactTestBitMask = contactMaskType.player | contactMaskType.enemy
        
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        enemy.physicsBody?.categoryBitMask = contactMaskType.enemy
        enemy.physicsBody?.collisionBitMask = contactMaskType.ball
        
        player = self.childNode(withName: "player") as! SKSpriteNode
        player.physicsBody?.categoryBitMask = contactMaskType.player
        player.physicsBody?.collisionBitMask = contactMaskType.ball
        
        
        leftWall = self.childNode(withName: "leftWall") as! SKSpriteNode
        
        
        rightWall = self.childNode(withName: "rightWall") as! SKSpriteNode
        
        
        //game start counter time
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            
            //ball direction
            let startBall = Int.random(in: 0...1)
            if startBall == 0 {
                self.ball.physicsBody?.applyImpulse(CGVector(dx: -30, dy: -30))
            } else {
                self.ball.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 30))
                
                //start background music
                do{
                    self.soundBg = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "bgmStage", ofType: "wav")!))
                    self.soundBg.numberOfLoops = -1
                    self.soundBg.prepareToPlay()
                }
                catch {}
                self.soundBg.play()
            }
        }
    }
    
    //changing player color
    @objc func playerColorChange(){
        
        padColorIndex = padColorIndex + 1
        if padColorIndex >= 4 {
            padColorIndex = 0
        }
        player.texture = padcolor[padColorIndex]
    }
    override public func didMove(to view: SKView) {
    }
    
    //player collision effects
    let shockWaveAction: SKAction = {
        let growAndFadeAction = SKAction.group([SKAction.scale(to: 50, duration: 0.5),SKAction.fadeOut(withDuration: 0.5)])
        
        let sequence = SKAction.sequence([growAndFadeAction,
                                          SKAction.removeFromParent()])
        
        return sequence
    }()
    
    //test of contact
    public func didBegin(_ contact: SKPhysicsContact) {
        
        //object collision
        if contact.bodyA.node?.name == "ball" && contact.bodyB.node?.name == "player" || contact.bodyA.node?.name == "player" && contact.bodyB.node?.name == "ball"
        {
            
            player.texture = padcolor[Int.random(in: 0 ..< 4)]
            
            let shockwave = SKShapeNode(circleOfRadius: 1)
            
            shockwave.position = contact.contactPoint
            scene!.addChild(shockwave)
            
            shockwave.run(shockWaveAction)
            
            counter += 1
            self.hitcounter()
        }
        if contact.bodyA.node?.name == "ball" && contact.bodyB.node?.name == "enemy" || contact.bodyA.node?.name == "enemy" && contact.bodyB.node?.name == "ball"
        {
            //calling object collision effect
            let shockwave = SKShapeNode(circleOfRadius: 1)
            
            shockwave.position = contact.contactPoint
            scene!.addChild(shockwave)
            
            shockwave.run(shockWaveAction)
            
            counter += 1
            self.hitcounter()
            
        }
    }
    //touch functions
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.playertouch = false
        playerColorChange()
        firstTouch = false
    }
    public override  func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.playertouch = true
        for t in touches{
            let node = self.nodes(at: t.location(in: self))
            if node.contains(self.retry){
                let reveal = SKTransition.crossFade(withDuration: 1.5)
                if let gameScene = GameScene(fileNamed: "GameScene"){
                    gameScene.scaleMode = .aspectFit
                    self.view?.presentScene(gameScene, transition:reveal)
                }
            }
        }
    }
    // here are set the touch and drag functions
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            self.playertouch = true
            let location = touch.location(in: self)
            player.run(SKAction.moveTo(x: location.x, duration: 0.2))
            
            //range limit of player movement
            let xrange = SKRange(lowerLimit: -((scene?.size.width)!/2) + 150, upperLimit: ((scene?.size.width)!/2 - 150))
            let yrange = SKRange(lowerLimit: -320, upperLimit: -320)
            self.player.constraints = [SKConstraint.positionX(xrange, y: yrange)]
        }
    }
    
    override public func update(_ currentTime: TimeInterval) {
        
        //player is hitable or not
        if self.hitInNodes() == false && !firstTouch {
            player.physicsBody?.categoryBitMask = contactMaskType.nothing
        }
        else {
            player.physicsBody?.categoryBitMask = contactMaskType.player
        }
        
        //Enemy movement
        enemy.run(SKAction.moveTo(x: ball.position.x, duration: 1))
        
        //ball move corrector
        if ball.position.y > 0 && abs(ball.physicsBody!.velocity.dy) <= 80.0 {
            ball.physicsBody?.applyForce(CGVector(dx: 0, dy: -80))
        }
        else if ball.position.y < 0 && abs(ball.physicsBody!.velocity.dy) <= 80.0 {
            ball.physicsBody?.applyForce(CGVector(dx: 0, dy: 80))
        }
        if ball.position.x > 0 && abs(ball.physicsBody!.velocity.dx) <= 80.0 {
            ball.physicsBody?.applyForce(CGVector(dx: -80, dy: 0))
            
        }else if ball.position.x < 0 && abs(ball.physicsBody!.velocity.dx) <= 80.0 {
            ball.physicsBody?.applyForce(CGVector(dx: 80, dy: 0))
        }
        
        //here dectect if the ball passes through the player's pad new functions will be called
        if ball.position.y <= player.position.y - 50  {
            
            //enemy life are reduced
            self.childNode(withName: "PlayerLife\(playerLife)")?.run(SKAction.fadeOut(withDuration: 0.5))
            playerLife -= 1
            
            ball.position = CGPoint(x: 0, y: 0)
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.ball.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 30))
            }
            if playerLife < 1{
                physicsWorld.speed = 0
                self.youLose.texture = SKTexture(imageNamed: "youlose")
                self.allBlackBg.run(SKAction.fadeIn(withDuration: 0.5)) {
                    self.youLose.run(SKAction.fadeIn(withDuration: 0.5), completion: {
                        self.retry.run(SKAction.fadeIn(withDuration: 0.5))
                    })
                }
            }
        }
        //here dectect if the ball passes through the enemy's pad new functions will be called
        else if ball.position.y >= enemy.position.y + 50 {
            
            //enemy life are reduced
            self.childNode(withName: "EnemyLife\(enemyLife)")?.run(SKAction.fadeOut(withDuration: 0.5))
            enemyLife -= 1
            
            ball.position = CGPoint(x: 0, y: 0)
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.ball.physicsBody?.applyImpulse(CGVector(dx: 30, dy: 30))
            }
            if enemyLife < 1{
                
                physicsWorld.speed = 0
                self.youLose.texture = SKTexture(imageNamed: "winner")
                self.allBlackBg.run(SKAction.fadeIn(withDuration: 0.5)) {
                    self.youLose.run(SKAction.fadeIn(withDuration: 0.5), completion: {
                        self.retry.run(SKAction.fadeIn(withDuration: 0.5))
                    })
                }
            }
        }
    }
    
    //here the counter variable change modify the ball color
    func hitcounter() {
        
        if counter >= 0 && counter <= 3 {
            ball.texture = ballcolor[3]
            index = 3
        }
        if counter > 3 {
            let textureCounter = Int.random(in: 0 ..< 3)
            ball.texture = ballcolor[textureCounter]
            index = textureCounter
            leftWall.physicsBody?.restitution = 1.1
            rightWall.physicsBody?.restitution = 1.1
        }
        //enemy pad receive the color texture
        enemy.texture = padcolor[index]
    }
}


