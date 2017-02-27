//
//  MetaData.swift
//  API-SampleApp
//
//  Created by Paul Dmitryev on 27.02.17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

struct MetaData {
    var rid: String
    var ttl: Int
    var latitude: Float
    var longitude: Float
    
    init(json: JSON) {
        self.latitude = 0.0
        self.longitude = 0.0
        self.rid = json["rid"] as? String ?? ""
        self.ttl = json["ttl"] as? Int ?? 0
        if let latitudeString = json["latitude"] as? String,
            let latitude = Float(latitudeString) {
            self.latitude = latitude
        }
        
        if let longitudeString = json["longitude"] as? String,
            let longitude = Float(longitudeString) {
            self.longitude = longitude
        }
    }
}
