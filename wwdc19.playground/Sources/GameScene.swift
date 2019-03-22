import PlaygroundSupport
import SpriteKit
import Foundation

public class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKSpriteNode()
    var enemy = SKSpriteNode()
    var player = SKSpriteNode()
    var counter:Int = 0
    var index = 0
    var playerLife = 5
    var enemyLife = 5
    
    var padColorIndex = 0
    
    var padcolor = [SKTexture(imageNamed: "bluebar.png"), SKTexture(imageNamed: "greenbar.png"),SKTexture(imageNamed: "redbar.png"), SKTexture(imageNamed: "pinkbar.png")]
    
    var ballcolor = [SKTexture(imageNamed: "owl.png"), SKTexture(imageNamed: "frog.png"), SKTexture(imageNamed: "fox.png"), SKTexture(imageNamed: "egg.png"), SKTexture(imageNamed: "egg1.png"), SKTexture(imageNamed: "egg2.png")]
    
    var playertouch:Bool = false
    private var label : SKLabelNode!
    private var spinnyNode : SKShapeNode!
    
    override public func sceneDidLoad() {
        
        
        self.counter = 0
        physicsWorld.contactDelegate = self
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.categoryBitMask = contactMaskType.ball
        ball.physicsBody?.collisionBitMask = contactMaskType.player | contactMaskType.enemy
        ball.physicsBody?.contactTestBitMask = contactMaskType.player | contactMaskType.enemy
        
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        enemy.physicsBody?.categoryBitMask = contactMaskType.enemy
        enemy.physicsBody?.collisionBitMask = contactMaskType.ball
        
        player = self.childNode(withName: "player") as! SKSpriteNode
        player.physicsBody?.categoryBitMask = contactMaskType.player

        //game start time
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            print("start!")
            self.ball.physicsBody?.applyImpulse(CGVector(dx: -50, dy: -50))
        }
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1.01
        
        self.physicsBody = border
        
        
    }
    
    //hit nodes is true
    func hitInNodes() -> Bool {
        
        print("entrou hitnodes func")
        if self.ball.texture == ballcolor[0] && self.player.texture == padcolor[0]{
            print("entrou texture azul")
            return true
        }
        else if self.ball.texture == ballcolor[1] && self.player.texture == padcolor[1]{
            print("entrou texture verde")
            return true
        }
        else if self.ball.texture == ballcolor[2] && self.player.texture == padcolor[2]{
            print("entrou vermelho")
            return true
        }
        else if self.player.texture == padcolor[3] && (self.ball.texture == ballcolor[3] ||
            self.ball.texture == ballcolor[4] ||
            self.ball.texture == ballcolor[5]){
            print("entrou no rosa")
            return true
        }
        
        return false
    }
    
    // player color is change
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
        
        //objectcolision
        if contact.bodyA.node?.name == "ball" && contact.bodyB.node?.name == "player" || contact.bodyA.node?.name == "player" && contact.bodyB.node?.name == "ball" && contact.bodyA.node?.name == "ball" && contact.bodyB.node?.name == "enemy" || contact.bodyA.node?.name == "enemy" && contact.bodyB.node?.name == "ball"
        {
            player.texture = padcolor[Int.random(in: 0 ..< 4)]
            
            let shockwave = SKShapeNode(circleOfRadius: 1)
            
            shockwave.position = contact.contactPoint
            scene!.addChild(shockwave)
            
            shockwave.run(shockWaveAction)
            
            //teste
            counter += 1
            self.hitcounter()
        }
        else if contact.bodyA.node?.name == "ball" && contact.bodyB.node?.name == "enemy" || contact.bodyA.node?.name == "enemy" && contact.bodyB.node?.name == "ball"
        {
            //teste enemy
            counter += 1
            self.hitcounter()
        }
        
    }
    //player touch
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.playertouch = false
        playerColorChange()
    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.playertouch = true
        for touch in touches{
            
            let location = touch.location(in: self)
            player.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            self.playertouch = true
            let location = touch.location(in: self)
            player.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
    }
    //Enemy movement
    override public func update(_ currentTime: TimeInterval) {
        
        if self.hitInNodes() == false {
            
            player.physicsBody?.categoryBitMask = contactMaskType.nothing
        }
        else {
            
            player.physicsBody?.categoryBitMask = contactMaskType.player
        }
        
        enemy.run(SKAction.moveTo(x: ball.position.x, duration: 0.2))
        
        //ball move corrector
        if ball.position.y > 0 && abs(ball.physicsBody!.velocity.dy) <= 30.0 {
            ball.physicsBody?.applyForce(CGVector(dx: 0, dy: -50))
        }
        else if ball.position.y < 0 && abs(ball.physicsBody!.velocity.dy) <= 30.0 {
            ball.physicsBody?.applyForce(CGVector(dx: 0, dy: 50))
        }
        
        //winner detect
        if ball.position.y <= player.position.y - 30  {
            
            self.childNode(withName: "PlayerLife\(playerLife)")?.run(SKAction.fadeOut(withDuration: 0.5))
            playerLife -= 1
            ball.position = CGPoint(x: 0, y: 0)
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.ball.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 50))
            }
            if playerLife < 1{
                print("Acabou bb")
            }
            
        }
        else if ball.position.y >= enemy.position.y + 30{
            ball.position = CGPoint(x: 0, y: 0)
            ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.ball.physicsBody?.applyImpulse(CGVector(dx: 50, dy: 50))
            }
        }
    }
    
    //ball image changer
    func hitcounter() {
        
        if counter == 2 {
            ball.texture = ballcolor[4]
            index = 1
            player.physicsBody?.restitution = 1.05
        }
        if counter == 3 {
            ball.texture = ballcolor[5]
            index = 1
        }
        if counter > 3 {
            let textureCounter = Int.random(in: 0 ..< 3)
            ball.texture = ballcolor[textureCounter]
            index = textureCounter
        }
        enemy.texture = padcolor[index]
    }
}

