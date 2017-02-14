//
//  APIParameters.swift
//  Prototype
//
//  Created by Xu Zhong on 1/20/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit
import AdSupport
import SystemConfiguration
import CoreLocation

enum CardFormat: String {
    case inline = "inline"
    case stamp = "stamp"
    case ticket = "ticket"
}

enum NetworkType: String {
    case WiFi = "WiFi"
    case Cellular = "Cellular"
    case None = "None"
}

class APIParameters {
    class var sharedInstance : APIParameters {
        struct Static {
            static let instance : APIParameters = APIParameters()
        }
        return Static.instance
    }
    
    let app_id: String = Bundle.main.bundleIdentifier!
    var q: String = ""
    let device_id: String = ASIdentifierManager.shared().isAdvertisingTrackingEnabled ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : (UIDevice.current.identifierForVendor?.uuidString)!
    
    var deviceLocation: CLLocation? {
        didSet {
            lat = CGFloat((deviceLocation?.coordinate.latitude)!)
            long = CGFloat((deviceLocation?.coordinate.longitude)!)
            location_accuracy = CGFloat((deviceLocation?.horizontalAccuracy)!)
        }
    }
    var lat: CGFloat = 0.0
    var long: CGFloat = 0.0
    var location_accuracy: CGFloat = 0.0
    let locale: String = NSLocale.current.identifier
    let timezone: String = NSTimeZone.local.abbreviation()!
    
    let os: String = "iOS"
    let app_ver: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let app_build: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    let screen_scale: CGFloat = UIScreen.main.scale
    let system_ver: String = UIDevice.current.systemVersion
    var device_model: String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    var network: String {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return NetworkType.None.rawValue
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return NetworkType.None.rawValue
        }
        
        if flags.contains(.reachable) == false {
            return NetworkType.None.rawValue
        }
        else if flags.contains(.isWWAN) == true {
            return NetworkType.Cellular.rawValue
        }
        else if flags.contains(.connectionRequired) == false {
            return NetworkType.WiFi.rawValue
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            return NetworkType.WiFi.rawValue
        }
        else {
            return NetworkType.None.rawValue
        }
    }
    
    var card_format: String = CardFormat.inline.rawValue
    var s_limit: Int = 10
    var c_limit: Int = 10
    
    var params: [String: Any] {
        return [
            "app_id" : app_id,
            "q" : q,
            "device_id" : device_id,
            "lat" : NSNumber(value: Float(lat)),
            "long" : NSNumber(value: Float(long)),
            "location_accuracy" : NSNumber(value: Float(location_accuracy)),
            "locale" : locale,
            "timezone" : timezone,
            "os" : os,
            "app_ver" : app_ver,
            "app_build" : app_build,
            "screen_scale" : NSNumber(value: Float(screen_scale)),
            "system_ver" : system_ver,
            "device_model" : device_model,
            "network" : network,
            "card_format" : card_format,
            "s_limit" : NSNumber(value: s_limit),
            "c_limit" : NSNumber(value: c_limit),
            "tracking" : NSNumber(value: 1)
        ]
    }
}
