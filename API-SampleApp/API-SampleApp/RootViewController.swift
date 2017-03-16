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
    let rowCaptionHeight: CGFloat = 20
    let collectionViewCellWidth: CGFloat = 160
    let collectionViewSpace: CGFloat = 8
    let collectionViewCellSpace: CGFloat = 10.0
    var collectionViewWidth: CGFloat = 0
    
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
        var visibility: [CardData: Bool] = [:]
        
        // if there is more then 50% of collection view visible, we need to count this row as visible
        let additionalRow = (self.tableView.frame.height.truncatingRemainder(dividingBy: self.rowHeight)) > (self.rowHeight - self.rowCaptionHeight) / 2 ? 1 : 0
        let visibleRows = Int(floor(self.tableView.frame.height / self.rowHeight)) + additionalRow
        
        let visibleColumns = Int(round(self.collectionViewWidth / (self.collectionViewCellWidth + self.collectionViewCellSpace)))
        
        for (rowNum, suggestion) in suggesions.enumerated() {
            if let cards = suggestion.cards {
                for (columnNum, card) in cards.enumerated() {
                    visibility[card] = columnNum < visibleColumns && rowNum < visibleRows
                }
            }
        }
        
        self.impressionsTracker.setNewCardsData(cards: Array(visibility.keys))
        for (card, visible) in visibility {
            if visible {
                self.impressionsTracker.cardShown(cardId: card.cardID)
            } else {
                self.impressionsTracker.cardHidden(cardId: card.cardID)
            }
        }
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
