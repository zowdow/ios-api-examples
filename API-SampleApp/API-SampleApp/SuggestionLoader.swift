//
//  SuggestionLoader.swift
//  Prototype
//
//  Created by Xu Zhong on 1/20/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

class SuggestionLoader {
    let zowdowAPIBaseURLUnified = "https://u.zowdow.com/v1/unified?"
    let zowdowAPIResponseRecordsKey = "records"
    let zowdowAPIResponseMetaKey = "_meta"
    
    func search(for text: String, completion: @escaping (_ response: [SuggestionData]?) -> Void) {
        if (text.characters.count > 0) {
            var params = APIParameters.sharedInstance.params
            params["q"] = text
            let urlRequest = request(parameters: params as [String: AnyObject])?.copy() as! URLRequest
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if (data != nil) {
                    if let jsonData = self.decodeAndValidateJSON(data: data!) {
                        let resp = self.parseData(data: jsonData)
                        return completion(resp)
                    }
                }
            }).resume()
        }
    }
    
    func request(parameters: [String: AnyObject]) -> NSMutableURLRequest? {
        let baseURL = URL(string: zowdowAPIBaseURLUnified)
        if var fullURL = URLComponents(url: baseURL!, resolvingAgainstBaseURL: true) {
            fullURL.query = parameters.urlEncodedString()
            let request = NSMutableURLRequest(url: fullURL.url!)
            request.httpMethod = "GET"
            return request
        }
        else {
            return nil
        }
    }
    
    func decodeAndValidateJSON(data: Data) -> [String: AnyObject]? {
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            if (parsedData.keys.contains(zowdowAPIResponseRecordsKey) && parsedData.keys.contains(zowdowAPIResponseMetaKey)) {
                return parsedData
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func parseData(data: [String: AnyObject]) -> [SuggestionData]? {
        if (data.count == 0) {
            return nil
        }
        
        var parsedResponseData: [SuggestionData]?
        autoreleasepool {
            let meta = data[zowdowAPIResponseMetaKey]
            let rid = meta?["rid"] as! String
            let ttl = meta?["ttl"] as! Int
            var latitude: Float?
            var longitude: Float?
            if let latitudeString = meta?["latitude"] as? String {
                latitude = Float(latitudeString)
            }
            if let longitudeString = meta?["longitude"] as? String {
                longitude = Float(longitudeString)
            }
            parsedResponseData = parseSuggestions(responseObjects: data[zowdowAPIResponseRecordsKey] as! [AnyObject], rid: rid, ttl: ttl, latitude: latitude, longitude: longitude)
        }
        return parsedResponseData
    }
    
    func parseSuggestions(responseObjects: [AnyObject], rid: String, ttl: Int, latitude: Float?, longitude: Float?) -> [SuggestionData]? {
        var suggestions: [SuggestionData] = []
        if (responseObjects.count > 0) {
            for querySuggestionInfo in responseObjects {
                if let querySuggestionInfo = querySuggestionInfo as? [String: AnyObject] {
                    var suggestion = querySuggestionInfo["suggestion"] as! [String: AnyObject]
                    suggestion["rid"] = rid as AnyObject?
                    suggestion["ttl"] = ttl as AnyObject?
                    suggestion["lat"] = latitude as AnyObject?
                    suggestion["long"] = longitude as AnyObject?
                    let suggestionData = SuggestionData(json: suggestion)
                    
                    var cards: [CardData] = []
                    if let responseCards = suggestion["cards"] as? [AnyObject] {
                        for queryCardInfo in responseCards {
                            var card = queryCardInfo as! [String: AnyObject]
                            card["rid"] = rid as AnyObject?
                            let cardData = CardData(json: card)
                            cards.append(cardData)
                        }
                    }
                    suggestionData.cards = cards
                    suggestions.append(suggestionData)
                }
            }
        }
        return suggestions
    }
}
