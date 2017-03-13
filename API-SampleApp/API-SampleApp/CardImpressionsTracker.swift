//
//  CardImpressionsTracker.swift
//  API-SampleApp
//
//  Created by Paul Dmitryev on 13.03.17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

class CardImpressionsTracker {
    private var cardInfos: [String: CardImpressionInfo] = [:]
    
    func setNewCardsData(cards: [CardData]) {
        let currentCardIds = Set(cardInfos.keys)
        let newCardIds = Set(cards.map {$0.cardID})
        
        for deleteId in currentCardIds.subtracting(newCardIds) {
            cardInfos.removeValue(forKey: deleteId)?.cardHidden()
        }
        
        for newCard in cards {
            if self.cardInfos.index(forKey: newCard.cardID) != nil {
                continue
            }
            self.cardInfos[newCard.cardID] = CardImpressionInfo(cardId: newCard.cardID, trackURL: newCard.impressionurl)
        }
    }
    
    func cardShown(cardId: String) {
        guard let card = self.cardInfos[cardId] else {
            print("! Warning, card \(cardId) not found")
            return
        }
        card.cardShown()
    }
    
    func cardHidden(cardId: String) {
        guard let card = self.cardInfos[cardId] else {
            print("! Warning, card \(cardId) not found")
            return
        }
        card.cardHidden()
    }
}
