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
    
    func search(for text: String, completion: @escaping (_ response: Array<SuggestionData>?) -> Void) {
        if (text.characters.count > 0) {
            var params = APIParameters.sharedInstance.params
            params.updateValue(text, forKey: "q")
            params.updateValue(NSNumber(value: 1), forKey: "tracking")
            let urlRequest = request(with: text, parameters: params as Dictionary<String, AnyObject>)?.copy() as! URLRequest
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
    
    func request(with query: String?, parameters: Dictionary<String, AnyObject>) -> NSMutableURLRequest? {
        assert(query != nil)
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
    
    func decodeAndValidateJSON(data: Data) -> Dictionary<String, AnyObject>? {
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
    
    func parseData(data: Dictionary<String, AnyObject>) -> Array<SuggestionData>? {
        if (data.count == 0) {
            return nil
        }
        
        var parsedResponseData: Array<SuggestionData>?
        autoreleasepool {
            let meta = data[zowdowAPIResponseMetaKey]
            let rid = meta?["rid"] as! String
            let ttl = (meta?["ttl"] as! NSNumber) as Int
            var latitude: Float?
            var longitude: Float?
            if let latitudeString = meta?["latitude"] as? String {
                latitude = Float(latitudeString)
            }
            if let longitudeString = meta?["longitude"] as? String {
                longitude = Float(longitudeString)
            }
            parsedResponseData = parseSuggestions(responseObjects: data[zowdowAPIResponseRecordsKey] as! Array<AnyObject>, rid: rid, ttl: ttl, latitude: latitude, longitude: longitude)
        }
        return parsedResponseData
    }
    
    func parseSuggestions(responseObjects: Array<AnyObject>, rid: String, ttl: Int, latitude: Float?, longitude: Float?) -> Array<SuggestionData>? {
        var suggestions: Array<SuggestionData> = Array()
        if (responseObjects.count > 0) {
            for (_, querySuggestionInfo) in responseObjects.enumerated() {
                if let querySuggestionInfo = querySuggestionInfo as? Dictionary<String, AnyObject> {
                    let suggestion = querySuggestionInfo["suggestion"] as! Dictionary<String, AnyObject>
                    let suggestionData = SuggestionData(json: suggestion)
                    suggestionData.rid = rid;
                    suggestionData.ttl = ttl;
                    suggestionData.latitude = latitude
                    suggestionData.longitude = longitude
                    
                    var cards: Array<CardData> = Array()
                    if let responseCards = suggestion["cards"] as? Array<AnyObject> {
                        for (_, queryCardInfo) in responseCards.enumerated() {
                            let cardData = CardData(json: queryCardInfo as! Dictionary<String, AnyObject>)
                            cardData.rid = rid
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
