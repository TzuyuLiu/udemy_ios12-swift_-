//
//  ViewController.swift
//  AR Ruler
//
//  Created by 劉子瑜 on 2019/4/26.
//  Copyright © 2019 劉子瑜. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNodes = [SCNNode]()  //這個Array將儲存所有我們放在scene上的紅點
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
 
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
    
    //偵測到有觸控螢幕時會觸發以下method
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNodes.count >= 2 {
            for dot in dotNodes{
                dot.removeFromParentNode()  //刪除在scene上的紅點
            }
            dotNodes = [SCNNode]()  //刪除在dotNodes裡面的資料
        }
        
        //將碰觸到的位置純存到touchLocation，此位置是2D，.location是得到2D的位置
        if let touchLocation = touches.first?.location(in: sceneView){
            
            //將2D轉3D位置，hitTest可以提供持續的3D surface
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            
            if let hitResult = hitTestResults.first{
                addDot(at: hitResult)   //將3D位置傳給addDot
            }
        }
        
    }
    
    func addDot(at hitResult : ARHitTestResult){
    
        //加紅點
        let dotGeometry = SCNSphere(radius: 0.003)
        
        let dotMaterial = SCNMaterial()
        
        dotMaterial.diffuse.contents = UIColor.red  //用diffuse.content設定顏色

        dotGeometry.materials = [dotMaterial]
        
        let dotNode = SCNNode(geometry: dotGeometry)
        
        //將取得的位置轉換成現實世界的位置，並且幾位置給紅點
        dotNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        
        //將紅點放到scene上面
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        dotNodes.append(dotNode)    //array用append增加東西
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    func calculate(){
        let start = dotNodes[0]     //一開始的測量位置
        let end = dotNodes[1]      //結束的測量位置
        
        //算出相異距離
        
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - end.position.z
        
        let distance = sqrt(pow(a, 2)+pow(b, 2)+pow(c, 2))  //a*a+b*b+c*c再開根號
        
        print(distance)
        
        updateText(text:"\(distance)",atPosition: end.position)
        
    }
    
    //創造3D的字
    func updateText(text:String ,atPosition position: SCNVector3){
        
        textNode.removeFromParentNode()
        
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        //使用SCNNode產生3D文字
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
 
}
