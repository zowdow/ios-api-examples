//
//  SuggestionData.swift
//  Prototype
//
//  Created by Xu Zhong on 2/14/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

struct SuggestionData {
    var suggestion: String
    var queryFragment: String
    var cards: [CardData]?
    var rank: Int
    var suggestionId: Int
    var meta: MetaData
    
    init(json: JSON, meta: MetaData, cards: [CardData]) {
        self.suggestion = json["suggestion"] as? String ?? ""
        self.queryFragment = json["queryFragment"] as? String ?? ""
        self.rank = json["suggRank"] as? Int ?? 0
        self.suggestionId = json["id"] as? Int ?? 0

        self.meta = meta
        self.cards = cards
    }
}
