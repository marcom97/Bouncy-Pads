//
//  GameViewController.swift
//  Bouncy Pads
//
//  Created by Marco Matamoros on 2017-06-26.
//  Copyright © 2017 Marco Matamoros. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController, SCNPhysicsContactDelegate {
    let scrollNode = PaddleScrollNode(quantity: 6, space: 1.375, reverse: false)
    let ball = SCNNode(geometry: SCNSphere(radius: 2))
    var firstPaddleHit = false
    var isFirstTap = true
//    let overlayScene = SKScene(fileNamed: "GameScene") as? GameScene
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.antialiasingMode = .multisampling4X
//        scnView.debugOptions = .showPhysicsShapes
        
        // create a new scene
        let scene = SCNScene()
        
        // setup physics for the scene
        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity.y = -500
        // create and add a camera to the scene
        let adjustedWidth = 1366 / scnView.bounds.height * scnView.bounds.width
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.eulerAngles = SCNVector3(-atan(1/sqrt(2)), -45 * CGFloat.pi/180, 0)
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale =  42.0625 * Double(1024 / adjustedWidth)
        cameraNode.camera?.zNear = -60
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .directional
        lightNode.eulerAngles = SCNVector3(x: -45 * Float.pi/180, y: -80 * Float.pi/180, z: 0)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
//        let ambientLightNode = SCNNode()
//        ambientLightNode.light = SCNLight()
//        ambientLightNode.light!.type = .ambient
//        ambientLightNode.light!.color = UIColor.darkGray
//        scene.rootNode.addChildNode(ambientLightNode)
        
        scrollNode.position.y = -22.4375
        scene.rootNode.addChildNode(scrollNode)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.cyan
        
        ball.geometry?.insertMaterial(material, at: 0)
        ball.position.x = -32.0625
        scene.rootNode.addChildNode(ball)
        
        ball.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: SCNSphere.init(radius: 2), options: nil))
        ball.physicsBody?.restitution = 0.99
        ball.physicsBody?.damping = 0
        ball.physicsBody?.friction = 0
        ball.physicsBody?.angularVelocityFactor = SCNVector3Zero
        ball.physicsBody?.categoryBitMask = 0x1
        ball.physicsBody?.contactTestBitMask = 0xFFFFFFFF
        ball.physicsBody?.collisionBitMask = 0xFFFFFFF7
        ball.physicsBody?.isAffectedByGravity = false
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
//        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
//        scnView.backgroundColor = UIColor(red:1.00, green:0.945, blue:0.91, alpha:1.0)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var secondBody: SCNNode
        
        if contact.nodeA.physicsBody!.categoryBitMask < contact.nodeB.physicsBody!.categoryBitMask {
            secondBody = contact.nodeB
        }
        else {
            secondBody = contact.nodeA
        }
        
        if secondBody.physicsBody!.categoryBitMask & 1 << 1 != 0 {
            if let paddle = secondBody as? Paddle {
                paddle.hit()
                
                if firstPaddleHit {
//                    overlayScene?.score += 1
//
//                    if overlayScene?.score == 10 {
//                        scrollNode.maxRepeatedSpikes = 2
//                    }
//                    else if overlayScene?.score == 25 {
//                        scrollNode.maxRepeatedEmpty = 2
//                    }
//                    else if overlayScene?.score == 50 {
//                        scrollNode.maxRepeatedEmpty = 1
//                    }
                }
                else {
                    firstPaddleHit = true
                }
            }
        }
        else {
            if secondBody.physicsBody!.categoryBitMask & 1 << 2 != 0 {
//                let explosion = SKEmitterNode(fileNamed: "Explosion")
//                explosion?.position = ball.position
//
//                let effectNode = SKEffectNode()
//                effectNode.addChild(explosion!)
//                effectNode.zPosition = -1
//
//                self.addChild(effectNode)
//
                ball.removeFromParentNode()
            }
            else {
                ball.physicsBody?.contactTestBitMask = 0
                let remove = SCNAction.sequence([SCNAction.wait(duration: 2), SCNAction.removeFromParentNode()])
                ball.runAction(remove)
            }
            
            scrollNode.isPaused = true
//            overlayScene?.gameOver()
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        if isFirstTap {
            ball.physicsBody?.isAffectedByGravity = true
            isFirstTap = false
        }
        else {
            scrollNode.scroll()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .portraitUpsideDown
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
