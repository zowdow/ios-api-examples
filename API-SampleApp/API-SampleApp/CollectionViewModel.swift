//
//  CollectionViewController.swift
//  API-SampleApp
//
//  Created by Xu Zhong on 2/22/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

class CollectionViewModel: NSObject, UICollectionViewDataSource {
    var model: [CardData]?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let cards = self.model else {
            return 0
        }
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        guard let cards = self.model else {
            return cell
        }
        let cardData = cards[indexPath.row]
        cell.loadImage(url: cardData.url)
        return cell
    }
}
