//
//  CollectionViewController.swift
//  API-SampleApp
//
//  Created by Xu Zhong on 2/22/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit
import SafariServices

class CollectionViewController: UIViewController {
    var model: SuggestionData?
}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let model = model else { return 0 }
        guard let cards = model.cards else { return 0 }
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        guard let model = model else { return cell }
        guard let cards = model.cards else { return cell }
        let cardData = cards[indexPath.row]
        cell.url = cardData.url
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CollectionViewCell
        cell.load()
        
        guard let model = model else { return }
        guard let cards = model.cards else { return }
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
        if #available(iOS 9.0, *) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        if cardData.clickurl != nil {
            cardData.trackClick()
        }
    }
}
