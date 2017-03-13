//
//  CardImpressionInfo.swift
//  API-SampleApp
//
//  Created by Paul Dmitryev on 13.03.17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

class CardImpressionInfo {
    private var timer: Timer?
    private var isTracked = false
    let trackURL: URL?
    let cardId: String
    
    init(cardId: String, trackURL: URL?) {
        self.cardId = cardId
        self.trackURL = trackURL
    }
    
    func cardShown() {
        if self.isTracked {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(doTrack), userInfo: nil, repeats: false)
    }
    
    func cardHidden() {
        if let timer = self.timer, timer.isValid {
            timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc func doTrack() {
        if self.isTracked {
            return
        }
        self.isTracked = true
        if let url = self.trackURL {
            URLSession.shared.dataTask(with: url).resume()
        }
    }
}
