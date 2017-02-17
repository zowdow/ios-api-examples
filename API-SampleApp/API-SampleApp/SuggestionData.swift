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
    var cards: Array<CardData>?
    var rank: NSNumber
    var suggestionId: String
    var rid: String
    var ttl: Int
    var latitude: Float?
    var longitude: Float?
    
    init() {
        suggestion = ""
        queryFragment = ""
        rank = NSNumber()
        suggestionId = ""
        rid = ""
        ttl = 0
    }
    
    init(json: Dictionary<String, AnyObject>) {
        suggestion = json["suggestion"] as! String
        queryFragment = json["queryFragment"] as! String
        rank = json["suggRank"] as! NSNumber
        suggestionId = (json["id"] as! NSNumber).stringValue
        rid = ""
        ttl = 0
    }
}
