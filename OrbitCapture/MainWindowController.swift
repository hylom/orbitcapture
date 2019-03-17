//
//  MainWindowController.swift
//  OrbitCapture
//
//  Created by Hiromichi Matsushima on 2019/03/04.
//  Copyright © 2019年 Hiromichi Matsushima. All rights reserved.
//

import Cocoa
import AVKit
import AppKit

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    override var windowNibName: NSNib.Name? {
        return NSNib.Name("MainWindow")
    }
    @IBOutlet weak var captureView: AVCaptureView!
    @IBOutlet weak var connectButton: NSButton!
    @IBOutlet weak var gainSlider: NSSlider!
    @IBOutlet weak var whiteBalanceSlider: NSSlider!
    @IBOutlet weak var exposureSlider: NSSlider!
    @IBOutlet weak var panTiltRange: NSSlider!
    
    var cameraControl: UVCCameraControl!
    @objc dynamic var connected = false
    
    override func awakeFromNib() {
        connected = false
        captureView.delegate = self
    }
    
    @IBAction func onResetPanTiltButton(_ sender: NSButton) {
        cameraControl.resetTiltPan(true)
        print("reset pan and tilt")
    }
    
    @IBAction func onClickPanIncButton(_ sender: NSButton) {
        if cameraControl != nil {
            cameraControl.setPanTiltRelative(false, withPan: panTiltRange.intValue, withTilt: 0)
        }
    }
    
    @IBAction func onClickPanDecButton(_ sender: NSButton) {
        if cameraControl != nil {
            cameraControl.setPanTiltRelative(false, withPan: -panTiltRange.intValue, withTilt: 0)
        }
    }
    
    @IBAction func onClickTiltIncButton(_ sender: NSButton) {
        if cameraControl != nil {
            cameraControl.setPanTiltRelative(false, withPan: 0, withTilt: panTiltRange.intValue)
        }
    }
    
    @IBAction func onClickTiltDecButton(_ sender: NSButton) {
        if cameraControl != nil {
            cameraControl.setPanTiltRelative(false, withPan: 0, withTilt: -panTiltRange.intValue)
        }
    }
    
    @IBAction func onClickConnectButton(_ sender: NSButton) {
        if let session = captureView.session {
            let inputs = session.inputs
            for input in inputs {
                if let inputDevice = input as? AVCaptureDeviceInput {
                    let captureDevice = inputDevice.device
                    print("modelID: \(captureDevice.modelID)")
                    print("localizedName: \(captureDevice.localizedName)")
                    print("uniqueID: \(captureDevice.uniqueID)")
                    print("manufacturer: \(captureDevice.manufacturer)")
                    /*
                     modelID: UVC Camera VendorID_1133 ProductID_2452
                     localizedName: USBカメラ
                     uniqueID: 0x14340000046d0994
                     uniqueID: 0x14_34_00_00_04_6d_09_94
                     */
                    // get vendor ID and product ID
                    let rex = try? NSRegularExpression(pattern: "UVC Camera VendorID_(\\d+) ProductID_(\\d+)")
                    let m = rex!.matches(in: captureDevice.modelID, range:NSRange(location: 0, length:captureDevice.modelID.count))
                    if (m.count > 0) {
                        let s = NSString(string: captureDevice.modelID)
                        let venderId = s.substring(with: m[0].range(at: 1))
                        let productId = s.substring(with: m[0].range(at: 2))

                        //if captureDevice.modelID == "UVC Camera VendorID_1133 ProductID_2452" {
                        if venderId == "1133" {
                            
                            cameraControl = UVCCameraControl.init(vendorID: Int(venderId)!, productID: Int(productId)!)
                            if cameraControl != nil {
                                cameraControl.setAutoExposure(true)
                                cameraControl.setAutoWhiteBalance(true)
                                cameraControl.resetTiltPan(true)
                                cameraControl.setGain(gainSlider.floatValue)
                                
                                
                                if session.canSetSessionPreset(AVCaptureSession.Preset.iFrame1280x720) {
                                    session.sessionPreset = AVCaptureSession.Preset.iFrame1280x720
                                }
                                else if session.canSetSessionPreset(AVCaptureSession.Preset.hd1280x720) {
                                    session.sessionPreset = AVCaptureSession.Preset.hd1280x720
                                }
                                else if session.canSetSessionPreset(AVCaptureSession.Preset.high) {
                                    session.sessionPreset = AVCaptureSession.Preset.high
                                }
                                
                                connected = true
                                print("init cameraControl done")
                                print("use preset \(session.sessionPreset)")
                            }
                        }
                    }
                }
            }
        }
        if connected {
            connectButton.isEnabled = false
        } else {
            let alert = NSAlert()
            alert.messageText = "Cannot connect to camera."
            alert.runModal()
        }
    }
    
    @IBAction func onUpdateGain(_ sender: NSSlider) {
        if cameraControl != nil {
            cameraControl.setGain(gainSlider.floatValue)
        }
    }
    
    @IBAction func onUpdateWhiteBalance(_ sender: NSSlider) {
        if cameraControl != nil {
            // convert log scale
            cameraControl.setWhiteBalance(whiteBalanceSlider.floatValue)
        }
    }
    
    @IBAction func onUpdateExposureTime(_ sender: NSSlider) {
        if cameraControl != nil {
            let logValue = log10(exposureSlider.floatValue * 9.0 + 1.0)
            cameraControl.setExposure(logValue)
        }
    }
    
    @IBAction func onUpdateUseAutoWhiteBalance(_ sender: NSButton) {
        if cameraControl != nil {
            if (sender.state == NSControl.StateValue.on) {
                cameraControl.setAutoWhiteBalance(true)
            } else {
                cameraControl.setAutoWhiteBalance(false)
                cameraControl.setWhiteBalance(whiteBalanceSlider.floatValue)
            }
        }
    }
    
    @IBAction func onUpdateUseAutoExposureTime(_ sender: NSButton) {
        if cameraControl != nil {
            if (sender.state == NSControl.StateValue.on) {
                cameraControl.setAutoExposure(true)
            } else {
                cameraControl.setAutoExposure(false)
                let logValue = log10(exposureSlider.floatValue * 9.0 + 1.0)
                cameraControl.setExposure(logValue)
                cameraControl.setGain(gainSlider.floatValue)
            }
        }
    }

}

extension MainWindowController: AVCaptureViewDelegate {
    func captureView(_ captureView: AVCaptureView,
                     startRecordingTo fileOutput: AVCaptureFileOutput) {
        let basedir = NSString(string: "~/Desktop").expandingTildeInPath
        var url = URL(fileURLWithPath: basedir)
        let movieName = "capture-\(Date()).mov"
        url.appendPathComponent(movieName, isDirectory: false)
        
        print("write movie to \(url)")
        fileOutput.startRecording(to: url,
                                  recordingDelegate: self)
    }
    
}

extension MainWindowController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!,
                 didFinishRecordingToOutputFileAt outputFileURL: URL!,
                 fromConnections connections: [Any]!, error: Error!) {
    }
}
