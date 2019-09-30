//
//  videoAssertWrtitter.swift
//  ReplyKit-Practice
//
//  Created by i9400503 on 2019/9/30.
//  Copyright © 2019 BrilleShine. All rights reserved.
//

import Foundation
import ReplayKit

class VideoAssertWrtitter{

    private var writter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?

    var savePath : String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

        return "\(documentPath)/Films"
    }

    var filePath : String{
        return  "\(savePath)/saveVideo.mp4"
    }

    let processQuere = DispatchQueue(label: "processQuere")

    func writeToAssert(buffer : CMSampleBuffer , bufferKind : RPSampleBufferType , fileFrame : CGRect){
        processQuere.sync {[weak self] in
            guard let self = self else {return}
            if self.writter == nil
            {
                self.configurationWritterAssert(buffer: buffer, fileFrame: fileFrame)
            }

            if self.writter?.status == .unknown {

                self.writter?.startWriting()
                self.writter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(buffer))
            }

            if CMSampleBufferDataIsReady(buffer) {
                if bufferKind == .video {
                    if let videoInput = self.videoInput, videoInput.isReadyForMoreMediaData {
                        videoInput.append(buffer)
                    }
                } else if bufferKind == .audioMic {
                    if let audioInput = self.audioInput, audioInput.isReadyForMoreMediaData {
                        audioInput.append(buffer)
                    }
                }
            }
        }
    }
}

extension VideoAssertWrtitter{
    func configurationWritterAssert(buffer : CMSampleBuffer, fileFrame : CGRect)
    {
        if FileManager.default.fileExists(atPath: self.savePath)
        {
            do {
                try FileManager.default.removeItem(atPath: self.savePath)
            }
            catch
            {
                print("fail to remove file")
            }
        }



        do{
            try FileManager.default.createDirectory(atPath: self.savePath, withIntermediateDirectories: true, attributes: nil)
        }
        catch
        {
            print("fail to create video Save documentPath")
        }

        self.writter = try?  AVAssetWriter(outputURL: URL(fileURLWithPath: self.filePath), fileType: .mov)
        let writeSetting : [String : Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoWidthKey : fileFrame.width ,
            AVVideoHeightKey : fileFrame.height
        ]

        self.videoInput =  AVAssetWriterInput(mediaType:.video , outputSettings: writeSetting)
        self.videoInput?.expectsMediaDataInRealTime = true

        guard let videoFormat = CMSampleBufferGetFormatDescription(buffer) ,
            let videoStream = CMAudioFormatDescriptionGetStreamBasicDescription(videoFormat) else
        {
            print("setup audioInput format failed")
            return
        }

        let audioSetting : [String : Any] = [
            AVFormatIDKey : kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey : videoStream.pointee.mChannelsPerFrame,
            AVSampleRateKey : videoStream.pointee.mSampleRate,
            AVEncoderBitRateKey : 64000
        ]

        self.audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSetting)
        self.audioInput?.expectsMediaDataInRealTime = true

        if let videoInput = self.videoInput , self.writter?.canAdd(videoInput)  ?? false
        {
            self.writter?.add(videoInput)
        }

        if let audioInpit = self.audioInput , self.writter?.canAdd(audioInpit) ?? false
        {
            self.writter?.add(audioInpit)
        }
        

    }

    func finish(){
        processQuere.sync {
            self.writter?.finishWriting {
                UISaveVideoAtPathToSavedPhotosAlbum(self.filePath, nil, nil, nil)
            }
        }
    }
}
