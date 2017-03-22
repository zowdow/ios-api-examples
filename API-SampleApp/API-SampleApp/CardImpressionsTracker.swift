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
    
    /// Call this method on new data receiving
    ///
    /// - Parameter cards: list of card data, obtained from server
    func setNewCardsData(cards: [CardData]) {
        let currentCardIds = Set(cardInfos.keys)
        let newCardIds = Set(cards.map {$0.cardID})
        
        // we need to delete cards that are no longer present and call `cardHidden` for them to stop tracking time
        for deleteId in currentCardIds.subtracting(newCardIds) {
            cardInfos.removeValue(forKey: deleteId)?.cardHidden()
        }
        
        // create  CardImpressionInfo records for new cards, received with recent request
        for newCard in cards {
            if self.cardInfos.index(forKey: newCard.cardID) != nil {
                continue
            }
            self.cardInfos[newCard.cardID] = CardImpressionInfo(cardId: newCard.cardID, trackURL: newCard.impressionurl)
        }
    }
    
    
    /// Track card became visible, call if at least 50% of card is shown
    ///
    /// - Parameter cardId: id of appeared card
    func cardShown(cardId: String) {
        guard let card = self.cardInfos[cardId] else {
            print("! Warning, card \(cardId) not found")
            return
        }
        card.cardShown()
    }
    
    /// Track card became invisible, call if less then 50% of card is shown
    ///
    /// - Parameter cardId: id of disappeared card
    func cardHidden(cardId: String) {
        guard let card = self.cardInfos[cardId] else {
            print("! Warning, card \(cardId) not found")
            return
        }
        card.cardHidden()
    }
}
