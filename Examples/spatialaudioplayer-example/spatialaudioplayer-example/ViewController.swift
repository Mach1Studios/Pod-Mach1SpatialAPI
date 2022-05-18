//
//  ViewController.swift
//
//  Created by Dylan Marcus on 11/8/21.
//

import UIKit
import SwiftUI
import CoreMotion
import AVFoundation
import Mach1SpatialAPI
import PlayListPlayer

/// As of 11/11/2021 the recommended minimum iOS target is 14.0 to make the examples
/// compatible with Headphone Motion Manager API from Apple.
/// if you require targetting an older version of iOS SDK, please remove all logic using
/// `CMHeadphoneMotionManager`or roll back to an older example version.
private var motionManager = CMMotionManager()
@available(iOS 14.0, *)
private var headphoneMotionManager = CMHeadphoneMotionManager()
var currentSelection: Int = 0

private var m1Decode = Mach1Decode()

private var isYawActive = true
private var isPitchActive = false
private var isRollActive = false
private var isPlaying = false
private var sliderCurrentlyTouched = false
var playbackCurrentTimeFromBackground = 0.0

var deviceYaw = 0.0
var devicePitch = 0.0
var deviceRoll = 0.0

private var audioEngine: AVAudioEngine = AVAudioEngine()
private var mixer: AVAudioMixerNode = AVAudioMixerNode()
private var players: [AVAudioPlayer] = []

// CoreMotion Flow Control
public var bUseCoreMotionHeadphones = false
public var bUseCustomOrientationInput = false // <---- not in use

@available(iOS 14.0, *)
class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CMHeadphoneMotionManagerDelegate {
    fileprivate let videoplayer: PlayListPlayer = PlayListPlayer.shared
    
    // MARK: - IBOutlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var currentPlayingString: UILabel!
    @IBOutlet weak var headphoneMotionManagerActive: UILabel!
    @IBOutlet weak var headingImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var playheadSlider: UISlider!
    @IBOutlet weak var movieRenderingView: MovieRenderingView!
    @IBOutlet weak var headerLineOne: UILabel!
    @IBOutlet weak var headerLineTwo: UILabel!
    @IBOutlet weak var headerLineThree: UILabel!
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var playControlsBG: UIView!
    
    struct AudioInput: Identifiable {
        var id = UUID()
        var name: String
        var videoIndex: Int
        var format: String
        var files: [String]
    }

    var pickerData: [AudioInput] = [
        AudioInput(name: "Clock", videoIndex: -1, format: "Mach1Spatial", files: [
            "01-1",
            "01-2",
            "01-3",
            "01-4",
            "01-5",
            "01-6",
            "01-7",
            "01-8",
        ]),
        AudioInput(name: "Chinatown Window", videoIndex: -1, format: "Mach1Spatial", files: [
            "02-1",
            "02-2",
            "02-3",
            "02-4",
            "02-5",
            "02-6",
            "02-7",
            "02-8",
        ]),
    ]
    
    func playVideo() {
        if (pickerData[currentSelection].videoIndex < 0) {
            // No video for this track so show album art instead
            stopVideo()
        } else {
            if !self.videoplayer.isPlaying() {
                self.videoplayer.play()
                self.videoplayer.playMode = .repeatItem
                movieRenderingView.isHidden = false
                albumImage.isHidden = true
            }
        }
    }
    
    func stopVideo() {
        if self.videoplayer.isPlaying() {
            self.videoplayer.pause()
            self.videoplayer.playMode = .repeatPlayList
            movieRenderingView.isHidden = true
            albumImage.isHidden = false
        }
    }
    
    func startSpatialAudioPlayback(startTime: TimeInterval) {
        if !isPlaying {
            if (players.isEmpty) {
                loadSpatialAudioAssets()
            }
            do {                
                let startDelayTime = 0.1
                let now = players[0].deviceCurrentTime
                let delayedTime = now + startDelayTime
                                
                for audioPlayer in players {
                    audioPlayer.currentTime = startTime
                    audioPlayer.play(atTime: delayedTime)
                }

                print("isPlaying")
                isPlaying = true
            } catch {
                print("error occured")
            }
        } else {
            for audioPlayer in players {
                audioPlayer.stop()
            }
            let startDelayTime = 0.1
            let now = players[0].deviceCurrentTime
            let delayedTime = now + startDelayTime
            
            for audioPlayer in players {
                audioPlayer.currentTime = startTime
                audioPlayer.play(atTime: delayedTime)
            }
            
            print("isPlaying")
            isPlaying = true
        }
        playVideo()
        let playButtonStatus = isPlaying ? "□" : "▷"
        playButton.setTitle(playButtonStatus, for: [.normal])
    }
    
    func loadSpatialAudioAssets(){
        currentSelection = picker.selectedRow(inComponent: 0)
        currentPlayingString.text = pickerData[currentSelection].name

        do {
            players = []
            
            var idx = 0
            for i in 0..<pickerData[currentSelection].files.count {
                //load in the individual streams of audio from a Mach1 Spatial encoded audio file
                //this example assumes you have decoded the multichannel (8channel) audio file into individual streams
                players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: pickerData[currentSelection].files[i], ofType: "aac")!)))
                players.append(try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: pickerData[currentSelection].files[i], ofType: "aac")!)))
                
                players[idx].numberOfLoops = 0
                players[idx].pan = 1.0;
                players[idx].volume = 0.0;
                players[idx].prepareToPlay()
                idx = idx + 1
                
                players[idx].numberOfLoops = 0
                players[idx].pan = -1.0;
                players[idx].volume = 0.0;
                players[idx].prepareToPlay()
                idx = idx + 1
            }
            print("loaded selectedAudio:", currentSelection)
                        
            // load video associated for track
            if (pickerData[currentSelection].videoIndex >= 0) {
                self.videoplayer.set(currentIndex: currentSelection)
            } else {
                // no video for this track, set index to 0
                self.videoplayer.set(currentIndex: 0)
            }
            print("Video Index: ", self.videoplayer.currentIndex)
            
            isPlaying = false
        } catch {
            print (error)
        }
    }
    
    func stopSpatialAudioPlayback(stopForUnload: Bool){
        if isPlaying && !stopForUnload {
            for audioPlayer in players {
                audioPlayer.pause()
            }
            print("paused")
        } else {
            for audioPlayer in players {
                audioPlayer.stop()
            }
            players = []
            playheadSlider.value = 0.0
            print("stopped")
        }
        
        stopVideo()
        isPlaying = false
        
        let playButtonStatus = isPlaying ? "□" : "▷"
        playButton.setTitle(playButtonStatus, for: [.normal])
    }
        
    @IBAction func playButtonTapped(_ sender: UIButton) {
        togglePlayButton()
    }
    
    func togglePlayButton() {
        if !isPlaying {
            if players.isEmpty || currentSelection != picker.selectedRow(inComponent: 0)  { // reload audio if never loaded or new selected track
                loadSpatialAudioAssets()
            }
            startSpatialAudioPlayback(startTime: 0.0 + players[0].currentTime + playbackCurrentTimeFromBackground)
            playbackCurrentTimeFromBackground = 0.0 //reset now that it has played again
        } else if isPlaying {
            stopSpatialAudioPlayback(stopForUnload: false)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        let position = picker.selectedRow(inComponent: 0)
        stopSpatialAudioPlayback(stopForUnload: true)
        if position > 0 {
            self.picker.selectRow(position - 1, inComponent: 0, animated: true)
        } else {
            startSpatialAudioPlayback(startTime: 0.0)
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        let position = picker.selectedRow(inComponent: 0)
        
        stopSpatialAudioPlayback(stopForUnload: true)
        
        if position < (pickerData.count - 1) {
            self.picker.selectRow(position + 1, inComponent: 0, animated: true)
        } else {
            startSpatialAudioPlayback(startTime: 0.0)
        }
        
        self.loadSpatialAudioAssets()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.togglePlayButton()
            //self.playButton.sendActions(for: .touchUpInside)
        }
    }
    
    @IBAction func playheadSliderTouchDown(_ sender: UISlider) {
        sliderCurrentlyTouched = true
    }
    
    @IBAction func playheadSliderTapped(_ sender: UISlider) {
        if players.isEmpty {
            loadSpatialAudioAssets()
        }
        startSpatialAudioPlayback(startTime: TimeInterval(TimeInterval(sender.value * Float(players[0].duration))))
        //print(TimeInterval(sender.value * Float(players[0].duration)))
        
        sliderCurrentlyTouched = false
    }
    
    func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        print("connect")
        bUseCoreMotionHeadphones = true
        bUseCustomOrientationInput = false
        DispatchQueue.main.async() {
            self.headphoneMotionManagerActive.text = (bUseCoreMotionHeadphones || bUseCustomOrientationInput) ? "🎧" : ""
        }
    }
    func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        print("disconnect")
        bUseCoreMotionHeadphones = false
        DispatchQueue.main.async() {
            self.headphoneMotionManagerActive.text = (bUseCoreMotionHeadphones || bUseCustomOrientationInput) ? "🎧" : ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
        // Connect data:
        self.picker.delegate = self
        self.picker.dataSource = self
        headphoneMotionManager.delegate = self
        
        let thumbImage = UIImage(named: "thumb")
        playheadSlider.setThumbImage(thumbImage, for: .normal)
        playheadSlider.setThumbImage(thumbImage, for: .highlighted)
        
        // set layer depths
        nextButton.layer.zPosition = 99
        playButton.layer.zPosition = 99
        headingImage.layer.zPosition = 99
        backButton.layer.zPosition = 99
        picker.layer.zPosition = 99
        playheadSlider.layer.zPosition = 99
        currentPlayingString.layer.zPosition = 99
        headerLineOne.layer.zPosition = 99
        headerLineTwo.layer.zPosition = 99
        headerLineThree.layer.zPosition = 99
        albumImage.layer.zPosition = 99
        
        // play control background
        playControlsBG.alpha = 0.5
        playControlsBG.layer.cornerRadius = 20

        var urls: [URL] = []
        for i in 0..<pickerData.count {
            if (pickerData[i].videoIndex > -1) {
                let url: URL = URL(fileURLWithPath: Bundle.main.path(forResource: String(pickerData[i].videoIndex), ofType: "mp4")!)
                urls.append(url)
            }
        }
        self.videoplayer.set(playList: urls)
        movieRenderingView.set(player: self.videoplayer)
        //movieRenderingView.setToAspectFill()

        // resize to full screen aspect ratio
        movieRenderingView.layer.frame = self.view.bounds
        //movieRenderingView.setToAspectFill()

        self.videoplayer.engine().isMuted = true
        
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
        
        /// This example declares 2 motion managers:
        /// `headphoneMotionManager` is for headphone IMU enalbed device
        /// `motionManager` is for the native device's IMU
        if (bUseCustomOrientationInput) {
            print("Device Bose motion started")
        }
        
        /// Warning:
        /// You're expected to correct and manage the orientation from devices in accordance with your UX
        /// to get accurate playback from Mach1Decode API
        /// https://dev.mach1.tech/#mach1-internal-angle-standard
        
        /// This example does not have motion management logic in place, it is expected
        /// that the app will be launched on a tabletop and will assume 0 values for
        /// yaw, pitch, roll upon launch. Rotating the device in portrait mode on table
        /// is the expected usage.
        
        /// `headphoneMotionManager` is for headphone IMU enalbed device
        /// `motionManager` is for the native device's IMU
        /// `bUseCoreMotionHeadphones` is used to block the update thread of one of the two motion managers
        ///  based on detection of supported IMU headphone devices
        
        if (headphoneMotionManager.isDeviceMotionAvailable == true) || (motionManager.isDeviceMotionAvailable == true) {
            let queue = OperationQueue()
            motionManager.deviceMotionUpdateInterval = 0.01
            
            // start native IMU core motion manager thread
            motionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] (motion, error) -> Void in
                // block update thread unless all other motion managers are inactive
                if (!bUseCoreMotionHeadphones && !bUseCustomOrientationInput && motionManager.isDeviceMotionAvailable) {
                    // Get the attitudes of the device
                    let attitude = motion?.attitude
                    //Device orientation management
                    let yawDegrees = attitude!.yaw * 180 / .pi
                    //devicePitch = attitude!.pitch * 180 / .pi
                    let rollDegrees = attitude!.roll * 180 / .pi

                    // gimbal lock roll & yaw so that yaw compass angle outputs whether phone is on table or in hand
                    if(rollDegrees < 0 && yawDegrees < 0){
                        deviceYaw = 360 - (-1 * (yawDegrees + rollDegrees))
                    } else {
                        deviceYaw = yawDegrees + rollDegrees
                    }

                    devicePitch = 0.0 // if using phone IMU, don't use pitch angle changes
                    deviceRoll = 0.0 // if using phone IMU, don't use roll angle changes

                    if isPlaying {
                        //Send device orientation to m1obj with the preferred algo
                        m1Decode.beginBuffer()
                        m1Decode.setRotationDegrees(newRotationDegrees: Mach1Point3D(x: Float(-deviceYaw), y: Float(devicePitch), z: Float(deviceRoll)))
                        let result: [Float] = m1Decode.decodeCoeffs()
                        m1Decode.endBuffer()
                                            
                        //Use each coeff to decode multichannel Mach1 Spatial mix
                        for i in 0...7 {
                            players[i * 2].setVolume(Float(result[i * 2]), fadeDuration: 0)
                            players[i * 2 + 1].setVolume(Float(result[i * 2 + 1]), fadeDuration: 0)
                            //print(String(players[i * 2].currentTime) + " ; " + String(i * 2))
                            //print(String(players[i * 2 + 1].currentTime) + " ; " + String(i * 2 + 1))
                        }
                    }
                    
                    func deg2rad(_ number: Double) -> Double {
                        return number * .pi / 180
                    }
                    
                    DispatchQueue.main.async() {
                        UIView.animate(withDuration: 0.01) {
                            self?.headingImage.transform = CGAffineTransform(rotationAngle: deg2rad(-deviceYaw))
                        }
                        self?.headphoneMotionManagerActive.text = (bUseCoreMotionHeadphones || bUseCustomOrientationInput) ? "🎧" : ""
                        if isPlaying {
                            let normalizedPos = players[0].currentTime / players[0].duration
                            if (!sliderCurrentlyTouched){ // update slider UI if not interacted with
                                self?.playheadSlider.value = Float(normalizedPos)
                            }
                            //print(normalizedPos)
                            if (normalizedPos >= 0.999) {
                                // play next track
                                self?.nextButton.sendActions(for: .touchUpInside)
                            }
                        }
                    }
                }
            })
            
            // start headphone core motion manager thread
            headphoneMotionManager.startDeviceMotionUpdates(to: queue, withHandler: { [weak self] (headphonemotion, error) -> Void in
                // block update thread unless all other motion managers are inactive
                if (bUseCoreMotionHeadphones && !bUseCustomOrientationInput && headphoneMotionManager.isDeviceMotionAvailable) {
                    // Get the attitudes of the device
                    let hpattitude = headphonemotion?.attitude
                    //Device orientation management
                    deviceYaw = hpattitude!.yaw * 180 / .pi
                    devicePitch = hpattitude!.pitch * 180 / .pi
                    deviceRoll = hpattitude!.roll * 180 / .pi
                    
                    if isPlaying {
                        //Send device orientation to m1obj with the preferred algo
                        m1Decode.beginBuffer()
                        /// NOTE: Disabled roll orientation due to bug on Apple IMU implementation in API
                        m1Decode.setRotationDegrees(newRotationDegrees: Mach1Point3D(x: Float(-deviceYaw), y: Float(devicePitch), z: Float(0)))
                        let result: [Float] = m1Decode.decodeCoeffs()
                        m1Decode.endBuffer()
                                            
                        //Use each coeff to decode multichannel Mach1 Spatial mix
                        for i in 0...7 {
                            players[i * 2].setVolume(Float(result[i * 2]), fadeDuration: 0)
                            players[i * 2 + 1].setVolume(Float(result[i * 2 + 1]), fadeDuration: 0)
                            //print(String(players[i * 2].currentTime) + " ; " + String(i * 2))
                            //print(String(players[i * 2 + 1].currentTime) + " ; " + String(i * 2 + 1))
                        }
                    }
                    
                    func deg2rad(_ number: Double) -> Double {
                        return number * .pi / 180
                    }
                    
                    DispatchQueue.main.async() {
                        UIView.animate(withDuration: 0.01) {
                            self?.headingImage.transform = CGAffineTransform(rotationAngle: deg2rad(-deviceYaw))
                        }
                        self?.headphoneMotionManagerActive.text = (bUseCoreMotionHeadphones || bUseCustomOrientationInput) ? "🎧" : ""
                        if isPlaying {
                            let normalizedPos = players[0].currentTime / players[0].duration
                            if (!sliderCurrentlyTouched){ // update slider UI if not interacted with
                                self?.playheadSlider.value = Float(normalizedPos)
                            }
                            //print(normalizedPos)
                            if (normalizedPos >= 0.999) {
                                // play next track
                                self?.nextButton.sendActions(for: .touchUpInside)
                            }
                        }
                    }
                }
            })
            print("Device coremotion started")
        } else {
            print("Device coremotion unavailable");
        }
        
        loadSpatialAudioAssets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    
        if (isPlaying) {
            stopSpatialAudioPlayback(stopForUnload: true)
        }
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 15)
            pickerLabel?.textAlignment = .left
        }
        pickerLabel?.text = pickerData[row].name
        pickerLabel?.textColor = UIColor.lightGray
        return pickerLabel!
    }
    
    // MARK: - Background handling

    @objc func appMovedToBackground() {
        print("App moved to background!")
        playbackCurrentTimeFromBackground = players[0].currentTime
        let normalizedPos = playbackCurrentTimeFromBackground / players[0].duration // calculate this before stop()
        stopSpatialAudioPlayback(stopForUnload: true)
        // set playhead as visual indicator to user on return
        playheadSlider.value = Float(normalizedPos)
    }

    //TODO: why dont these work?
    func applicationDidEnterBackground(application: UIApplication) {
        print("we are in the background...")
    }
     
    func applicationWillTerminate(application: UIApplication) {
        print("we have terminated")
    }

}

@available(iOS 14.0, *)
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
