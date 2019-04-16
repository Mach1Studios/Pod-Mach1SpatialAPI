import Foundation

public class Mach1Decode {
    var M1obj : UnsafeMutableRawPointer
    
    public init() {
        M1obj = Mach1DecodeCAPI_create()
    }
    
    deinit {
        Mach1DecodeCAPI_delete(M1obj)
    }
    
    public func setPlatformType(type: Mach1PlatformType) {
        Mach1DecodeCAPI_setPlatformType(M1obj, type)
        /// Set the device's angle order and convention if applicable
        ///
        /// - Parameters:
        ///     - Mach1PlatformDefault = 0
        ///     - Mach1PlatformUnity = 1
        ///     - Mach1PlatformUE = 2
        ///     - Mach1PlatformOfEasyCam = 3
        ///     - Mach1PlatformAndroid = 4
        ///     - Mach1PlatformiOS = 5
    }
    
    public func setDecodeAlgoType(newAlgorithmType: Mach1DecodeAlgoType) {
        Mach1DecodeCAPI_setDecodeAlgoType(M1obj, newAlgorithmType)
        /// Set the decoding algorithm
        ///
        /// - Parameters:
        ///     - Mach1DecodeAlgoSpatial = 0 (default spatial | 8 channels)
        ///     - Mach1DecodeAlgoAltSpatial = 1 (periphonic spatial | 8 channels)
        ///     - Mach1DecodeAlgoHorizon = 2 (compass / yaw | 4 channels)
        ///     - Mach1DecodeAlgoHorizonPairs = 3 (compass / yaw | 4x stereo mastered pairs)
        ///     - Mach1DecodeAlgoSpatialPairs = 4 (experimental periphonic pairs | 8x stereo mastered pairs)
    }

    public func setFilterSpeed(filterSpeed: Float) {
        Mach1DecodeCAPI_setFilterSpeed(M1obj, filterSpeed)
        /// Filter speed determines the amount of angle smoothing applied 
        /// to the orientation angles used for the Mach1DecodeCore class
        ///
        /// - Parameters: 
        ///     - value range: 0.0001 -> 1.0 (where 0.1 would be a slow filter
        ///     and 1.0 is no filter)
    }
    
    public func beginBuffer() {
        Mach1DecodeCAPI_beginBuffer(M1obj)
        /// Call this function before reading from the Mach1Decode buffer
    }
    
    public func endBuffer() {
        Mach1DecodeCAPI_endBuffer(M1obj)
        /// Call this function after reading from the Mach1Decode buffer
    }
    
    public func getCurrentTime() -> Int {
        let t = Mach1DecodeCAPI_getCurrentTime(M1obj)
        return t
    }
    
    public func getLog() -> String {
        let str = String(cString: UnsafePointer(Mach1DecodeCAPI_getLog(M1obj)))
        return str
    }
    
    public func decode(Yaw: Float, Pitch: Float, Roll: Float, bufferSize: Int = 0, sampleIndex: Int = 0) -> [Float] {
        var array: [Float] = Array(repeating: 0.0, count: 18)
        Mach1DecodeCAPI_decode(M1obj, Yaw, Pitch, Roll, &array, CInt(bufferSize), CInt(sampleIndex))
        return array
        /// Call with current update's angles to return the resulting coefficients
        /// to apply to the audioplayer's volume
    }
   
}