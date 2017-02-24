//
//  TableViewCell.swift
//  Prototype
//
//  Created by Xu Zhong on 2/16/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    let collectionVC = CollectionViewController()

    @IBOutlet weak var suggestionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    func setSuggestionData(data: SuggestionData) {
        self.collectionVC.model = data
        self.suggestionLabel.text = data.suggestion
        
        self.collectionView.dataSource = collectionVC
        self.collectionView.delegate = collectionVC
        self.collectionView.reloadData()
    }
}
