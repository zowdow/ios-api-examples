//
//  CollectionViewCell.swift
//  API-SampleApp
//
//  Created by Xu Zhong on 2/22/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit

class CollectionViewCell : UICollectionViewCell {
    private var imageView: UIImageView?
    private var task: URLSessionDataTask?
    
    private func setImage(image: UIImage) {
        if self.imageView == nil {
            self.imageView = UIImageView(frame: self.bounds)
            guard let imageView = self.imageView else {
                fatalError()
            }
            imageView.layer.borderColor = UIColor.black.cgColor
            imageView.layer.borderWidth = 1
            self.contentView.addSubview(imageView)
        }

        self.imageView!.image = image
    }
    
    func loadImage(url: URL) {
        if let activeTask = self.task {
            activeTask.cancel()
        }
        
        self.task = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.setImage(image: image)
                }
            } else if let error = error {
                print("!!! \(error.localizedDescription)")
            }
        })
        self.task!.resume()
    }
}

