//
//  ViewController.swift
//

import UIKit
import Mach1SpatialAPI
import CoreMotion
import SceneKit

class ViewController: UIViewController {
    
    var encoder: Encoder! = Encoder()
    var motionManager = CMMotionManager()
    @IBOutlet weak var yawMeter: YawMeter!
    @IBOutlet weak var rollMeter: RollMeter!
    @IBOutlet weak var pitchMeter: PitchMeter!
    
    @IBAction func PlayButtonPressed(_ sender: Any) {
        print("Play pressed")
        
        encoder.activateAudioSession()
        encoder.playSpatialAudioCue(audioCue: "Take a right turn on Vestry Street")
    }
    
    var m1Decode : Mach1Decode!
    var encoderCurrent: Encoder?
    var cameraYaw : Float = 0.0
    var cameraPitch : Float = 0.0
    var cameraRoll : Float = 0.0
    
    @objc func update() {
        m1Decode.beginBuffer()
        let decodeArray: [Float]  = m1Decode.decode(Yaw: Float(cameraYaw), Pitch: Float(cameraPitch), Roll: Float(cameraRoll))
        m1Decode.endBuffer()
        
        encoder.update(decodeArray: decodeArray, decodeType: Mach1DecodeAlgoSpatial)
        
//        soundMap?.update(decodeArray: decodeArray, decodeType: Mach1DecodeAlgoSpatial, rotationAngleForDisplay: -cameraPitch * Float.pi/180)
    }
    
    func getEuler(q1 : SCNVector4) -> float3
    {
        var res = float3(0,0,0)
        
        let test = q1.x * q1.y + q1.z * q1.w
        if (test > 0.499) // singularity at north pole
        {
            return float3(
                0,
                Float(2 * atan2(q1.x, q1.w)),
                .pi / 2
                ) * 180 / .pi
        }
        if (test < -0.499) // singularity at south pole
        {
            return float3(
                0,
                Float(-2 * atan2(q1.x, q1.w)),
                -.pi / 2
                ) * 180 / .pi
        }
        
        let sqx = q1.x * q1.x
        let sqy = q1.y * q1.y
        let sqz = q1.z * q1.z
        
        res.x = Float(atan2(2 * q1.x * q1.w - 2 * q1.y * q1.z, 1 - 2 * sqx - 2 * sqz))
        res.y = Float(atan2(2 * q1.y * q1.w - 2 * q1.x * q1.z, 1 - 2 * sqy - 2 * sqz))
        res.z = Float(sin(2.0 * test))
        
        return res * 180 / .pi
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        encoder.setupAudio()
        
        m1Decode = Mach1Decode()
        //Mach1 Decode Setup
        //Setup the correct angle convention for orientation Euler input angles
        m1Decode.setPlatformType(type: Mach1PlatformiOS)
        //Setup the expected spatial audio mix format for decoding
        m1Decode.setDecodeAlgoType(newAlgorithmType: Mach1DecodeAlgoSpatial)
        //Setup for the safety filter speed:
        //1.0 = no filter | 0.1 = slow filter
        m1Decode.setFilterSpeed(filterSpeed: 1.0)
       
        // timer for draw update
        Timer.scheduledTimer(timeInterval: 1.0 / 60.0, target: self, selector: (#selector(ViewController.update)), userInfo: nil, repeats: true)
        
        if motionManager.isDeviceMotionAvailable == true {
            motionManager.deviceMotionUpdateInterval = 0.01;
            let queue = OperationQueue()
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] (motion, error) -> Void in
                
                // Get the attitudes of the device
                let quat = motion?.gaze(atOrientation: UIApplication.shared.statusBarOrientation)
                var angles = self!.getEuler(q1: quat!)
                
                self?.cameraYaw = angles.x
                self?.cameraPitch = angles.y
                self?.cameraRoll = angles.z
                
                DispatchQueue.main.async {
                    self?.yawMeter?.update(meter: -angles.y / 180)
                    self?.rollMeter?.update(meter: -angles.z / 90)
                    self?.pitchMeter?.update(meter: -angles.x / 90)
                    /*
                    self?.labelInfo?.text = "Yaw: " + String(format: "%.3f", angles.x) + "°" + "\r\n" +
                        "Pitch: " + String(format: "%.3f", angles.y) + "°" + "\r\n" +
                        "Roll: " + String(format: "%.3f", angles.z) + "°"
                    */
                }

            })
            print("Device motion started")
        } else {
            print("Device motion unavailable");
        }
    }

}

