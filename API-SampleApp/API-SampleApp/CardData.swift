//
//  CardData.swift
//  Prototype
//
//  Created by Xu Zhong on 2/14/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

struct CardData {
    var cardID: String
    var url: URL
    var height: Float
    var width: Float
    var card_format: String
    var cardRank: Int
    var actionurl: URL?
    var clickurl: URL?
    var impressionurl: URL?
    
    init(json: JSON) {
        cardID = json["id"] as! String
        url = URL(string: json["x3"] as! String)!
        height = json["x3_h"] as! Float
        width = json["x3_w"] as! Float
        card_format = json["card_format"] as! String
        cardRank = json["cardRank"] as! Int
        if let actions = json["actions"] as? [[String: AnyObject]] {
            actionurl = URL(string: actions[0]["action_target"] as! String)
        }
        clickurl = URL(string: json["card_click_url"] as! String)
        impressionurl = URL(string: json["card_impression_url"] as! String)
    }
    
    func trackClick() {
        URLSession.shared.dataTask(with: clickurl!)
    }
    
    func trackImpression() {
        URLSession.shared.dataTask(with: impressionurl!)
    }
}
