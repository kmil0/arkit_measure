//
//  ViewController.swift
//  MeasurementApp
//
//  Created by Camilo Rodriguez on 2/05/23.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()
    var textNode = SCNNode()
    var meterValue : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()
                
            }
        }
        
        dotNodes = [SCNNode]()
        if let touchLocation = touches.first?.location(in: sceneView){
            let hitTestResults = sceneView.hitTest(touchLocation ,  types: .featurePoint)
            if let hitResult = hitTestResults.first{
                addDot(at: hitResult)
            }}
                    
            
//            let estimadedPlane: ARRaycastQuery.Target = .estimatedPlane
//            let alignment: ARRaycastQuery.TargetAlignment = .any
//
//            let query: ARRaycastQuery? = sceneView.raycastQuery(from: touchLocation, allowing: estimadedPlane, alignment: alignment)
//
//            if let nonOptQuery: ARRaycastQuery = query {
//                let result:[ARRaycastResult] = sceneView.session.raycast(nonOptQuery)
//                guard let rayCast: ARRaycastResult = result.first
//                else {return}
//
//                addDot(at: rayCast)
//
//            }
//        }
        
        func addDot(at hitResult: ARHitTestResult){
            let dotGeometry = SCNSphere(radius: 0.005)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            dotGeometry.materials = [material]
            
            
            let dotNode = SCNNode(geometry: dotGeometry)
            dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            sceneView.scene.rootNode.addChildNode(dotNode)
            dotNodes.append(dotNode)
            
            if dotNodes.count >= 2 {
                calculate()
            }
        }
        
        func calculate (){
            let start = dotNodes[0]
            let end = dotNodes[1]
            
            print(start.position)
            print(end.position)
            
            let deltaX = end.position.x - start.position.x
            let deltaY = end.position.y - start.position.y
            let deltaZ = end.position.z - start.position.z
            
            let squaredDeltaX = pow(deltaX, 2)
            let squaredDeltaY = pow(deltaY, 2)
            let squaredDeltaZ = pow(deltaZ, 2)
            
            let sumOfSquaredDeltas = squaredDeltaX + squaredDeltaY + squaredDeltaZ
            
            let distance = sqrt(sumOfSquaredDeltas)
            
            meterValue = Double(abs(distance))
            
            let heightMeter = Measurement(value: meterValue ?? 0, unit: UnitLength.meters)
            let heightInches = heightMeter.converted(to: UnitLength.inches)
            //convert to centimeters
            let heightCentimeter = heightMeter.converted(to: UnitLength.centimeters)
            
            let value =  "\(heightCentimeter)"
            let finalMesuarement = String(value.prefix(6))
            updateText(text: finalMesuarement, atPosition: end.position)
            
        }
        
        func updateText(text: String, atPosition position: SCNVector3 ){
            textNode.removeFromParentNode()
            let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
            textGeometry.firstMaterial?.diffuse.contents = UIColor.red
            textNode = SCNNode(geometry: textGeometry)
            textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
            textNode.scale = SCNVector3(x:0.01, y:0.01, z:0.01 )
            sceneView.scene.rootNode.addChildNode(textNode)
            
        
        }
        
        
        
    }
}
