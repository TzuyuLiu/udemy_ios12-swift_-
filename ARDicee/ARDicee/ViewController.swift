//
//  ViewController.swift
//  ARDicee
//
//  Created by 劉子瑜 on 2019/4/25.
//  Copyright © 2019 劉子瑜. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //顯示點點
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
 
        // Run the view's session
        sceneView.session.run(configuration)
        
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    //MARK: - Dice Rendering Methods
    
    
    //偵測到有觸控螢幕時會觸發以下method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            let touchLocation = touch.location(in: sceneView)  //傳觸碰的地方，使用的資料型態是2D位置
            
            //偵測觸碰位置(是否在平面上)，existingPlaneUsingExtent:找出位置
            //如果在平面上，result就不是空值，results的是一個陣列，所以用isEmpty去看是否為空
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
                
                addDice(atLocation: hitResult)
                
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult) {
        
        //創造一個骰子
        let dicescene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        if let diceNode = dicescene.rootNode.childNode(withName: "Dice", recursively: true){
            
            //y的boundingSphere：因為y的參數是用一半高一半低的方式算出，所以用此來矯正不讓骰子飄浮起來
            //將位置轉換成現實世界的位置
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            
            // Set the scene to the view
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        }
    }
    
    
    func roll(dice: SCNNode){
        
        //arc4random_uniform:產生亂數，Float.pi / 2：每次轉90度，也就是轉一面
        //在x平面上就是4個面
        let randomX = Float(arc4random_uniform(4) + 1)*(Float.pi / 2)
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        
        //不用randomY是因為y不管怎麼轉同一面都是朝著上
        
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX*3),  //看要轉幾度，轉越多度CG看起來越快
                y: 0,
                z: CGFloat(randomZ*3),
                duration: 0.5)
        )
        
    }

    
    
    func rollAll(){
        
        if !diceArray.isEmpty{
            for dice in diceArray{
                roll(dice:dice)
            }
        }
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    //搖手機時會出現以下function
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
    }
    
    
    //MARK: - ARSCNViewDelegateMethods
    
    //偵測到水平面會觸發以下function
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planAnchor)
        
        node.addChildNode(planeNode)
 
    }
    
    
    
    //MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planAnchor: ARPlaneAnchor)-> SCNNode{
        
        let plane = SCNPlane(width: CGFloat(planAnchor.extent.x), height: CGFloat(planAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(x: planAnchor.center.x, y: 0, z: planAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
        
    }
    
}

