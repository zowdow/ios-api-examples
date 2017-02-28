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
import CoreTelephony

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
    let timezone: String = NSTimeZone.local.abbreviation() ?? "UTC"
    let app_ver: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    let app_build: String = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? ""
    let screen_scale: CGFloat = UIScreen.main.scale
    let system_ver: String = UIDevice.current.systemVersion
    var device_model: String {
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    func getNetworkType() -> String {
        let reachability:Reachability = Reachability.init()!
        do{
            try reachability.startNotifier()
            let status = reachability.currentReachabilityStatus
            if(status == Reachability.NetworkStatus.notReachable) {
                return ""
            } else if (status == Reachability.NetworkStatus.reachableViaWiFi) {
                return "wifi"
            } else if (status == Reachability.NetworkStatus.reachableViaWWAN) {
                let networkInfo = CTTelephonyNetworkInfo()
                let carrierType = networkInfo.currentRadioAccessTechnology
                switch carrierType {
                case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?: return "2g"
                case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?: return "3g"
                case CTRadioAccessTechnologyLTE?: return "4g"
                default: return ""
                }
            } else {
                return ""
            }
        } catch {
            return ""
        }
    }
    
    var params: [String: Any] {
        return [
            "app_id" : "com.zowdow.android.example",
            "device_id" : device_id,
            "lat" : lat,
            "long" : long,
            "location_accuracy" : location_accuracy,
            "locale" : locale,
            "timezone" : timezone,
            "os" : "ios",
            "app_ver" : app_ver,
            "app_build" : app_build,
            "screen_scale" : screen_scale,
            "system_ver" : system_ver,
            "device_model" : device_model,
            "network" : getNetworkType(),
            "card_format" : "inline",
            "s_limit" : 10,
            "c_limit" : 10,
            "tracking" : 1
        ]
    }
    
}
