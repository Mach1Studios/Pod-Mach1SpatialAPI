//
//  Encoder.swift
//

import Foundation
import Mach1SpatialAPI
import AVFoundation
import UIKit

public class Encoder {
    public var currentAzimiuthDegrees : Float = -90.0;
    public var masterGain : Float = 1.0;
    var m1Encode : Mach1Encode = Mach1Encode()
    var volume : Float = 1.0
    //var players: [AVAudioPlayer] = [AVAudioPlayer(), AVAudioPlayer()]
    var type : Mach1EncodeInputModeType = Mach1EncodeInputModeMono;
    //var spatialMixer : SpatialMixer = SpatialMixer();
    
    // MARK: AVAudio properties
    var engines: [AVAudioEngine] = [AVAudioEngine(), AVAudioEngine()]
    var players: [AVAudioPlayerNode] = [AVAudioPlayerNode(), AVAudioPlayerNode()]
    var eqEffects: [AVAudioUnitEQ] = [AVAudioUnitEQ(), AVAudioUnitEQ()]
    var bufferCounters : [Int] = [0,0]
    //var player = AVAudioPlayerNode()
    let sampleRate: Float = 22050
    var converter = AVAudioConverter(from: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 22050, channels: 1, interleaved: false)!, to: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!)
    var synthesizer = AVSpeechSynthesizer()
    
    let audioSession = AVAudioSession.sharedInstance()
    let outputFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!
    
    public func setCurrentAzimuthDegrees(degress: Float) {
        print("Set new azimuth's value to \(degress)")
        self.currentAzimiuthDegrees = degress;
    }
    
    init(){
    }
    
    /**
     * Plays the audio file which contains the audio file to be triggered.
     * @param pathToFile Path to generated audio file
     */
    public func playSpatialAudioCue(audioCue: String) {
        stop()
        //if players[0].isPlaying {
        //    resetIfPlaying()
        //}
        
        // Reset players
        players = [AVAudioPlayerNode(), AVAudioPlayerNode()]
        // Set up left/right channel
        self.players[0].pan = -1.0
        self.players[1].pan = 1.0
        
        // Connecting the equalizer to the engine
        setupAudio(globalGain: 0)
        
        // Set voice message
        let utterance = AVSpeechUtterance(string: audioCue)
        
        if #available(iOS 13.0, *) {
            // Write the new voice message in the audio file
            synthesizer.write(utterance) { buffer in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 else {
                    print("could not create buffer or buffer empty")
                    return
                }
                
                // QUIRCK Need to convert the buffer to different format because AVAudioEngine does not support the format returned from AVSpeechSynthesizer
                let convertedBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: pcmBuffer.format.sampleRate, channels: pcmBuffer.format.channelCount, interleaved: false)!, frameCapacity: pcmBuffer.frameCapacity)!
                do {
                    try self.converter!.convert(to: convertedBuffer, from: pcmBuffer)
                    
                    let fcd = convertedBuffer.floatChannelData!
                    let capacity = convertedBuffer.frameCapacity
                    
                    print(self.players.count)
                    // Schedule buffers
                    for i in 0...self.players.count-1{
                        // When finished
                        /*self.bufferCounters[i] += 1
                      
                        self.players[i].scheduleBuffer(convertedBuffer, completionCallbackType: .dataPlayedBack, completionHandler: { (type) -> Void in
                            DispatchQueue.main.async {
                                self.bufferCounters[i] -= 1
                                if self.bufferCounters[i] == 0 {
                                    self.players[i].stop()
                                    self.players[i].volume = 0.0
                                    self.engines[i].stop()
                                    try! self.audioSession.setActive(false, options: [])
                                }
                            }
                        })*/
                        
                        let playerSampleTime: AVAudioFramePosition? = self.players[0].lastRenderTime?.sampleTime
                        
                        let delay: Float = 0.1
                        guard (playerSampleTime != nil) else {
//                            let startTime: AVAudioTime = AVAudioTime(sampleTime: 0 + Int64((delay * self.sampleRate)), atRate: Double(self.sampleRate))
                            print("adding buffer... 1")
                            self.players[i].scheduleBuffer(convertedBuffer,
//                                                           at: startTime,
                                                           completionCallbackType: .dataPlayedBack, completionHandler: { (type) -> Void in
                                print("Converted buffer added")
                            })
                            self.converter!.reset()
                            continue;
                        }
                        
//                        let startTime: AVAudioTime = AVAudioTime(sampleTime: playerSampleTime! + Int64((delay * self.sampleRate)), atRate: Double(self.sampleRate))

                        print("adding buffer... 2")
                        self.players[i].scheduleBuffer(convertedBuffer,
//                                                       at: startTime,
                                                       completionCallbackType: .dataPlayedBack, completionHandler: { (type) -> Void in
                            print("Converted buffer added")
                        })

                    }
                    
                    self.converter!.reset()
                    //self.player.prepare(withFrameCount: convertedBuffer.frameLength)
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            // Fallback on earlier versions
            print("iOS version does not match the minimum requirements (> iOS 13.0)")
        }
        
        // Activates the audio sessions
        activateAudioSession()
        
        // Start audio engines
        for i in 0...self.engines.count-1{
            try! self.engines[i].start()
        }
        
        print("Playing...")
        play()
        
    }
    
    func play() {
        for i in 0...self.players.count-1{
            print("Play audio cue in players[\(i)]")
            self.players[i].volume = 1.0
            // Set delay
            let playerSampleTime: AVAudioFramePosition? = players[0].lastRenderTime?.sampleTime
            let delay: Float = 0.1
            let startTime: AVAudioTime = AVAudioTime(sampleTime: playerSampleTime! + Int64((delay * sampleRate)), atRate: Double(sampleRate))
            self.players[i].play(at: startTime)
            //self.players[i].play()
        }
    }
    
    func stop(){
        print("Stop audio players")
        for i in 0...self.players.count-1{
            self.bufferCounters[i] = 0
            self.players[i].volume = 0.0
            self.players[i].stop()
            self.engines[i].stop()
        }
        self.converter!.reset()
        //try! self.audioSession.setActive(false, options: [])

    }
    
    func setupAudio(globalGain: Float) {
        // QUIRCK: Connecting the equalizer to the engine somehow starts the shared audioSession, and if that audiosession is not configured with .mixWithOthers and if it's not deactivated afterwards, this will stop any background music that was already playing. So first configure the audio session, then setup the engine and then deactivate the session again.
        try? self.audioSession.setCategory(.playback, options: .mixWithOthers)
        
//        for i in 0...eqEffects.count-1{
//            eqEffects[i].globalGain = globalGain
//        }
        
        for i in 0...engines.count-1{
            engines[i].attach(players[i])
//            engines[i].attach(eqEffects[i])
            engines[i].connect(players[i], to: engines[i].mainMixerNode, format: outputFormat)
//            engines[i].connect(players[i], to: eqEffects[i], format: outputFormat)
//            engines[i].connect(eqEffects[i], to: engines[i].mainMixerNode, format: outputFormat)
            engines[i].prepare()
        }
        
        try? self.audioSession.setActive(true)
        
        print("Session created")
    }
    
    
    func activateAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .voicePrompt, options: [.mixWithOthers, .duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Activating audio session")
            
        } catch {
            print("An error has occurred while setting the AVAudioSession.")
        }
    }
    
    /**
     * Update the properties of the encoder
     *
     * @param decodeArray
     * @param decodeType
     */
    func update(decodeArray: [Float], decodeType: Mach1DecodeAlgoType) {
        m1Encode.setAzimuthDegrees(azimuthDegrees: 90.0);
        m1Encode.setDiverge(diverge: 1.0);
        m1Encode.setElevation(elevationFromMinus1to1: 0);
        m1Encode.setAutoOrbit(setAutoOrbit: true)
        m1Encode.setIsotropicEncode(setIsotropicEncode: true)
        m1Encode.setInputMode(inputMode: type)
        m1Encode.generatePointResults()
        
        //Use each coeff to decode multichannel Mach1 Spatial mix
        let gains : [Float] = m1Encode.getResultingCoeffsDecoded(decodeType: decodeType, decodeResult: decodeArray)
        
        for i in 0..<players.count {
            players[i].volume = gains[i] * volume
        }
        
    }
    
}
