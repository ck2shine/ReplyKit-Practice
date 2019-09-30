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

    private let session = AVCaptureSession()

    private let writter = VideoAssertWrtitter()
    let recorder = RPScreenRecorder.shared()

    let videoQuere = DispatchQueue(label: "videoQuere")
    private var isVideoSessionRunning = false
    private var isAuthForVideo = true

    private var isRecording = false

    dynamic var videoDeviceInput : AVCaptureDeviceInput!

    @IBOutlet weak var RecordButtonStatue: UIButton!
    
    @IBOutlet weak var RecordInfoView: UIStackView!
    @IBOutlet weak var RecordStarting: UIView!

    @IBOutlet weak var RecordTimer: UILabel!

    @IBOutlet weak var cameraPreview: CameraPrewview!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initView()

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break
        case .notDetermined:
            videoQuere.suspend()
            AVCaptureDevice.requestAccess(for: .video) { (authDone) in
                if !authDone
                {
                    self.isAuthForVideo = false
                }
                self.videoQuere.resume()
            }
        default:
            self.isAuthForVideo = false
        }

        videoQuere.async {
            self.configurationVideoSession()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        videoQuere.async {
            self.isVideoSessionRunning = true
            self.session.startRunning()
        }

        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoQuere.async {
            if self.isVideoSessionRunning
            {
                self.session.stopRunning()
            }

        }
        super.viewWillDisappear(animated)

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
        guard recorder.isAvailable else {
            
            alertErrorMessage("Device doesn`t support Record function !")
            
            return
        }
        
        
        
        recorder.isMicrophoneEnabled = true

        //writeToAlbum
        let bounds = self.cameraPreview.bounds



        //available in ios11
        recorder.startCapture(handler: { [unowned self](bufer, rssmapleBuffer, error) in

            self.writter.writeToAssert(buffer: bufer, bufferKind: rssmapleBuffer, fileFrame: bounds)


        }) { (error) in

            guard  error == nil else
            {
                DispatchQueue.main.async {
                    self.alertErrorMessage("records with something error : \(error?.localizedDescription ?? "")")
                }
                return
            }

            self.isRecording = true
        }

        /*
         recorder.startRecording { [unowned self](error) in

         guard error == nil else
         {
         self.alertErrorMessage("records with something error : \(error?.localizedDescription ?? "")")
         return
         }

         self.isRecording = true
         self.showInfoView(self.isRecording)
         }*/
    }
    private func stopRecord(){
        recorder.stopCapture { [unowned self](error) in
            guard error == nil else
            {
                DispatchQueue.main.async {
                    self.alertErrorMessage(error?.localizedDescription ?? "error with stop Capture")
                }
                return
            }
            self.writter.finish()
            self.isRecording = false
        }
        /*
         //this is only for ios10
         recorder.stopRecording { [unowned self](preview, error) in
         self.isRecording = false
         self.showInfoView(self.isRecording)
         guard let preview = preview else
         {
         print("there is not any preview")
         return
         }
         preview.previewControllerDelegate = self
         self.present(preview, animated: true)


         self.writter.finish()
         }*/
    }


}

extension BrRecorderViewController{
    private func initView(){
        self.RecordButtonStatue.layer.cornerRadius = self.RecordButtonStatue.bounds.width / 2
        self.cameraPreview.session = session
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

extension BrRecorderViewController {
    private func configurationVideoSession()
    {
        guard isAuthForVideo else {
            return
        }

        //set up set session input mode
        session.beginConfiguration()

        session.sessionPreset = .photo


        do
        {
            let defaultViedoDevice = AVCaptureDevice.default( .builtInWideAngleCamera ,for: .video , position:  . front)

            guard let viedoDevice = defaultViedoDevice else
            {
                session.commitConfiguration()
                return
            }

            let videoDeviceInput = try AVCaptureDeviceInput(device: viedoDevice)

            if session.canAddInput(videoDeviceInput)
            {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput


                DispatchQueue.main.async {
                    let defaultOritation: AVCaptureVideoOrientation = .portrait
                    self.cameraPreview.filmPreviewLayer.connection?.videoOrientation = defaultOritation
                }


            }
        }
        catch
        {
            print("configuration viedo Session with something error")
            session.commitConfiguration()
        }

        session.commitConfiguration()
    }
}

extension BrRecorderViewController : RPPreviewViewControllerDelegate
{
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
        
    }
}
