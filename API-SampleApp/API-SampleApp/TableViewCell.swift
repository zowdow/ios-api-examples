//
//  TableViewCell.swift
//  Prototype
//
//  Created by Xu Zhong on 2/16/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    private let collectionModel = CollectionViewModel()

    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    func prepareForUse(rowData: SuggestionData, clickDelegate: CollectionViewCardClickDelegate) {
        self.collectionModel.model = rowData
        self.collectionModel.delegate = clickDelegate
        
        self.suggestionLabel.text = rowData.suggestion
        
        self.collectionView.dataSource = collectionModel
        self.collectionView.delegate = collectionModel
        self.collectionView.reloadData()
    }
}
