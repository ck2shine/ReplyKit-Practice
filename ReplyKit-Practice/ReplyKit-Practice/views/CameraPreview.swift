//
//  CameraPreview.swift
//  ReplyKit-Practice
//
//  Created by i9400503 on 2019/9/30.
//  Copyright © 2019 BrilleShine. All rights reserved.
//

import UIKit
import AVFoundation
class CameraPrewview : UIView
{

    var filmPreviewLayer : AVCaptureVideoPreviewLayer{
        guard let layer = layer as? AVCaptureVideoPreviewLayer else
        {
            fatalError("getPreviewLayer Error")
        }
        return layer
    }

    var session : AVCaptureSession?
    {
        get {
            return filmPreviewLayer.session
        }

        set {
            filmPreviewLayer.session = newValue
        }
    }

    override class var layerClass: AnyClass
    {
        return AVCaptureVideoPreviewLayer.self
    }
}
