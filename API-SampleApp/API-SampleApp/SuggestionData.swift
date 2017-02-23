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
    
    init() {
        suggestion = ""
        queryFragment = ""
        rank = 0
        suggestionId = 0
        rid = ""
        ttl = 0
    }
    
    init(json: [String: AnyObject]) {
        suggestion = json["suggestion"] as! String
        queryFragment = json["queryFragment"] as! String
        rank = json["suggRank"] as! Int
        suggestionId = json["id"] as! Int
        rid = ""
        ttl = 0
    }
}
