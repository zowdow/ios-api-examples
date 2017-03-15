//
//  TableViewCell.swift
//  Prototype
//
//  Created by Xu Zhong on 2/16/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

protocol CardCollectionViewDelegate {
    func onCollectionViewScroll(sender: TableViewCell, visibleCardIds: Set<String>)
    func onCardClick(url: URL)
}

class TableViewCell: UITableViewCell {
    private let collectionModel = CollectionViewModel()
    fileprivate var visibleCards = Set<String>()
    fileprivate var delegate: CardCollectionViewDelegate?
    
    var cards: [CardData]?

    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    func prepareForUse(rowData: SuggestionData, delegate: CardCollectionViewDelegate) {
        self.delegate = delegate
        self.cards = rowData.cards
        self.collectionModel.model = self.cards
        
        self.suggestionLabel.text = rowData.suggestion
        
        self.collectionView.dataSource = collectionModel
        self.collectionView.delegate = self
        self.collectionView.reloadData()
    }
    
    var visibleCardIds: Set<String> {
        // if we don't have items in self.visibleCards, then user didn't scroll cell, so we can determine necessary data by geometric calculations
        if self.visibleCards.count == 0 {
            let firstItem = IndexPath(row: 0, section: 0)
            if let cellAttributes = self.collectionView.layoutAttributesForItem(at: firstItem), let cards = self.cards {
                let cellSize = cellAttributes.size
                let visibleCardsCount = Int(ceil(self.frame.width / cellSize.width))
                for index in 0..<min(visibleCardsCount, cards.count) {
                    self.visibleCards.insert(cards[index].cardID)
                }
                return self.visibleCards
            } else {
                return Set<String>()
            }
        } else {
            return self.visibleCards
        }
    }
    
    fileprivate func visible(midX: CGFloat) -> Bool {
        return midX >= self.collectionView.contentOffset.x && midX <= self.collectionView.contentOffset.x + self.collectionView.frame.width
    }
}

extension TableViewCell: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let cards = self.cards else {
            return
        }
        
        self.visibleCards.removeAll()
        for cell in self.collectionView.visibleCells {
            if visible(midX: cell.frame.midX), let indexPath = self.collectionView.indexPath(for: cell) {
                self.visibleCards.insert(cards[indexPath.row].cardID)
            }
        }
        delegate?.onCollectionViewScroll(sender: self, visibleCardIds: self.visibleCards)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cardData = self.cards?[indexPath.row] else {
            return
        }
        
        cardData.trackClick()
        if let url = cardData.actionurl {
            delegate?.onCardClick(url: url)
        }
    }
}
