//
//  ViewController.swift
//  mach1-ios-example
//
//  Created by Dylan Marcus on 2/19/18.
//  Copyright © 2018 Mach1. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
import Mach1SpatialAPI

/// As of 11/11/2021 the recommended minimum iOS target is 14.0 to make the examples
/// compatible with Headphone Motion Manager API from Apple.
/// if you require targetting an older version of iOS SDK, please remove all logic using
/// `CMHeadphoneMotionManager`or roll back to an older example version.
private var motionManager = CMMotionManager()
@available(iOS 14.0, *)
private var headphoneMotionManager = CMHeadphoneMotionManager()
private var bUseHeadphoneOrientationData = false
var currentSelection: Int = 0

private var m1Decode = Mach1Decode()
private var m1Transcode = Mach1Transcode()

private var isYawActive = true
private var isPitchActive = false
private var isRollActive = false
private var isPlaying = false
var deviceYaw = 0.0
var devicePitch = 0.0
var deviceRoll = 0.0

private var audioEngine: AVAudioEngine = AVAudioEngine()
private var mixer: AVAudioMixerNode = AVAudioMixerNode()
private var players: [AVAudioPlayer] = []
private var matrix: [[Float]] = []

@available(iOS 14.0, *)
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CMHeadphoneMotionManagerDelegate {
    
    @IBOutlet weak var UseHeadphoneOrientationDataSwitch: UISwitch!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var yaw: UILabel!
    @IBOutlet weak var pitch: UILabel!
    @IBOutlet weak var roll: UILabel!
    
    struct AudioInput {
        var name: String
        var format: Mach1TranscodeFormatType
        var files: [String]
    }
    
    var pickerData: [AudioInput] = [
        AudioInput(name: "ACNSN3D", format: Mach1TranscodeFormatACNSN3D, files: [
            "guitar-acnsn3d-1",
            "guitar-acnsn3d-2",
            "guitar-acnsn3d-3",
            "guitar-acnsn3d-4",
            ]),
        AudioInput(name: "FiveOneFilm_Cinema", format: Mach1TranscodeFormatFiveOneFilm_Cinema, files: [
            "guitar-51Film-1",
            "guitar-51Film-2",
            "guitar-51Film-3",
            "guitar-51Film-4",
            "guitar-51Film-5",
            "guitar-51Film-6",
            ]),
        ]
    
    func playAudio(){
        if !isPlaying {
            let currentSelection = picker.selectedRow(inComponent: 0)
            print("selectedAudio:", currentSelection)
            
            do {
                players = []
                
                var idx = 0
                for i in 0..<pickerData[currentSelection].files.count {
                    //load in the individual streams of audio from a Mach1 Spatial encoded audio file
                    //this example assumes you have decoded the multichannel (8channel) audio file into individual streams
                    players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: pickerData[currentSelection].files[i], ofType: "wav")!)))
                    players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: pickerData[currentSelection].files[i], ofType: "wav")!)))
                    
                    players[idx].numberOfLoops = -1
                    players[idx].pan = 1.0;
                    players[idx].volume = 0.0;
                    players[idx].prepareToPlay()
                    idx = idx + 1
                    
                    players[idx].numberOfLoops = -1
                    players[idx].pan = -1.0;
                    players[idx].volume = 0.0;
                    players[idx].prepareToPlay()
                    idx = idx + 1
                }

                //Mach1 Transcode Setup
                m1Transcode.setInputFormat(inFmt: pickerData[currentSelection].format)
                m1Transcode.setOutputFormat(outFmt: Mach1TranscodeFormatM1Spatial)
                m1Transcode.processConversionPath()
                matrix = m1Transcode.getMatrixConversion()
                
                m1Decode.beginBuffer()
                m1Decode.setRotationDegrees(newRotationDegrees: Mach1Point3D(x: 0, y: 0, z: 0))
                let result: [Float] = m1Decode.decodeCoeffsUsingTranscodeMatrix(matrix: matrix, channels: m1Transcode.getInputNumChannels())
                m1Decode.endBuffer()
                
                //Use each coeff to decode multichannel Mach1 Spatial mix
                for i in 0..<result.count {
                    players[i].setVolume(result[i], fadeDuration: 0)
                    //print(String(players[i].currentTime) + " ; " + String(i))
                }
            } catch {
                print (error)
            }
            
            let startDelayTime = 1.0
            let now = players[0].deviceCurrentTime
            let startTime = now + startDelayTime
            print (startTime)
            for audioPlayer in players {
                audioPlayer.play(atTime: startTime)
            }
            print("isPlaying")
            isPlaying = true
        }
    }
    
    func stopAudio(){
        isPlaying = false

        for audioPlayer in players {
            audioPlayer.stop()
        }
        players = []
    }
    
    @IBAction func headphoneIMUActive(_ sender: Any) {
        bUseHeadphoneOrientationData = UseHeadphoneOrientationDataSwitch.isOn
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        togglePlayButton()
    }
    
    func togglePlayButton() {
        if !isPlaying {
            playAudio()
        } else if isPlaying {
            stopAudio()
        }
        let playButtonStatus = isPlaying ? "Stop" : "Play"
        playButton.setTitle(playButtonStatus, for: [.normal])
    }

    @IBAction func yawActive(_ sender: Any) {
        isYawActive = !isYawActive
    }
    
    @IBAction func pitchActive(_ sender: Any) {
        isPitchActive = !isPitchActive
    }
    
    @IBAction func rollActive(_ sender: Any) {
        isRollActive = !isRollActive
    }
    
    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        print("connect")
        bUseHeadphoneOrientationData = true
        DispatchQueue.main.async() {
            self.UseHeadphoneOrientationDataSwitch.setOn(bUseHeadphoneOrientationData, animated: true)
        }
    }
    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        print("disconnect")
        bUseHeadphoneOrientationData = false
        DispatchQueue.main.async() {
            self.UseHeadphoneOrientationDataSwitch.setOn(bUseHeadphoneOrientationData, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect data:
        self.picker.delegate = self
        self.picker.dataSource = self
        
        do {
            //Mach1 Decode Setup
            //Setup the correct angle convention for orientation Euler input angles
            m1Decode.setPlatformType(type: Mach1PlatformiOS)
            //Setup the expected spatial audio mix format for decoding
            m1Decode.setDecodeAlgoType(newAlgorithmType: Mach1DecodeAlgoSpatial)
            //Setup for the safety filter speed:
            //1.0 = no filter | 0.1 = slow filter
            m1Decode.setFilterSpeed(filterSpeed: 0.95)
            
        } catch {
            print (error)
        }
        
        //TODO: split audio channels for independent coeffs from our lib
        //let channelCount = audioPlayer.numberOfChannels
        //print("Channel Count: ", channelCount)
        
        //Allow audio to play when app closes
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }
        
        /// This example declares 2 motion managers:
        /// `headphoneMotionManager` is for headphone IMU enalbed device
        /// `motionManager` is for the native device's IMU
        /// `bUseHeadphoneOrientationData` lazily swaps between both manager's orientation updates
        headphoneMotionManager.delegate = self
        if (headphoneMotionManager.isDeviceMotionAvailable == true) || (motionManager.isDeviceMotionAvailable == true) {
            let queue = OperationQueue()
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] (motion, error) -> Void in
                if (bUseHeadphoneOrientationData && headphoneMotionManager.isDeviceMotionAvailable){
                    headphoneMotionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] (headphonemotion, error) -> Void in
                        // Get the attitudes of the device
                        let hpattitude = headphonemotion?.attitude
                        //Device orientation management
                        deviceYaw = hpattitude!.yaw * 180 / .pi
                        devicePitch = hpattitude!.pitch * 180 / .pi
                        deviceRoll = hpattitude!.roll * 180 / .pi
                    })
                    if (!headphoneMotionManager.isDeviceMotionActive) {
                        bUseHeadphoneOrientationData = false
                    }
                } else {
                    // Get the attitudes of the device
                    let attitude = motion?.attitude
                    //Device orientation management
                    deviceYaw = attitude!.yaw * 180 / .pi
                    devicePitch = attitude!.pitch * 180 / .pi
                    deviceRoll = attitude!.roll * 180 / .pi
                    DispatchQueue.main.async() {
                        bUseHeadphoneOrientationData = false
                        self!.UseHeadphoneOrientationDataSwitch.setOn(bUseHeadphoneOrientationData, animated: true)
                    }
                }
                                                                    
                /// Warning:
                /// You're expected to correct and manage the orientation from devices in accordance with your UX
                /// to get accurate playback from Mach1Decode API
                /// https://dev.mach1.tech/#mach1-internal-angle-standard
                
                /// This example does not have motion management logic in place, it is expected
                /// that the app will be launched on a tabletop and will assume 0 values for
                /// yaw, pitch, roll upon launch. Rotating the device in portrait mode on table
                /// is the expected usage.
                
                if isPlaying {
                    //Send device orientation to m1obj with the preferred algo
                    m1Decode.beginBuffer()
                    m1Decode.setRotationDegrees(newRotationDegrees: Mach1Point3D(x: Float(-deviceYaw), y: Float(devicePitch), z: Float(deviceRoll)))
                    let result: [Float] = m1Decode.decodeCoeffsUsingTranscodeMatrix(matrix: matrix, channels: m1Transcode.getInputNumChannels())
                    m1Decode.endBuffer()
                                        
                    //Use each coeff to decode multichannel Mach1 Spatial mix
                    for i in 0..<result.count {
                        players[i].setVolume(result[i], fadeDuration: 0)
                        //print(String(players[i].currentTime) + " ; " + String(i))
                    }
                }
                
                DispatchQueue.main.async() {
                    // Return and display current corrected angle from Platform & filterspeed processing
                    self?.yaw.text = String(-deviceYaw) //TODO: Fix issue with `PlatformType` not taking precedence when using inline transcode decode function
                    self?.pitch.text = String(m1Decode.getCurrentAngle().y)
                    self?.roll.text = String(m1Decode.getCurrentAngle().z)
                }
            })
            print("Device motion started")
        } else {
            print("Device motion unavailable");
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .allButUpsideDown
        }
    }
            
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].name
    }
}
