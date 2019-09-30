//
//  BrRecorderViewController.swift
//  ReplyKit-Practice
//
//  Created by i9400503 on 2019/9/30.
//  Copyright © 2019 BrilleShine. All rights reserved.
//

import UIKit
import ReplayKit
class BrRecorderViewController: UIViewController {

    private let writter = VideoAssertWrtitter()

    let videoQuere = DispatchQueue(label: "videoQuere")
    private var isVideoSessionRunning = false
    private var isAuthForVideo = true

    private var recorder = RPScreenRecorder.shared()

    private var isRecording = false

    dynamic var videoDeviceInput : AVCaptureDeviceInput!

    @IBOutlet weak var RecordButtonStatue: UIButton!
    
    @IBOutlet weak var RecordInfoView: UIStackView!
    @IBOutlet weak var RecordStarting: UIView!

    @IBOutlet weak var RecordTimer: UILabel!

    @IBOutlet weak var cameraPreview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()

    }



    @IBAction func RecordButton(_ sender: UIButton) {

        UIView.animate(withDuration: 0.5) {
            if !self.isRecording
            {
                self.RecordButtonStatue.layer.cornerRadius = 0.0
            }
            else
            {
                self.RecordButtonStatue.layer.cornerRadius = self.RecordButtonStatue.bounds.width / 2
            }
        }
        if !self.isRecording
        {
            self.startRecord()
        }
        else
        {
            self.stopRecord()
        }

    }
    
    
}

//MARK: Record funciton
extension BrRecorderViewController{
    private func startRecord(){
        //        guard RPScreenRecorder.shared().isAvailable else {
        //
        //            alertErrorMessage("Device doesn`t support Record function !")
        //
        //            return
        //        }
        //
        //        self.recorder.isMicrophoneEnabled = true
        //        self.recorder.isCameraEnabled = true
        //        self.recorder.cameraPosition = .front
        //
        //        let bounds = self.cameraPreview.bounds
        //
        //        //available in ios11
        //        RPScreenRecorder.shared().startCapture(handler: { [unowned self](bufer, rssmapleBuffer, error) in
        //
        //            self.writter.writeToAssert(buffer: bufer, bufferKind: rssmapleBuffer, fileFrame: bounds)
        //
        //        }) { (error) in
        //
        //            guard  error == nil else
        //            {
        //                DispatchQueue.main.async {
        //                    self.alertErrorMessage("records with something error : \(error?.localizedDescription ?? "")")
        //                }
        //                return
        //            }
        //            DispatchQueue.main.async {
        //
        //                self.recorder.cameraPreviewView?.frame.size = self.cameraPreview.bounds.size
        //                self.recorder.cameraPreviewView?.frame.origin = CGPoint(x: 0, y: 0)
        //
        //                self.cameraPreview.addSubview(   self.recorder.cameraPreviewView!)
        //                self.isRecording = true
        //                self.showInfoView(self.isRecording)
        //            }
        //        }


        self.recorder.isMicrophoneEnabled = true
        self.recorder.isCameraEnabled = true
        self.recorder.cameraPosition = .front
        recorder.startRecording { [unowned self](error) in



            guard error == nil else
            {
                self.alertErrorMessage("records with something error : \(error?.localizedDescription ?? "")")
                return
            }
            DispatchQueue.main.async {

                self.recorder.cameraPreviewView?.frame.size = self.cameraPreview.bounds.size
                self.recorder.cameraPreviewView?.frame.origin = CGPoint(x: 0, y: 0)

                self.cameraPreview.addSubview(   self.recorder.cameraPreviewView!)
                self.isRecording = true
                self.showInfoView(self.isRecording)
            }

        }
    }
    private func stopRecord(){
        //        self.recorder.stopCapture { [unowned self](error) in
        //            guard error == nil else
        //            {
        //                DispatchQueue.main.async {
        //                    self.alertErrorMessage(error?.localizedDescription ?? "error with stop Capture")
        //                }
        //                return
        //            }
        //            self.writter.finish()
        //            self.isRecording = false
        //        }

        self.recorder.stopRecording { (preview, error) in
            guard error == nil else
            {
                DispatchQueue.main.async {
                    self.alertErrorMessage(error?.localizedDescription ?? "error with stop Capture")
                }
                return
            }
            self.isRecording = false
            DispatchQueue.main.async {
                self.recorder.cameraPreviewView?.removeFromSuperview()
                preview?.previewControllerDelegate = self
                self.present(preview!, animated: true)
            }
        }
    }
}

extension BrRecorderViewController{
    private func initView(){
        self.RecordButtonStatue.layer.cornerRadius = self.RecordButtonStatue.bounds.width / 2

    }
    
    private func alertErrorMessage(_ errMsg : String){
        let alert = UIAlertController(title: "Error", message: errMsg, preferredStyle: .alert)
        let confirm  =   UIAlertAction(title: "Error", style: .cancel )
        alert.addAction(confirm)
        self.present(alert, animated: true)
    }

    private func showInfoView(_ show : Bool){
        RecordInfoView.isHidden = !show
        if show
        {

            UIView.animate(withDuration: 0.5,delay: 0.0, options: [.repeat , .autoreverse], animations: {
                self.RecordStarting.alpha = 0.0
            }) { (success) in

            }
        }
        else
        {

        }

    }
}


extension BrRecorderViewController : RPPreviewViewControllerDelegate
{
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
        
    }
}
