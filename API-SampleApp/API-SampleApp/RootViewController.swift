//
//  RootViewController.swift
//  Prototype
//
//  Created by Xu Zhong on 1/20/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices

class RootViewController: UIViewController {
    let rowHeight: CGFloat = 80
    let cellWidth: CGFloat = 160
    
    let locationManager = CLLocationManager()
    let impressionsTracker = CardImpressionsTracker()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var loader: SuggestionLoader?
    var model: [SuggestionData]?
    
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
    
    func trackNewItems(suggestions: [SuggestionData]?) {
        guard let suggesions = suggestions else {
            return
        }
        var allCards: [CardData] = []
        var visibleIds: [String] = []
        var invisibleIds: [String] = []
        
        let visibleRows = Int(self.tableView.frame.height / self.rowHeight)
        
        for (rowNum, suggestion) in suggesions.enumerated() {
            if let cards = suggestion.cards {
                if rowNum < visibleRows {
                    let cell = self.tableView.cellForRow(at: IndexPath.init(row: rowNum, section: 0)) as! TableViewCell
                    for (columnNum, card) in cards.enumerated() {
                        allCards.append(card)
                        if (cell.visibleCardsIndex().contains(columnNum)) {
                            visibleIds.append(card.cardID)
                        } else {
                            invisibleIds.append(card.cardID)
                        }
                    }
                } else {
                    for card in cards {
                        allCards.append(card)
                        invisibleIds.append(card.cardID)
                    }
                }
            }
        }
        
        self.impressionsTracker.setNewCardsData(cards: allCards)
        visibleIds.forEach{self.impressionsTracker.cardShown(cardId: $0)}
        invisibleIds.forEach{self.impressionsTracker.cardHidden(cardId: $0)}
    }
    
    func doSearch(for text: String) {
        self.model = []
        self.tableView.reloadData()
        activityIndicator.startAnimating()
        
        loader?.search(for: text, completion: { response in
            self.model = response
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
                self.trackNewItems(suggestions: response)
            }
        })
    }

}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CarouselCell", for: indexPath) as! TableViewCell
        guard let model = model else {
            return cell
        }
        cell.prepareForUse(rowData: model[indexPath.row], clickDelegate: self)
        cell.delegate = self
        return cell
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
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

extension RootViewController: CollectionViewCardClickDelegate {
    func onCardClick(sender: CollectionViewModel, url: URL) {
        if #available(iOS 9.0, *) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }
}

extension RootViewController: CollectionViewDidScrollDelegate {
    func onCollectionViewScroll(sender: TableViewCell) {
        if let cards = sender.cards {
            for index in 0..<cards.count {
                if sender.visibleCardsIndex().contains(index) {
                    self.impressionsTracker.cardShown(cardId: cards[index].cardID)
                }
                else {
                    self.impressionsTracker.cardHidden(cardId: cards[index].cardID)
                }
            }
        }
    }
}
