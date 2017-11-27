//
//  ViewController.swift
//  Visualizer
//
//  Created by Taketo Sano on 2017/09/29.
//  Copyright © 2017年 Taketo Sano. All rights reserved.
//

import Cocoa
import SceneKit

class SceneViewController : NSViewController {
    var wValue: CGFloat = 0
    
    var scene: SCNScene!
    @IBOutlet var sceneView:  SCNView!
    var cameraNode: SCNNode!
    var cameraTargetNode: SCNNode!
    var axesNode:   SCNNode!
    var objectsNode: SCNNode!
    
    // TODO create some entity struct
    var objects: [Entity] = [] {
        didSet {
            generateObjectNodes()
        }
    }
    
    @IBOutlet var slider: NSSlider!
    
    override func viewDidLoad() {
        setupScene()
    }
    
    private func setupScene() {
        scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        
        cameraNode = {
            let cameraNode = SCNNode()
            let camera = SCNCamera()
            cameraNode.camera = {
                camera.usesOrthographicProjection = true
                camera.orthographicScale = 5
                return camera
            }()
            cameraNode.position = Vec3(20, 10, 20)
            return cameraNode
        }()
        
        scene.rootNode.addChildNode(cameraNode)
        
        // xyz-axis
        axesNode = {
            let axesNode = SCNNode()
            
            let dirs = [SCNVector4(0, 0, 1, -PI_2), SCNVector4.zero, SCNVector4(1, 0, 0, PI_2)]
            for d in dirs {
                let axis = SCNCylinder(radius: 0.01, height: 10)
                axis.color = .black
                axis.radialSegmentCount = 6
                let axisNode = SCNNode(geometry: axis)
                
                axisNode.rotation = d
                axesNode.addChildNode(axisNode)
                
                let cone = SCNCone(topRadius: 0, bottomRadius: 0.1, height: 0.2)
                cone.color = .black
                cone.radialSegmentCount = 6
                let coneNode = SCNNode(geometry: cone)
                coneNode.position = Vec3(0, 5, 0)
                axisNode.addChildNode(coneNode)
            }
            
            let originNode = SCNNode(geometry: {
                let origin = SCNSphere(radius: 0.1)
                origin.color = .black
                return origin
            }())
            
            axesNode.addChildNode(originNode)
            cameraTargetNode = originNode
            
            return axesNode
        }()
        
        scene.rootNode.addChildNode(axesNode)
        
        let target = SCNLookAtConstraint(target: cameraTargetNode)
        target.isGimbalLockEnabled = true
        cameraNode.constraints = [target]
        
        objectsNode = SCNNode()
        scene.rootNode.addChildNode(objectsNode)
    }
    
    func generateObjectNodes() {
        func add(_ _e: Entity, to parent: SCNNode) {
            switch _e {
            case let e as Point:
                let n = PointNode(e)
                parent.addChildNode(n)
                
            case let e as Edge:
                let n = EdgeNode(e)
                parent.addChildNode(n)
                
            case let e as Polyhedron:
                let n = SCNNode()
                parent.addChildNode(n)
                
                for p in e.points { add(p, to: n) }
                for e in e.edges  { add(e, to: n) }

            default:
                break
            }
        }
        
        objects.forEach { e in add(e, to: objectsNode) }
        updateObjects()
    }
    
    func updateObjects() {
//        objects.forEach { e in
//            switch e {
//            case let p as Point:
//                if let n = p.node {
//                    n.opacity = (abs(p.w - wValue) < 1) ? exp(-pow(p.w - wValue, 2) * 15) : 0
//                }
//            default:
//                break
//            }
//        }
    }
    
    // interactions
    
    override func magnify(with event: NSEvent) {
        let camera = cameraNode.camera!
        let s = 5.0
        camera.orthographicScale = clamp(camera.orthographicScale - s * Double(event.magnification), 1.0, Double.infinity)
    }
    
    override func scrollWheel(with event: NSEvent) {
        let scale: CGFloat = 30.0
        let p = cameraNode.position
        let t = atan2(p.z, p.x) + event.deltaX / scale
        let s = clamp(atan2(p.y, len(p.x, p.z) ) + event.deltaY / scale, -PI_2, PI_2)
        cameraNode.position = 20 * Vec3(cos(s) * cos(t), sin(s), cos(s) * sin(t))
    }
    
    @IBAction func sliderMoved(target: NSSlider) {
        wValue = CGFloat(target.doubleValue)
        updateObjects()
        
        let e = objects[0] as! Polyhedron
        let p = e.points[0]
        p.position = Vec4.zero
    }
}
