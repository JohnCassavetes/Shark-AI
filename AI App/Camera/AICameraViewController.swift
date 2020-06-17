//
//  AICameraViewController.swift
//  AI App
//
//  Created by a on 10/06/20.
//  Copyright © 2020 Gaw. All rights reserved.
//

import UIKit
import AVKit
import Vision

@available(iOS 12.0, *)
class AICameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBOutlet weak var belowView: UIView!
    
    @IBOutlet weak var objectNameLabel: UILabel!
    
    @IBOutlet weak var accuracyLabel: UILabel!
    
    
    var model = Resnet50().model
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
            
            
            //camera
            let captureSession = AVCaptureSession()
            
            guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
            captureSession.addInput(input)
            
            captureSession.startRunning()
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(previewLayer)
            previewLayer.frame = view.frame
            // The camera is now created!
            
            view.addSubview(belowView)
            
            belowView.clipsToBounds = true
            belowView.layer.cornerRadius = 15.0
            belowView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            
            let  dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(dataOutput)
            
            
            
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            guard let model = try? VNCoreMLModel(for: model) else { return }
            let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                
                guard let results = finishedReq.results as? [VNClassificationObservation] else {return}
                guard let firstObservation = results.first else {return}
                
                let name: String = firstObservation.identifier
                let acc: Int = Int(firstObservation.confidence * 100)
                
                DispatchQueue.main.async {
                    self.objectNameLabel.text = name
                    self.accuracyLabel.text = "Accuracy: \(acc)%"
                }
                
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
            
        }

        

    }


//Other code [without any of the view]
    
    /*
    
    let identifierLabel: UILabel = {
            let label = UILabel()
            label.backgroundColor = .white
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // here is where we start up the camera

            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            
            guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
            captureSession.addInput(input)
            
            captureSession.startRunning()
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            view.layer.addSublayer(previewLayer)
            previewLayer.frame = view.frame
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(dataOutput)
            
            
    //        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
            
            setupIdentifierConfidenceLabel()
        }
        
        fileprivate func setupIdentifierConfidenceLabel() {
            view.addSubview(identifierLabel)
            identifierLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
            identifierLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            identifierLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            identifierLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        @available(iOS 12.0, *)
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    //        print("Camera was able to capture a frame:", Date())
            
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
            let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
                
    //            print(finishedReq.results)
                
                guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                
                guard let firstObservation = results.first else { return }
                
                print(firstObservation.identifier, firstObservation.confidence)
                
                DispatchQueue.main.async {
                    self.identifierLabel.text = "\(firstObservation.identifier) \(firstObservation.confidence * 100)"
                }
                
            }
            
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }
 
 */

 



