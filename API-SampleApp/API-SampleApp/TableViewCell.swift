//
//  TableViewCell.swift
//  Prototype
//
//  Created by Xu Zhong on 2/16/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

protocol CollectionViewDidScrollDelegate {
    func onCollectionViewScroll(sender: TableViewCell)
}

class TableViewCell: UITableViewCell {
    private let collectionModel = CollectionViewModel()
    var delegate: CollectionViewDidScrollDelegate?
    var cards: [CardData]?

    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    func prepareForUse(rowData: SuggestionData, clickDelegate: CollectionViewCardClickDelegate) {
        self.collectionModel.model = rowData
        self.collectionModel.delegate = clickDelegate
        self.cards = rowData.cards
        
        self.suggestionLabel.text = rowData.suggestion
        
        self.collectionView.dataSource = collectionModel
        self.collectionView.delegate = collectionModel
        self.collectionView.delegate = self
        self.collectionView.reloadData()
    }
    
    func visibleCardsIndex() -> [Int] {
        var index: [Int] = []
        for cell in self.collectionView.visibleCells {
            if visible(midX: cell.frame.midX) {
                index.append((self.collectionView.indexPath(for: cell)?.row)!)
            }
        }
        return index
    }
    
    private func visible(midX: CGFloat) -> Bool {
        return midX >= self.collectionView.contentOffset.x && midX <= self.collectionView.contentOffset.x + self.collectionView.frame.width
    }
}

extension TableViewCell: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.onCollectionViewScroll(sender: self)
    }
}
