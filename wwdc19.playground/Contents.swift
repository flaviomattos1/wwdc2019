//: A SpriteKit based Playground
import PlaygroundSupport
import SpriteKit

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 384, height: 512))
if let scene = GameScene(fileNamed: "GameScene") {
    //Set; the; scale mode to scale to fit the window
    scene.scaleMode = .aspectFit

    //Present; the; scene
    sceneView.presentScene(scene)
}


PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
