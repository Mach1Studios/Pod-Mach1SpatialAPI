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

var m1Decode = Mach1Decode()
var stereoPlayer = AVAudioPlayer()

var stereoActive = false
var isYawActive = true
var isPitchActive = false
var isRollActive = false
var isPlaying = false
var deviceYaw = 0.0
var devicePitch = 0.0
var deviceRoll = 0.0

private var audioEngine: AVAudioEngine = AVAudioEngine()
private var mixer: AVAudioMixerNode = AVAudioMixerNode()
var players: [AVAudioPlayer] = []

@available(iOS 14.0, *)
class ViewController: UIViewController, CMHeadphoneMotionManagerDelegate {
    
    @IBOutlet weak var UseHeadphoneOrientationDataSwitch: UISwitch!
    @IBOutlet weak var yaw: UILabel!
    @IBOutlet weak var pitch: UILabel!
    @IBOutlet weak var roll: UILabel!
    @IBAction func playButton(_ sender: Any) {
        if !isPlaying {
            var startDelayTime = 1.0
            var now = players[0].deviceCurrentTime
            var startTime = now + startDelayTime
            print (startTime)
            for audioPlayer in players {
                audioPlayer.play(atTime: startTime)
            }
            //stereoPlayer.play()
            print("isPlaying")
            isPlaying = true
        }
    }
    @IBAction func stopButton(_ sender: Any) {
        for audioPlayer in players {
            audioPlayer.stop()
        }
        isPlaying = false
        //stereoPlayer.stop()
        // prep files for next play
        for i in 0...7 {
            players[i * 2].prepareToPlay()
            players[i * 2 + 1].prepareToPlay()
        }
        //stereoPlayer.prepareToPlay()
    }
    @IBAction func staticStereoActive(_ sender: Any) {
        stereoActive = !stereoActive
    }
    @IBAction func headphoneIMUActive(_ sender: Any) {
        bUseHeadphoneOrientationData = UseHeadphoneOrientationDataSwitch.isOn
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
        
        do {
            for i in 0...7 {
                //load in the individual streams of audio from a Mach1 Spatial encoded audio file
                //this example assumes you have decoded the multichannel (8channel) audio file into individual streams
                players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "00" + String(i), ofType: "aif")!)))
                players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "00" + String(i), ofType: "aif")!)))
                
                players[i * 2].numberOfLoops = 10
                players[i * 2 + 1].numberOfLoops = 10
                
                //the Mach1Decode function 8*2 channels to correctly recreate the stereo image
                players[i * 2].pan = -1.0;
                players[i * 2 + 1].pan = 1.0;
                
                players[i * 2].prepareToPlay()
                players[i * 2 + 1].prepareToPlay()
            }
            
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
        
        //Static Stereo
        do{
            stereoPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "stereo", ofType: "wav")!))
        } catch {
            print(error)
        }
        stereoPlayer.prepareToPlay()
        print(stereoPlayer)
        
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
            motionManager.deviceMotionUpdateInterval = 0.01;
            let queue = OperationQueue()
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
                    if (!headphoneMotionManager.isDeviceMotionActive) { // If CoreMotionHeadphone device not found, revert back to native device IMU
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
                
                // Please notice that you're expected to correct the correct the angles you get from
                // the device's sensors to provide M1 Library with accurate angles in accordance to documentation.
                // https://dev.mach1.tech/#mach1-internal-angle-standard
                
                // This example does not have motion management logic in place, it is expected
                // that the app will be launched on a tabletop and will assume 0 values for
                // yaw, pitch, roll upon launch. Rotating the device in portrait mode on table
                // is the expected usage.                switch UIDevice.current.orientation{
                
                //Mute stereo if off
                if (stereoActive) {
                    stereoPlayer.setVolume(1.0, fadeDuration: 0.1)
                } else if (!stereoActive) {
                    stereoPlayer.setVolume(0.0, fadeDuration: 0.1)
                }
                
                //Send device orientation to m1obj with the preferred algo
                m1Decode.beginBuffer()
                let decodeArray: [Float]  = m1Decode.decode(Yaw: Float(deviceYaw), Pitch: Float(devicePitch), Roll: Float(deviceRoll))
                m1Decode.endBuffer()
                
                //Use each coeff to decode multichannel Mach1 Spatial mix
                for i in 0...7 {
                    players[i * 2].setVolume(Float(decodeArray[i * 2]), fadeDuration: 0)
                    players[i * 2 + 1].setVolume(Float(decodeArray[i * 2 + 1]), fadeDuration: 0)
                    //print(String(players[i * 2].currentTime) + " ; " + String(i * 2))
                    //print(String(players[i * 2 + 1].currentTime) + " ; " + String(i * 2 + 1))
                }
                
                DispatchQueue.main.async() {
                    // Return and display current corrected angle from Platform & filterspeed processing
                    self?.yaw.text = String(m1Decode.getCurrentAngle().x)
                    self?.pitch.text = String(m1Decode.getCurrentAngle().y)
                    self?.roll.text = String(m1Decode.getCurrentAngle().z)
                }
            })
            print("Device motion started")
        } else {
            print("Device motion unavailable");
        }
    }
}

