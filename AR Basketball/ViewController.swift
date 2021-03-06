//
//  ViewController.swift
//  AR Basketball
//
//  Created by Artyom Mihailovich on 9/9/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addHoopButton: UIButton!
    var currentNode: SCNNode!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene

        registerGestureRecognizer()
    }
    
    func registerGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        
        //Scene view to be accessed
        //access to point of view to scene view
        guard let sceneView = gestureRecognizer.view as? ARSCNView else {
            return
        }
        
        guard let centerPoint = sceneView.pointOfView else {
            return
        }
        
        //Transform matrix
        //the orientation
        //the location of the camera
        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41,y: cameraTransform.m42, z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31,y: -cameraTransform.m32, z: -cameraTransform.m33)
        
        
        //x1 + x2, y1 + y2, z1 + z2
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x, cameraLocation.y + cameraOrientation.y, cameraLocation.z + cameraOrientation.z)
        
        //Create ball
        let ball = SCNSphere(radius: 0.15)
        let material = SCNMaterial()
        //Add "Skin" for our ball from image
        material.diffuse.contents =  UIImage(named: "basketballSkin.png")
        ball.materials = [material]
        
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
        ballNode.physicsBody = physicsBody
        
        //Add Force to our ball...
        let forceVector: Float = 6
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraOrientation.x * forceVector, y: cameraOrientation.y * forceVector, z: cameraOrientation.z * forceVector), asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(ballNode)
        
    }
    
    
    //Add hoop...
    func addBackBoard(){
        //Do the scene with hoop
        guard let backBoardScene = SCNScene(named: "art.scnassets/hoop.scn") else {
            return
        }
        
        guard let backBoardNode = backBoardScene.rootNode.childNode(withName: "backboard", recursively: false) else {
            return
        }
        
        backBoardNode.position = SCNVector3(x: 0, y: 0.5, z: -3)
        
        // For understanding our basket ring
        let physicsShape = SCNPhysicsShape(node: backBoardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        backBoardNode.physicsBody = physicsBody
        
        
        sceneView.scene.rootNode.addChildNode(backBoardNode)
        currentNode  = backBoardNode
    }
    
    //Create Action for backBoard for moving ±1m.
    func horizontalAction(node: SCNNode) {
        let leftAction = SCNAction.move(by: SCNVector3(x: -1, y: 0, z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1, y: 0, z: 0), duration: 3)
        
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    func roundAction(node: SCNNode) {
        let upLeft = SCNAction.move(by: SCNVector3(x: 1, y: 1, z: 0 ), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(x: 1, y: -1, z: 0 ), duration: 2)
        let downLeft = SCNAction.move(by: SCNVector3(x: -1, y: -1, z: 0 ), duration: 2)
        let upRight = SCNAction.move(by: SCNVector3(x: -1, y: 1, z: 0 ), duration: 2)
        
        let actionSequence = SCNAction.sequence([upLeft, downRight, downLeft, upRight])
        
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: Action Buttons...
    @IBAction func addHoop(_ sender: Any) {
        addBackBoard()
        addHoopButton.isHidden = true
        
    }
    
    @IBAction func startRoundedAction(_ sender: Any) {
        roundAction(node: currentNode)
    }
    
    @IBAction func stopAllActions(_ sender: Any) {
        currentNode.removeAllActions()
    }
    @IBAction func horizontalAction(_ sender: Any) {
        horizontalAction(node: currentNode)
    }
}
