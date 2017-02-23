//
//  Dictionary+URLEncode.swift
//  API-SampleApp
//
//  Created by Xu Zhong on 2/22/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

extension Dictionary {
    func urlEncodedString() -> String {
        let parts = NSMutableArray()
        for (key, value) in self {
            let part = String(format: "%@=%@", urlEncode(object: key), urlEncode(object: value))
            parts.add(part)
        }
        return parts.componentsJoined(by: "&")
    }
    
    func toString(object: Any) -> String {
        return String(describing: object)
    }
    
    func urlEncode(object: Any) -> String {
        return toString(object: object).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}

