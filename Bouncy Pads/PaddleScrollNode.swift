//
//  ScrollNode.swift
//  Street Chase
//
//  Created by Marco Matamoros on 2016-06-27.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import SceneKit

class PaddleScrollNode: SCNNode {
    
    private let paddleWidth = (Paddle.paddleNode.boundingBox.max.x - Paddle.paddleNode.boundingBox.min.x)
    private let firstPosition: Float
    private var scrollingSpeed:Float
    private var space:Float?
    private var repeatedSpikes = 0
    private var repeatedEmpty = 0
    private var reverse = false
    private var currentlyMoving = false
    var maxRepeatedSpikes = 1
    var maxRepeatedEmpty = 3
    
    
    init(withSpeed speed: Float, reverse: Bool, firstPosition: Float) {
        scrollingSpeed = speed
        self.reverse = reverse
        self.firstPosition = firstPosition
        
        super.init()
    }
    
    convenience init(quantity: Int, space: Float, reverse: Bool) {
        let paddleWidth = (Paddle.paddleNode.boundingBox.max.x - Paddle.paddleNode.boundingBox.min.x)
        
        self.init(withSpeed: paddleWidth + space, reverse: reverse, firstPosition: -(paddleWidth * Float(quantity) + space * (Float(quantity) - 1))/2 + paddleWidth/2)
        
        self.space = space
        
        var total:Float = firstPosition
        
        for i in 1...quantity + 1 {
            var spikes:Bool
            
            if i == 1 {
                spikes = false
            }
            else {
                spikes = self.spikes()
            }
            let child = Paddle(hasSpikes: spikes)
            child.position = SCNVector3(total, 0, 0)
            
            if reverse {
                child.eulerAngles = SCNVector3(0, 0, Float.pi)
            }
            
            self.addChildNode(child)
            
            total += paddleWidth + space
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spikes() -> Bool {
        if repeatedSpikes >= maxRepeatedSpikes {
            repeatedSpikes = 0
            repeatedEmpty += 1
            
            return false
        }
        if repeatedEmpty >= maxRepeatedEmpty {
            repeatedSpikes += 1
            repeatedEmpty = 0
            
            return true
        }
        let random = Int(arc4random_uniform(2))
        
        if random == 0 {
            repeatedSpikes = 0
            repeatedEmpty += 1
            
            return false
        }
        
        repeatedSpikes += 1
        repeatedEmpty = 0
        
        return true
    }
    
    func scroll() {
        if !currentlyMoving {
            for node in self.childNodes {
                
                if let child = node as? Paddle {
                    let scroll = SCNAction.move(to: SCNVector3(child.position.x - scrollingSpeed, 0, 0), duration: 0.1)
                    
                    child.runAction(scroll) {
                        self.currentlyMoving = false
                        
                        if (child.position.x <= self.firstPosition - self.scrollingSpeed) {
                            let newChild = Paddle(hasSpikes: self.spikes())
                            
                            let delta = child.position.x + self.scrollingSpeed
                            newChild.position = SCNVector3(x: (self.scrollingSpeed) * (Float(self.childNodes.count) - 1) + delta, y: child.position.y, z: child.position.z)
                            
                            if self.reverse {
                                newChild.eulerAngles = SCNVector3(0, 0, Float.pi)
                            }
                            
                            child.removeFromParentNode()
                            self.addChildNode(newChild)
                        }
                    }
                    
                    currentlyMoving = true
                }
            }
        }
    }
}

class Paddle: SCNNode {
    static let paddleNode: SCNNode! = SCNScene(named: "art.scnassets/Paddle.scn")?.rootNode.childNode(withName: "Paddle", recursively: true)
    static let spikesNode: SCNNode! = SCNScene(named: "art.scnassets/Paddle.scn")?.rootNode.childNode(withName: "Spikes", recursively: true)
    private let fadeFactor: Double
    private(set) var hits: Int
    
    init(hasSpikes: Bool, maxHits: Int = 1) {
        hits = maxHits
        fadeFactor = 1/Double(hits)
        
        super.init()

        self.geometry = Paddle.paddleNode.geometry
        
        self.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNBox(width: CGFloat(self.boundingBox.max.x - self.boundingBox.min.x), height: CGFloat(self.boundingBox.max.y - self.boundingBox.min.y), length: CGFloat(self.boundingBox.max.z - self.boundingBox.min.z), chamferRadius: 0), options: nil))
        self.physicsBody?.categoryBitMask = 1 << 1
        self.physicsBody?.contactTestBitMask = 1
        self.physicsBody?.damping = 0
        self.physicsBody?.restitution = 1
        self.physicsBody?.friction = 0
        
        if hasSpikes {
            self.physicsBody?.categoryBitMask = 1 << 2
            
            let spike = SCNNode(geometry: Paddle.spikesNode.geometry)
            spike.position = SCNVector3(x: 0, y: self.boundingBox.max.y + spike.boundingBox.max.y, z: 0)
            
            spike.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: spike, options: nil))
            spike.physicsBody?.categoryBitMask = 1 << 2
            spike.physicsBody?.contactTestBitMask = 1
            
            self.addChildNode(spike)
        }
    }
    
    func hit() {
        hits -= 1
        
//        let fade = SCNAction.fadeOpacity(by: CGFloat(-fadeFactor), duration: 0.1 * fadeFactor)
//
//        self.runAction(fade)
        self.opacity -= CGFloat(fadeFactor)
        
        if hits <= 0 {
            self.physicsBody?.categoryBitMask = 0x1 << 3
            self.physicsBody?.collisionBitMask = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

