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
    
    let collectionViewSpace: CGFloat = 8
    let collectionViewCellSpace: CGFloat = 10.0
    var collectionViewWidth: CGFloat = 0
    
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
        
        collectionViewWidth = tableView.frame.width - 2 * collectionViewSpace
    }
    
    func trackSuggestion(data: [CardData], visibleCards: Set<String>) {
        for card in data {
            if visibleCards.contains(card.cardID) {
                self.impressionsTracker.cardShown(cardId: card.cardID)
            } else {
                self.impressionsTracker.cardHidden(cardId: card.cardID)
            }
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
        var visibleColumns = Int(floor(self.tableView.frame.width / self.cellWidth))
        if (self.collectionViewWidth - CGFloat(visibleColumns) * (self.cellWidth + self.collectionViewCellSpace) >= self.cellWidth/2) {
            visibleColumns += 1;
        }
        
        for (rowNum, suggestion) in suggesions.enumerated() {
            if let cards = suggestion.cards {
                for (columnNum, card) in cards.enumerated() {
                    allCards.append(card)
                    if columnNum < visibleColumns && rowNum < visibleRows {
                        visibleIds.append(card.cardID)
                    } else {
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
        cell.prepareForUse(rowData: model[indexPath.row], delegate: self)
        return cell
    }
}

extension RootViewController: UITableViewDelegate {
    private func visible(midY: CGFloat) -> Bool {
        return midY >= self.tableView.contentOffset.x && midY <= self.tableView.contentOffset.x + self.tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        for row in self.tableView.visibleCells {
            if let cell = row as? TableViewCell, let cards = cell.cards {
                let visibleItems: Set<String>
                if self.visible(midY: cell.frame.midY) {
                    visibleItems = cell.visibleCardIds
                } else {
                    visibleItems = Set<String>()
                }
                self.trackSuggestion(data: cards, visibleCards: visibleItems)
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

extension RootViewController: CardCollectionViewDelegate {
    func onCardClick(url: URL) {
        if #available(iOS 9.0, *) {
            let vc = SFSafariViewController(url: url)
            self.present(vc, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(url)
        }
    }

    func onCollectionViewScroll(sender: TableViewCell, visibleCardIds: Set<String>) {
        if let cards = sender.cards {
            self.trackSuggestion(data: cards, visibleCards: sender.visibleCardIds)
        }
    }
}
