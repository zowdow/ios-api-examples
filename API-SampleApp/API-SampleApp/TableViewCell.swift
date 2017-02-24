//
//  TableViewCell.swift
//  Prototype
//
//  Created by Xu Zhong on 2/16/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    let collectionModel = CollectionViewModel()

    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    func setSuggestionData(data: SuggestionData) {
        self.collectionModel.model = data
        self.suggestionLabel.text = data.suggestion
        
        self.collectionView.dataSource = collectionModel
        self.collectionView.delegate = collectionModel
        self.collectionView.reloadData()
    }
}
