//
//  SceneCoordinator.swift
//  SceneKit_Neumorphism
//
//  Created by Geri Borbás on 2020. 03. 02..
//  Copyright © 2020. Geri Borbás. All rights reserved.
//

import SwiftUI
import SceneKit
   
    
class SceneCoordinator: NSObject
{
    
    
    var sceneView: SCNView
    
    
    private var scene: SCNScene
    private var camera: SCNCamera
    private var backplane: SCNNode
    private var buttonNodes: SCNNode
    
    
    override init()
    {
        // iPhone 11 Screen.
        let width = 414.0
        let height = 818.0
        
        // Scene.
        self.scene = SCNScene()
        
        // Scene view.
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        let sceneView = SCNView(frame: frame)
            sceneView.allowsCameraControl = true
            sceneView.antialiasingMode = .multisampling4X
            sceneView.contentMode = .redraw
            sceneView.scene = self.scene
                
        // Camera.
        self.camera = SCNCamera()
        self.camera.usesOrthographicProjection = true
        self.camera.orthographicScale = height / 2
        self.camera.zNear = -height
        self.camera.zFar = height
        
        // Camera node.
        let cameraNode = SCNNode()
            cameraNode.camera = self.camera
        
        let light = SCNLight()
        // Light.
        let temperatureMultiplier: CGFloat = 0.6
            light.type = .omni
            light.intensity = 600
            light.temperature = 6500 / temperatureMultiplier
            light.shadowMode = .deferred
        
        // Light node.
        let lightNode = SCNNode()
            lightNode.light = light
            lightNode.position = SCNVector3(x: -300, y: 300, z: 200)
            
        // Backlight.
        let backlight = SCNLight()
            backlight.type = .omni
            backlight.intensity = 100
            backlight.temperature = 6500 * temperatureMultiplier
            backlight.shadowMode = .deferred
        
        // Backlight node.
        let backlightNode = SCNNode()
            backlightNode.light = backlight
            backlightNode.position = SCNVector3(x: 100, y: -100, z: 300)
                
        // Ambient light.
        let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.intensity = 300
        
        // Ambient light node.
        let ambientLightNode = SCNNode()
            ambientLightNode.light = ambientLight
        
        // Create backplane.
        self.backplane = SCNNode(geometry: SCNPlane(width: CGFloat(width), height: CGFloat(height)))
        
        // Create buttons.
        self.buttonNodes = SCNNode()
        
        // Add nodes.
        self.scene.rootNode.addChildNode(cameraNode)
        self.scene.rootNode.addChildNode(ambientLightNode)
        self.scene.rootNode.addChildNode(lightNode)
        self.scene.rootNode.addChildNode(backlightNode)
        self.scene.rootNode.addChildNode(self.backplane)
        self.scene.rootNode.addChildNode(self.buttonNodes)
        
        // Reference.
        self.sceneView = sceneView
        
        // Default.
        super.init()
        
        // Rendering events.
        self.sceneView.delegate = self
    }
    
    func onChange(_ snapshot: Snapshot)
    {
        print("SceneKitView.environment.onChange")
        print("viewBounds: \(String(describing: snapshot.viewBounds))")
        print("buttonFramesForNames[\"library\"]: \(String(describing: snapshot.buttonFramesForNames["library"]))")
                
        // Adjust bounds.
        self.sceneView.frame = snapshot.viewBounds
        
        // Backplane size.
        self.backplane.geometry = SCNPlane(
            width: snapshot.viewBounds.width,
            height: snapshot.viewBounds.height
        )

        // Camera settings.
        let height = Double(snapshot.viewBounds.height)
        self.camera.orthographicScale = height / 2
        self.camera.zNear = -height
        self.camera.zFar = height
        
        // Recreate capsules (if snapshots any).
        if
            let frame_1 = snapshot.buttonFramesForNames["new"],
            let frame_2 = snapshot.buttonFramesForNames["camera"],
            let frame_3 = snapshot.buttonFramesForNames["library"]
        {
            let outlineWidth: CGFloat = 30.0
            self.buttonNodes.enumerateChildNodes{ eachNode, stop in eachNode.removeFromParentNode() }
            self.buttonNodes.addChildNode(CapsuleNode.Node(
                for: frame_1,
                in: snapshot.viewBounds,
                outlineWidth: outlineWidth
            ))
            self.buttonNodes.addChildNode(CapsuleNode.Node(
                for: frame_2,
                in: snapshot.viewBounds,
                outlineWidth: outlineWidth
            ))
            self.buttonNodes.addChildNode(CapsuleNode.Node(
                for: frame_3,
                in: snapshot.viewBounds,
                outlineWidth: outlineWidth
            ))
        }
        
        self.buttonNodes.position = SCNVector3.init()

        print("sceneView.frame: \(String(describing: sceneView.frame))")
    }
}


extension SceneCoordinator: SCNSceneRendererDelegate
{

    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        // print("SceneKitView.Coordinator.renderer(_:updateAtTime:)")
    }
}
