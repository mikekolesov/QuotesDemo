//
//  Storage.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation

let activeQuotesKey: String = "activeQuotesKey"
let quoteTicksKey: String = "quoteTicksKey"

extension Notification.Name {
    public static let QuoteStorageDidUpdate = Notification.Name("QuoteStorageDidUpdate")
}

class QuoteStorage {
    
    // MARK: Quote model methods
    
    class var activeQuotes: [Quote] {
        get {
            print("activeQuotes == READ ===")
            if let activeStrings = UserDefaults.standard.array(forKey: activeQuotesKey) as? [String] {
                let activeQuote = activeStrings.map({ (rawString) -> Quote in
                    if let type = Quote(rawValue: rawString) {
                        return type
                    }
                    return Quote.EURUSD
                })
                return activeQuote
            } else {
                return Quote.all
            }
        }
        set {
            print("activeQuotesKey == WRITE ===")
            let converted = newValue.map { $0.rawValue }
            UserDefaults.standard.set(converted, forKey: activeQuotesKey)
        }
    }
    
    class func addActiveQuotes(_ quotes: [Quote]) {
        var currentActiveQuotes = QuoteStorage.activeQuotes
        for quote in quotes {
            if !currentActiveQuotes.contains(quote) {
                currentActiveQuotes.append(quote)
            }
        }
        QuoteStorage.activeQuotes = currentActiveQuotes
    }
    
    class func removeActiveQuotes(_ quotes: [Quote]) {
        var currentActiveQuotes = QuoteStorage.activeQuotes
        for quote in quotes {
            if let quoteIndex = currentActiveQuotes.index(of: quote) {
                currentActiveQuotes.remove(at: quoteIndex)
            }
        }
        QuoteStorage.activeQuotes = currentActiveQuotes
    }
        
    
    // MARK: QuoteTick model methods
    
    class var quoteTicks:[QuoteTick] {
        get {
            print("quoteTicks == READ ===")
            guard let ticksData = UserDefaults.standard.object(forKey: quoteTicksKey) as? Data
                else { return [] }
            do {
                let ticksDecoded = try PropertyListDecoder().decode([QuoteTick].self, from: ticksData)
                return ticksDecoded
            } catch {
                return []
            }
            
        }
        set {
            print("quoteTicks == WRITE ===")
            
            // decode/read quote ticks
            
            if let ticksData = UserDefaults.standard.object(forKey: quoteTicksKey) as? Data {
                var ticks:[QuoteTick] = []
                do { ticks = try PropertyListDecoder().decode([QuoteTick].self, from: ticksData) }
                catch {  print("ticks decode error"); return }
                var newTicks:[QuoteTick] = []
                ticks.forEach { newTicks.append($0) }
                
                // add/update quote ticks
                for newTick in newValue {
                    if let index = newTicks.index(of: newTick) {
                        newTicks[index] = newTick
                    } else {
                        newTicks.append(newTick)
                    }
                }
                
                // encode/write quote ticks
                do {
                    let encodedTicks = try PropertyListEncoder().encode(newTicks) //difference
                    UserDefaults.standard.set(encodedTicks, forKey: quoteTicksKey)
                }
                catch {  print("ticks encode/write error"); return }
            } else {
                do {
                    let encodedTicks = try PropertyListEncoder().encode(newValue) //difference
                    UserDefaults.standard.set(encodedTicks, forKey: quoteTicksKey)
                }
                catch {  print("ticks encode/write error"); return }
            }
            
            // post only new quotes
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name.QuoteStorageDidUpdate, object: newValue.map { $0.quote })
            }
        }
        
    }
}
