//
//  SubscriptionResponse.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation

struct QuoteResponse {
    var responseBody: String
    
    var quoteTicks: [QuoteTick]? {
        
        guard let responseData = responseBody.data(using: .utf8)
            else {
                print("Response Parse Error. Conversion to data failed")
                return nil
        }
        do {
            let responseDict = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]
            if let rootDict = responseDict {
                return parseQuoteTicks(rootDict)
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    private func parseQuoteTicks(_ rootDict: [String: Any]) -> [QuoteTick]? {
        var updatedQuoteTicks:[QuoteTick] = []
        var subscribedList:[String:Any] = [:]
        
        if let _ = rootDict["subscribed_count"] as? Int {
            guard let list = rootDict["subscribed_list"] as? [String: Any]
                else {
                    print("Response Parse Error. subscribed_list missed")
                    return nil
            }
            subscribedList = list
        } else {
            subscribedList = rootDict
        }
        
        guard let ticks = subscribedList["ticks"] as? [Dictionary<String, Any>]  else {
            print("Response Parse Error. ticks missed")
            return nil
        }
        for tick in ticks  {
            guard let symbol = tick["s"] as? String else { print("Response Parse Error. symbol missed"); continue }
            guard let quote = Quote(rawValue: symbol) else { print("Response Parse Error. Unsupported quote:\(symbol)"); continue }
            guard let bid = tick["b"] as? String else { print("Response Parse Error. bid missed"); continue }
            guard let ask = tick["a"] as? String else { print("Response Parse Error. ask missed"); continue }
            guard let spread = tick["spr"] as? String else { print("Response Parse Error. spr missed"); continue }
            
            let quoteTick = QuoteTick(quote: quote, bid: bid, ask: ask, spread: spread)
            updatedQuoteTicks.append(quoteTick)
        }
        return updatedQuoteTicks.count > 0 ? updatedQuoteTicks : nil
    }
}
