//
//  CardData.swift
//  Prototype
//
//  Created by Xu Zhong on 2/14/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

class CardData {
    var cardID: String
    var url: URL
    var height: Float
    var width: Float
    var rid: String
    var card_format: String
    var cardRank: NSNumber
    var actionurl: URL?
    var clickurl: URL?
    var impressionurl: URL?
    
    init() {
        cardID = ""
        url = URL(string: "")!
        height = 0.0
        width = 0.0
        rid = ""
        card_format = ""
        cardRank = NSNumber()
    }
    
    init(json: Dictionary<String, AnyObject>) {
        cardID = json["id"] as! String
        url = URL.init(string: json["x3"] as! String)!
        height = (json["x3_h"] as! NSNumber).floatValue
        width = (json["x3_w"] as! NSNumber).floatValue
        rid = ""
        card_format = json["card_format"] as! String
        cardRank = json["cardRank"] as! NSNumber
        if let actions = json["actions"] as? Array<Dictionary<String, AnyObject>> {
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
