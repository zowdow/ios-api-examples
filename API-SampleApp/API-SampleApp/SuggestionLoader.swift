//
//  SuggestionLoader.swift
//  Prototype
//
//  Created by Xu Zhong on 1/20/17.
//  Copyright © 2017 Zowdow, Inc. All rights reserved.
//

import Foundation

typealias JSON = [String: Any?]

class SuggestionLoader {
    private var task: URLSessionDataTask?
    
    let zowdowAPIBaseURLUnified = "https://u.zowdow.com/v1/unified?"
    let zowdowAPIResponseRecordsKey = "records"
    let zowdowAPIResponseMetaKey = "_meta"
    
    func search(for text: String, completion: @escaping (_ response: [SuggestionData]?) -> Void) {
        if let activeTask = self.task {
            activeTask.cancel()
        }
        guard text.characters.count != 0 else {
            completion([])
            return
        }
        
        var params = APIParameters.sharedInstance.params
        params["q"] = text
        guard let requestUrl = request(parameters: params.urlEncodedString()) else {
            return
        }
        self.task = URLSession.shared.dataTask(with: requestUrl, completionHandler: { (data, response, error) in
            if let data = data, let jsonData = self.decodeAndValidateJSON(data: data) {
                let resp = self.parseData(data: jsonData)
                return completion(resp)
            } else if let error = error as? NSError {
                if error.domain == NSURLErrorDomain && error.code != NSURLErrorCancelled {
                    print("! Error polling API \(error.localizedDescription)")
                }
            }
        })
        self.task!.resume()
    }
    
    func request(parameters: String) -> URL? {
        let baseURL = URL(string: zowdowAPIBaseURLUnified)
        if var fullURL = URLComponents(url: baseURL!, resolvingAgainstBaseURL: true) {
            fullURL.query = parameters
            return fullURL.url
        } else {
            return nil
        }
    }
    
    func decodeAndValidateJSON(data: Data) -> JSON? {
        guard let parsedData = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSON else {
            return nil
        }
        if parsedData.keys.contains(zowdowAPIResponseRecordsKey) && parsedData.keys.contains(zowdowAPIResponseMetaKey) {
            return parsedData
        }
        return nil
    }
    
    func parseData(data: JSON) -> [SuggestionData]? {
        if (data.count == 0) {
            return nil
        }
        
        let meta = data[zowdowAPIResponseMetaKey] as! JSON
        let parsedMeta = MetaData(json: meta)
        
        guard let suggestions = data[zowdowAPIResponseRecordsKey] as? [JSON] else {
            return nil
        }
        
        return parseSuggestions(suggestionsData: suggestions, metadata: parsedMeta)
    }
    
    func parseSuggestions(suggestionsData: [JSON], metadata: MetaData) -> [SuggestionData]? {
        var parsedSuggestions: [SuggestionData] = []
        for suggestion in suggestionsData {
            if let suggJson = suggestion["suggestion"] as? JSON {
                let cards: [CardData]
                if let cardsJSON = suggJson["cards"] as? [JSON] {
                    cards = self.parseCards(cardsData: cardsJSON)
                } else {
                    cards = []
                }
                let suggestionData = SuggestionData(json: suggJson, meta: metadata, cards: cards)
                parsedSuggestions.append(suggestionData)
            }
        }

        return parsedSuggestions
    }
    
    func parseCards(cardsData: [JSON]) -> [CardData] {
        return cardsData.map {(card: JSON)->CardData in
            return CardData(json: card)
        }
    }
}
