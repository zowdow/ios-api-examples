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
    let zowdowAPIBaseURLInit = "https://i1.quick1y.com/v5/init"
    let zowdowAPIBaseURLUnified = "https://u1.quick1y.com/v1/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        
        
        
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func callInitAPI() {
        let fullURL = NSURLComponents(string: zowdowAPIBaseURLInit)
        fullURL?.query = APIParameters.sharedInstance.params.urlEncodedString()
        let requestURL = fullURL?.url
        let dataTask = URLSession.shared.dataTask(with: requestURL!) { (data, response, error) in
            if let data = data {
                
            } else {
                if let error = error {
                    var errorURL = ""
                    if let response = response {
                        errorURL = (response.url?.absoluteString)!
                    } else {
                        errorURL = "URL unknown"
                    }
                    //track error
                }
            }
        }
        dataTask.resume()
    }
    
    func doSearch(for text: String) {
        
    }
    
    func request(with query: String, parameters: NSMutableDictionary, error: Error) -> NSMutableURLRequest {
        return NSMutableURLRequest(url: URL(string: "http://u1.quick1y.com/v1/unified?q=piz&app_id=com.searchmaster.searchapp")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func optionsCallback() {
        if let text = searchBar.text {
            self.doSearch(for: text)
        }
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(200)
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
        for key in self {
            let value = ((self as Any) as AnyObject).object(forKey: key)
            let part = String(format: "%@=%@", urlEncode(object: key), urlEncode(object: value as Any))
            parts.add(part)
        }
        return parts.componentsJoined(by: "&")
    }
    
    func toString(object: Any) -> String {
        return String(format: "%@", object as! CVarArg)
    }
    
    func urlEncode(object: Any) -> String {
        return toString(object: object).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}
