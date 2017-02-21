//
//  RootViewController.swift
//  Prototype
//
//  Created by Xu Zhong on 1/20/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit
import SafariServices
import CoreLocation

class RootViewController: UIViewController {
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var loader: SuggestionLoader?
    var model: Array<SuggestionData>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        loader = SuggestionLoader()
        
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func doSearch(for text: String) {
        loader?.search(for: text, completion: { (resp) in
            self.model = resp
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = model {
            return model.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarouselCell", for: indexPath) as? TableViewCell
        if let cell = cell {
            if let model = model {
                cell.suggestionLabel.text = model[indexPath.row].suggestion
            }
            cell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        }
        return cell!
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func escaping(fragment: String) -> String {
        let charactersToEscape = "!*'();@&=+$,/?%#[]\" "
        let customEncodingSet = CharacterSet(charactersIn: charactersToEscape).inverted
        return fragment.addingPercentEncoding(withAllowedCharacters: customEncodingSet)!
    }
}

extension RootViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let model = model {
            if let cards = model[collectionView.tag].cards {
                return cards.count
            }
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let model = model {
            if let cards = model[collectionView.tag].cards {
                do {
                    let cardData = cards[indexPath.row]
                    let data = try Data(contentsOf: cardData.url)
                    let image = UIImage(data: data)
                    let imageView = UIImageView()
                    imageView.image = image
                    imageView.layer.borderWidth = 1
                    imageView.layer.borderColor = UIColor.black.cgColor
                    cell.backgroundView = imageView
                    
                    if cardData.impressionurl != nil {
                        cardData.trackImpression()
                    }
                } catch {
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = model {
            if let cards = model[collectionView.tag].cards {
                let cardData = cards[indexPath.row]
                if let url = cardData.actionurl {
                    if #available(iOS 9.0, *) {
                        let vc = SFSafariViewController(url: url)
                        self.present(vc, animated: true, completion: nil)
                        
                        if cardData.clickurl != nil {
                            cardData.trackClick()
                        }
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
}

extension RootViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        doSearch(for: searchText)
    }
}

extension RootViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        APIParameters.sharedInstance.deviceLocation = manager.location
    }
}

extension Dictionary {
    func urlEncodedString() -> String {
        let parts = NSMutableArray()
        for (key, value) in self {
            let part = String(format: "%@=%@", urlEncode(object: key), urlEncode(object: value))
            parts.add(part)
        }
        return parts.componentsJoined(by: "&")
    }
    
    func toString(object: Any) -> String {
        return String(describing: object)
    }
    
    func urlEncode(object: Any) -> String {
        return toString(object: object).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
