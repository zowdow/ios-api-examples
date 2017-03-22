//
//  CardData.swift
//  Prototype
//
//  Created by Xu Zhong on 2/14/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

struct CardData: Hashable {
    var cardID: String
    var url: URL
    var height: Float
    var width: Float
    var card_format: String
    var cardRank: Int
    var actionurl: URL?
    var clickurl: URL?
    var impressionurl: URL?
    
    var hashValue: Int {
        return self.cardID.hashValue ^ self.url.hashValue ^ (self.impressionurl ?? URL(string: "")!).hashValue
    }
    
    static func == (lhs: CardData, rhs: CardData) -> Bool {
        return lhs.cardID == rhs.cardID && lhs.url == rhs.url && lhs.impressionurl == rhs.impressionurl
    }
    
    init(json: JSON) {
        cardID = json["id"] as! String
        url = URL(string: json["x3"] as! String)!
        height = json["x3_h"] as! Float
        width = json["x3_w"] as! Float
        card_format = json["card_format"] as! String
        cardRank = json["cardRank"] as! Int
        if let actions = json["actions"] as? [JSON] {
            actionurl = URL(string: actions[0]["action_target"] as! String)
        }
        clickurl = URL(string: json["card_click_url"] as! String)
        impressionurl = URL(string: json["card_impression_url"] as! String)
    }
    
    func trackClick() {
        guard let clickurl = self.clickurl else {
            return
        }
        URLSession.shared.dataTask(with: clickurl).resume()
    }
    
    func trackImpression() {
        guard let impressionurl = self.impressionurl else {
            return
        }
        URLSession.shared.dataTask(with: impressionurl).resume()
    }
}
