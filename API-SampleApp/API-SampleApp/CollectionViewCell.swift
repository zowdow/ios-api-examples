//
//  CollectionViewCell.swift
//  API-SampleApp
//
//  Created by Xu Zhong on 2/22/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

class CollectionViewCell : UICollectionViewCell {
    var url: URL?
    
    func load() {
        do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data)
            let imageView = UIImageView()
            imageView.image = image
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.black.cgColor
            self.backgroundView = imageView
        }
        catch {}
    }
}

