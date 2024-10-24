//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2024/10/24.
//

import UIKit
import AVFoundation
import WWPrint

// MARK: - 多鏡頭功能測試 (iOS 13.0 ~ / iPhone XR ~)
final class ViewController: UIViewController {
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    private let session = AVCaptureMultiCamSession()
    private var previewLayers: [AVCaptureVideoPreviewLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        multiCamSessionSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRunning()
    }
}

// MARK: - 多鏡頭設置
private extension ViewController {
    
    /// 多鏡頭初始設定
    func multiCamSessionSetting() {
        
        guard AVCaptureMultiCamSession.isMultiCamSupported else { wwPrint("多相機不支援"); return }
        
        session.beginConfiguration()
        
        let cameraConfigs: [(AVCaptureDevice.DeviceType, AVCaptureDevice.Position, UIView)] = [
            (.builtInWideAngleCamera, .back, view1),
            (.builtInUltraWideCamera, .back, view2),
            (.builtInWideAngleCamera, .front, view3)
        ]
        
        for (deviceType, position, previewView) in cameraConfigs {
            
            guard let camera = AVCaptureDevice.default(deviceType, for: .video, position: position),
                  let input = try? AVCaptureDeviceInput(device: camera),
                  session.canAddInput(input) 
            else {
                continue
            }
            
            session.addInputWithNoConnections(input)
            
            let output = AVCaptureVideoDataOutput()
            guard session.canAddOutput(output) else { continue }
            session.addOutputWithNoConnections(output)
            
            let connection = AVCaptureConnection(inputPorts: input.ports, output: output)
            guard session.canAddConnection(connection) else { continue }
            session.addConnection(connection)
            
            let previewLayer = AVCaptureVideoPreviewLayer()
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.setSessionWithNoConnection(session)
            previewLayer.frame = previewView.bounds
            
            guard let videoPort = input.ports.first(where: { $0.mediaType == .video }) else { continue }
            let previewLayerConnection = AVCaptureConnection(inputPort: videoPort, videoPreviewLayer: previewLayer)
            
            guard session.canAddConnection(previewLayerConnection) else { continue }
            session.addConnection(previewLayerConnection)
            
            previewView.layer.addSublayer(previewLayer)
            previewLayers.append(previewLayer)
        }
        
        session.commitConfiguration()
    }
    
    /// 啟動多鏡頭
    func startRunning() {
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in session.startRunning() }
    }
}
