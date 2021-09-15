//
// ReactionsApp
//

import Foundation
import UIKit

public struct DeviceInfo {
    private init() { }

    /// Returns whether the animation rate should be reduced for this device for heavy animations
    ///
    /// - Note: As a general cut-off, anything with an A10 chip returns true. The lowest hardware tested was an iPhone 6S, \
    /// which uses an A9 chip. A physical model using an A10 chip was not available to test with.
    public static func shouldThrottleAnimationRateIfNeeded() -> Bool {
        guard let model = UIDevice().model else {
            // Likely to be a newer device, so we should not throttle
            return false
        }

        switch model {
        case .iPhone6S, .iPhone6SPlus, .iPhone7, .iPhone7Plus: return true

        case .iPad5, .iPad6, .iPad7: return true

        case .iPadAir2: return true

        case .iPadMini4: return true

        case .iPod7: return true

        default: return false
        }
    }
}

// Device detection code from https://stackoverflow.com/questions/26028918/how-to-determine-the-current-iphone-device-model

/// The current models we support. This is not updated for new devices, as we're currently only interested in detecting
/// older devices
private enum Model {

    case simulator

    //iPod
    case iPod7

    //iPad
    case iPadAir2
    case iPadAir3
    case iPadAir4
    case iPad5
    case iPad6
    case iPad7
    case iPad8

    //iPad Mini
    case iPadMini4
    case iPadMini5

    //iPad Pro
    case iPadPro9_7
    case iPadPro10_5
    case iPadPro11
    case iPadPro2_11
    case iPadPro3_11
    case iPadPro12_9
    case iPadPro2_12_9
    case iPadPro3_12_9
    case iPadPro4_12_9
    case iPadPro5_12_9

    //iPhone
    case iPhone6S
    case iPhone6SPlus
    case iPhoneSE
    case iPhone7
    case iPhone7Plus
    case iPhone8
    case iPhone8Plus
    case iPhoneX
    case iPhoneXS
    case iPhoneXSMax
    case iPhoneXR
    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax
    case iPhoneSE2
    case iPhone12Mini
    case iPhone12
    case iPhone12Pro
    case iPhone12ProMax
}

extension UIDevice {

    fileprivate var model: Model? {
        if let code = modelCode, let model = Self.modelMap[code] {
            print("Model is \(model)")
            return model
        }
        print("No model")
        return nil
    }

    private var modelCode: String? {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        if let code = modelCode {
            return String(validatingUTF8: code)
        }
        return nil
    }

    private static let modelMap : [String: Model] = [
        //Simulator
        "i386"      : .simulator,
        "x86_64"    : .simulator,

        //iPod
        "iPod9,1"   : .iPod7,

        //iPad
        "iPad6,11"  : .iPad5, //iPad 2017
        "iPad6,12"  : .iPad5,
        "iPad7,5"   : .iPad6, //iPad 2018
        "iPad7,6"   : .iPad6,
        "iPad7,11"  : .iPad7, //iPad 2019
        "iPad7,12"  : .iPad7,
        "iPad11,6"  : .iPad8, //iPad 2020
        "iPad11,7"  : .iPad8,

        //iPad Mini
        "iPad5,1"   : .iPadMini4,
        "iPad5,2"   : .iPadMini4,
        "iPad11,1"  : .iPadMini5,
        "iPad11,2"  : .iPadMini5,

        //iPad Pro
        "iPad6,3"   : .iPadPro9_7,
        "iPad6,4"   : .iPadPro9_7,
        "iPad7,3"   : .iPadPro10_5,
        "iPad7,4"   : .iPadPro10_5,
        "iPad6,7"   : .iPadPro12_9,
        "iPad6,8"   : .iPadPro12_9,
        "iPad7,1"   : .iPadPro2_12_9,
        "iPad7,2"   : .iPadPro2_12_9,
        "iPad8,1"   : .iPadPro11,
        "iPad8,2"   : .iPadPro11,
        "iPad8,3"   : .iPadPro11,
        "iPad8,4"   : .iPadPro11,
        "iPad8,9"   : .iPadPro2_11,
        "iPad8,10"  : .iPadPro2_11,
        "iPad13,4"  : .iPadPro3_11,
        "iPad13,5"  : .iPadPro3_11,
        "iPad13,6"  : .iPadPro3_11,
        "iPad13,7"  : .iPadPro3_11,
        "iPad8,5"   : .iPadPro3_12_9,
        "iPad8,6"   : .iPadPro3_12_9,
        "iPad8,7"   : .iPadPro3_12_9,
        "iPad8,8"   : .iPadPro3_12_9,
        "iPad8,11"  : .iPadPro4_12_9,
        "iPad8,12"  : .iPadPro4_12_9,
        "iPad13,8"  : .iPadPro5_12_9,
        "iPad13,9"  : .iPadPro5_12_9,
        "iPad13,10" : .iPadPro5_12_9,
        "iPad13,11" : .iPadPro5_12_9,

        //iPad Air
        "iPad5,3"   : .iPadAir2,
        "iPad5,4"   : .iPadAir2,
        "iPad11,3"  : .iPadAir3,
        "iPad11,4"  : .iPadAir3,
        "iPad13,1"  : .iPadAir4,
        "iPad13,2"  : .iPadAir4,


        //iPhone
        "iPhone8,1" : .iPhone6S,
        "iPhone8,2" : .iPhone6SPlus,
        "iPhone8,4" : .iPhoneSE,
        "iPhone9,1" : .iPhone7,
        "iPhone9,3" : .iPhone7,
        "iPhone9,2" : .iPhone7Plus,
        "iPhone9,4" : .iPhone7Plus,
        "iPhone10,1" : .iPhone8,
        "iPhone10,4" : .iPhone8,
        "iPhone10,2" : .iPhone8Plus,
        "iPhone10,5" : .iPhone8Plus,
        "iPhone10,3" : .iPhoneX,
        "iPhone10,6" : .iPhoneX,
        "iPhone11,2" : .iPhoneXS,
        "iPhone11,4" : .iPhoneXSMax,
        "iPhone11,6" : .iPhoneXSMax,
        "iPhone11,8" : .iPhoneXR,
        "iPhone12,1" : .iPhone11,
        "iPhone12,3" : .iPhone11Pro,
        "iPhone12,5" : .iPhone11ProMax,
        "iPhone12,8" : .iPhoneSE2,
        "iPhone13,1" : .iPhone12Mini,
        "iPhone13,2" : .iPhone12,
        "iPhone13,3" : .iPhone12Pro,
        "iPhone13,4" : .iPhone12ProMax,
    ]


}
