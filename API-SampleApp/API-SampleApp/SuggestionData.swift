//
//  SuggestionData.swift
//  Prototype
//
//  Created by Xu Zhong on 2/14/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

class SuggestionData {
    var suggestion: String
    var queryFragment: String
    var cards: [CardData]?
    var rank: Int
    var suggestionId: Int
    var rid: String
    var ttl: Int
    var latitude: Float?
    var longitude: Float?
    
    init(json: [String: AnyObject]) {
        suggestion = json["suggestion"] as! String
        queryFragment = json["queryFragment"] as! String
        rank = json["suggRank"] as! Int
        suggestionId = json["id"] as! Int
        rid = json["rid"] as! String
        ttl = json["ttl"] as! Int
        latitude = json["lat"] as? Float
        longitude = json["long"] as? Float
    }
}
