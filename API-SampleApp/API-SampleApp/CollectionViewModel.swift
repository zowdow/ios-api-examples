//
//  CollectionViewController.swift
//  API-SampleApp
//
//  Created by Xu Zhong on 2/22/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

protocol CollectionViewCardClickDelegate {
    func onCardClick(sender: CollectionViewModel, url: URL)
}

class CollectionViewModel: NSObject {
    var model: SuggestionData?
    var delegate: CollectionViewCardClickDelegate?
}

extension CollectionViewModel: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = model, let cards = model.cards else { return 0 }
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        guard let model = model, let cards = model.cards else {
            return cell
        }
        let cardData = cards[indexPath.row]
        cell.loadImage(url: cardData.url)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let model = model, let cards = model.cards else {
            return
        }
        let cardData = cards[indexPath.row]
        if cardData.impressionurl != nil {
            cardData.trackImpression()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let model = model else { return }
        guard let cards = model.cards else { return }
        let cardData = cards[indexPath.row]
        guard let url = cardData.actionurl else { return }
        delegate?.onCardClick(sender: self, url: url)
        
        if cardData.clickurl != nil {
            cardData.trackClick()
        }
    }
}
