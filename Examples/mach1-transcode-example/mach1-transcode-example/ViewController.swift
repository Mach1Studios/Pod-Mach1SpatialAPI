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

private var motionManager = CMMotionManager()
private var m1Decode = Mach1Decode()
private var m1Transcode = Mach1Transcode()

private var isYawActive = true
private var isPitchActive = false
private var isRollActive = false
private var isPlaying = false

private var audioEngine: AVAudioEngine = AVAudioEngine()
private var mixer: AVAudioMixerNode = AVAudioMixerNode()
private var players: [AVAudioPlayer] = []
private var matrix: [[Float]] = []

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    @IBAction func playButton(_ sender: Any) {
        if !isPlaying {
            let selectedAudio = picker.selectedRow(inComponent: 0)
            print("selectedAudio:", selectedAudio)
            
            do {
                players = []
                
                var idx = 0
                for i in 0..<pickerData[selectedAudio].files.count {
                    //load in the individual streams of audio from a Mach1 Spatial encoded audio file
                    //this example assumes you have decoded the multichannel (8channel) audio file into individual streams
                    players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: pickerData[selectedAudio].files[i], ofType: "wav")!)))
                    players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: pickerData[selectedAudio].files[i], ofType: "wav")!)))
                    
                    players[idx].numberOfLoops = 10
                    players[idx].pan = 1.0;
                    players[idx].volume = 0.0;
                    players[idx].prepareToPlay()
                    idx = idx + 1
                    
                    players[idx].numberOfLoops = 10
                    players[idx].pan = -1.0;
                    players[idx].volume = 0.0;
                    players[idx].prepareToPlay()
                    idx = idx + 1
                }

                //Mach1 Transcode Setup
                m1Transcode.setInputFormat(inFmt: pickerData[selectedAudio].format)
                m1Transcode.setOutputFormat(outFmt: Mach1TranscodeFormatM1Spatial)
                m1Transcode.processConversionPath()
                matrix = m1Transcode.getMatrixConversion()
                
                m1Decode.beginBuffer()
                m1Decode.setRotationDegrees(newRotationDegrees: Mach1Point3D(x: 0, y: 0, z: 0))
                let result: [Float] = m1Decode.decodeCoeffsUsingTranscodeMatrix(matrix: matrix, channels: m1Transcode.getInputNumChannels())
                m1Decode.endBuffer()
                
                //print(decodeArray)
                
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
    
    @IBAction func stopButton(_ sender: Any) {
        isPlaying = false

        for audioPlayer in players {
            audioPlayer.stop()
        }
        players = []
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
            m1Decode.setFilterSpeed(filterSpeed: 1.0)
            
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
        
        // Ensure to keep a strong reference to the motion manager otherwise you won't get updates
        if motionManager.isDeviceMotionAvailable == true {
            motionManager.deviceMotionUpdateInterval = 0.01;
            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] (motion, error) -> Void in
                
                // Get the attitudes of the device
                let attitude = motion?.attitude
                //Device orientation management
                var deviceYaw = attitude!.yaw * 180/Double.pi
                var devicePitch = attitude!.pitch * 180/Double.pi
                //                    let devicePitch = 0.0
                var deviceRoll = attitude!.roll * 180/Double.pi
                //                    let deviceRoll = 0.0
                //                    print("Yaw: ", deviceYaw)
                //                    print("Pitch: ", devicePitch)
                
                // Please notice that you're expected to correct the correct the angles you get from
                // the device's sensors to provide M1 Library with accurate angles in accordance to documentation.
                // (documentation URL here)
                switch UIDevice.current.orientation{
                case .portrait:
                    deviceYaw += 90
                    devicePitch -= 90
                case .portraitUpsideDown:
                    deviceYaw -= 90
                    devicePitch += 90
                case .landscapeLeft:
                    deviceRoll += 90
                case .landscapeRight:
                    deviceYaw += 180
                    deviceRoll -= 90
                default:
                    break
                }
                
                DispatchQueue.main.async() {
                    self?.yaw.text = String(deviceYaw)
                    self?.pitch.text = String(devicePitch)
                    self?.roll.text = String(deviceRoll)
                }
                
                if isPlaying {
                    //Send device orientation to m1obj with the preferred algo
                    m1Decode.beginBuffer()
                    m1Decode.setRotationDegrees(newRotationDegrees: Mach1Point3D(x: Float(deviceYaw), y: Float(devicePitch), z: Float(deviceRoll)))
                    let result: [Float] = m1Decode.decodeCoeffsUsingTranscodeMatrix(matrix: matrix, channels: m1Transcode.getInputNumChannels())
                    m1Decode.endBuffer()
                    
                    //print(decodeArray)
                    
                    //Use each coeff to decode multichannel Mach1 Spatial mix
                    for i in 0..<result.count {
                        players[i].setVolume(result[i], fadeDuration: 0)
                        //print(String(players[i].currentTime) + " ; " + String(i))
                    }
                }
                
            })
            print("Device motion started")
        } else {
            print("Device motion unavailable");
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
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].name
    }
}


