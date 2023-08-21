//
//  TutorialViewController.swift
//  ARHouseOfMemes
//
//  Created by Lucas Petrola on 21/08/23.
//

import UIKit
import SceneKit
import ARKit

class TutorialViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [SCNDebugOptions.showWireframe, SCNDebugOptions.showFeaturePoints, SCNDebugOptions.showCreases]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        UIApplication.shared.isIdleTimerDisabled = true
        sceneView.autoenablesDefaultLighting = true
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        addGestures()
        
    }
    
    func addGestures () {
        let tapped = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        sceneView.addGestureRecognizer(tapped)
    }
    
    @objc func tapGesture (sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        
        if hitTest.isEmpty {
            print("No Plane Detected")
            return
        } else {
            
            guard let scene = SCNScene(named: "art.scnassets/Pikachu/pika.scn") else {
                print ("n carregou scene")
                return
            }
            
            guard let node = scene.rootNode.childNode(withName: "pika", recursively: false) else {
                print ("n carregou node")
                return
            }
            
            
            let columns = hitTest.first?.worldTransform.columns.3
            
            node.position = SCNVector3(x: columns!.x, y: columns!.y, z: columns!.z)
            node.scale = SCNVector3(0.01, 0.01, 0.01)
            
            sceneView.scene.rootNode.addChildNode(node)
            
            sceneView.scene.rootNode.enumerateChildNodes { (child, _) in
                if child.name == "MeshNode" || child.name == "TextNode" {
                    child.removeFromParentNode()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        let meshNode : SCNNode
        let textNode : SCNNode
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        guard let meshGeometry = ARSCNPlaneGeometry(device: sceneView.device!)
        else { fatalError("Não conseguiu criar geometria") }
        
        meshGeometry.update(from: planeAnchor.geometry)
        meshNode = SCNNode(geometry: meshGeometry)
        meshNode.opacity = 0.6
        meshNode.name = "MeshNode"
        
        guard let material = meshNode.geometry?.firstMaterial
        else { fatalError("ARSCNPlaneGeometry always has one material") }
        material.diffuse.contents = UIColor.blue
        
        node.addChildNode(meshNode)
        
        let textGeometry = SCNText(string: "Plane", extrusionDepth: 1)
        textGeometry.font = UIFont(name: "Futura", size: 75)
        
        textNode = SCNNode(geometry: textGeometry)
        textNode.name = "TextNode"
        
        textNode.simdScale = SIMD3(repeating: 0.0005)
        textNode.eulerAngles = SCNVector3(x: Float(-90.degreesToradians), y: 0, z: 0)
        
        node.addChildNode(textNode)
        
        textNode.centerAlign()
        
        print("Plane node adicionado")
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = node.childNode(withName: "MeshNode", recursively: false)
        
        if let planeGeometry = planeNode?.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: planeAnchor.geometry)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

