//
//  Encoder.swift
//

import Foundation
import Mach1SpatialAPI
import AVFoundation
import UIKit

public class Encoder {
    public var currentAzimiuthDegrees : Float = 0.0;
    public var masterGain : Float = 1.0;
    var m1Encode : Mach1Encode = Mach1Encode()
    var volume : Float = 1.0
    var type : Mach1EncodeInputModeType = Mach1EncodeInputModeMono;
    
    // MARK: AVAudio properties
    var engines: [AVAudioEngine] = [AVAudioEngine() /*, AVAudioEngine() */]
    var players: [AVAudioPlayerNode] = [AVAudioPlayerNode() /* , AVAudioPlayerNode() */]
    var bufferCounters : [Int] = [0,0]
    let sampleRate: Float = 22050
    var converter = AVAudioConverter(from: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 22050, channels: 2, interleaved: true)!,
                                     to: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 2, interleaved: false)!)
    var synthesizer = AVSpeechSynthesizer()
    let audioSession = AVAudioSession.sharedInstance()
    let outputFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 2, interleaved: false)!
    var lastGains = [0.0, 0.0]
    var filteredGains = [0.0, 0.0]
    
    public func setCurrentAzimuthDegrees(degrees: Float) {
        //print("Set new azimuth's value to \(degrees)")
        self.currentAzimiuthDegrees = degrees;
    }
    
    init(){
    }
    
    /**
     * Plays the audio file which contains the audio file to be triggered.
     * @param pathToFile Path to generated audio file
     */
    public func playSpatialAudioCue(audioCue: String) {
        stop() // Nicely reset audio to block overlapping play calls
        
        /// In this implementation we are using `getResultingCoeffsDecoded()` to directly create panning objects via Mach1Encode from the buffers provided
        /// by the TTS synthesizer, we then pass the buffers to a stereo output `AVAudioPlayerNode()` instead of two mono players like in our other examples
        /// to ensure player to player sync easily.
        /// A more recommended implementation would be creating a mixer class to receive multiple 4/8 channel Mach1Encode outputs and sum them to a single Mach1Decode
        /// to fully leverage use of Mach1 Spatial (building render outputs or utilizing other input formats)
        players = [AVAudioPlayerNode()]
        setupAudio()
        
        // Set voice message
        let utterance = AVSpeechUtterance(string: audioCue)
        
        var sampleCounter: Int! = 0
        
        if #available(iOS 13.0, *) {
            // Write the new voice message in the audio file
            synthesizer.write(utterance) { buffer in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 else {
                    print("could not create buffer or buffer empty")
                    return
                }
                
                let intermediateBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 22050, channels: 2, interleaved: true)!, frameCapacity: pcmBuffer.frameCapacity)
                for i in 0...pcmBuffer.frameLength {
                    self.filteredGains[0] = self.filteredGains[0] * 0.99 + self.lastGains[0] * 0.01
                    self.filteredGains[1] = self.filteredGains[1] * 0.99 + self.lastGains[1] * 0.01
                    
                    
                    intermediateBuffer!.int16ChannelData!.pointee[Int(i) * 2] = Int16(Double(pcmBuffer.int16ChannelData!.pointee[Int(i)]) * self.filteredGains[0])
                    intermediateBuffer!.int16ChannelData!.pointee[Int(i) * 2 + 1] = Int16(Double(pcmBuffer.int16ChannelData!.pointee[Int(i)]) * self.filteredGains[1])
                }
                intermediateBuffer!.frameLength = pcmBuffer.frameLength
                
                /// Note: Need to convert the buffer to different format because AVAudioEngine does not support the format returned from AVSpeechSynthesizer
                let convertedBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 2, interleaved: false)!, frameCapacity: 4410)!
                do {
                    try self.converter!.convert(to: convertedBuffer, from: intermediateBuffer!)
                    // Schedule buffers
                    sampleCounter += Int(convertedBuffer.frameLength)
                    for i in 0...self.players.count-1{
                        self.players[i].scheduleBuffer(convertedBuffer,
                                                       completionCallbackType: .dataPlayedBack, completionHandler: { (type) -> Void in
                        })
                    }
                    self.converter!.reset()
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
            print ("player ", i, " sample time = ", startTime.sampleTime)
            self.players[i].play(at: startTime)
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
    }
    
    func setupAudio() {
        /// Note: Connecting an [AudioUnit] to the engine somehow starts the shared audioSession, and if that audiosession
        /// is not configured with .mixWithOthers and if it's not deactivated afterwards, this will stop any background music
        /// that was already playing. So first configure the audio session, then setup the engine and then deactivate the session again.
        try? self.audioSession.setCategory(.playback, options: .mixWithOthers)
        
        for i in 0...engines.count-1{
            engines[i].attach(players[i])
            print("main mixer node channel count:", engines[i].mainMixerNode.inputFormat(forBus: 0).channelCount)
            let format1 = engines[i].mainMixerNode.inputFormat(forBus: 0)
            engines[i].connect(players[i], to: engines[i].mainMixerNode, format: outputFormat)
            engines[i].prepare()
        }
        try? self.audioSession.setActive(false)
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
        m1Encode.setAzimuthDegrees(azimuthDegrees: self.currentAzimiuthDegrees);
        m1Encode.setDiverge(diverge: 1.0);
        m1Encode.setElevation(elevationFromMinus1to1: 0);
        m1Encode.setAutoOrbit(setAutoOrbit: true)
        m1Encode.setIsotropicEncode(setIsotropicEncode: true)
        m1Encode.setInputMode(inputMode: type)
        m1Encode.setOutputMode(outputMode: Mach1EncodeOutputModeM1Horizon) /// Note: Using Mach1Horizon for Yaw only processing
        m1Encode.generatePointResults()
        
        //Use each coeff to decode multichannel Mach1 Spatial mix
        let gains : [Float] = m1Encode.getResultingCoeffsDecoded(decodeType: decodeType, decodeResult: decodeArray)
        lastGains[0] = Double(gains[0])
        lastGains[1] = Double(gains[1])
    }
    
}
