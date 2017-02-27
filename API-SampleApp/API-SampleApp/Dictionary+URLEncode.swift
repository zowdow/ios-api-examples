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
        var parts: [String] = []
        for (key, value) in self {
            parts.append("\(urlEncode(object: key))=\(urlEncode(object: value))")
        }
        return parts.joined(separator: "&")
    }
    
    private func urlEncode(object: Any) -> String {
        return String(describing: object).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}

