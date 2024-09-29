//
//  ViewController.swift
//  ARSample
//
//  Created by 김호성 on 2024.09.29.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/Ampharos.scn")!
        
        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) else { return }
        
        configuration.trackingImages = imageToTrack
        
        configuration.maximumNumberOfTrackedImages = 1

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
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


extension ViewController: ARSCNViewDelegate {
    // renderer(_:nodeFor:)를 anchor에 따라 새로운 노드를 추가합니다
    // anchor: 화면에 감지된 이미지
    // 결과 값으로 3D객체(node)를 리턴합니다.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // 빈 노드를 생성시킵니다.
        let node = SCNNode()
        
        // 이미지를 추적해야 하므로 감지된 anchor를 ARImageAnchor로 형변환을 시켜줍니다.
        // 또한 imageAnchor.referenceImage.name로 접근하여 지금 인식되고 있는 사진의 이름도 알 수 있습니다.
        guard let imageAnchor = anchor as? ARImageAnchor else { return node }
        
        print("imageAnchor: \(imageAnchor.referenceImage.name)")
        
        let planeNode = detectCard(at: imageAnchor)
        
        node.addChildNode(planeNode)
        makeModel(on: planeNode)
        
        return node
    }
    
    func detectCard(at imageAnchor: ARImageAnchor) -> SCNNode {
        // 카드를 인식해야 하므로 감지된 카드의 크기를 입력해 준다.(하드코딩 할 필요 X)
        // 카드위에 3D객체 형상(plane)을 렌더링을 시킨다.
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                             height: imageAnchor.referenceImage.physicalSize.height)
        
        // 투명하게 만들기
        plane.firstMaterial?.diffuse.contents = UIColor(white: 1.0, alpha: 0.5)
        
        // 뼈대 설정
        let planeNode = SCNNode(geometry: plane)
        
        // 이전까지는 plane이 수직으로 생성이 되므로 우리는 스티커에 맞게 90도로 눞여 줘야 한다.
        // eulerAngles은 라디안 각도를 표현하기 위함.
        planeNode.eulerAngles.x = -(Float.pi / 2)
        
        return planeNode
    }
    
    func makeModel(on planeNode: SCNNode) {
        let ampharosScene = SCNScene(named: "art.scnassets/Ampharos.scn")!
        let ampharosNode = ampharosScene.rootNode
        
        // 생성된 3D 모델의 각도와 위치를 조정
        ampharosNode.eulerAngles.x = Float.pi/2
        ampharosNode.position.z = -(ampharosNode.boundingBox.min.y * 6)/1000
        ampharosNode.scale = SCNVector3(0.0005, 0.0005, 0.0005)

        planeNode.addChildNode(ampharosNode)
    }
}
