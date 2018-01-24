//
//  QuoteProvider.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation

protocol QuoteProviderDelegate: class {
    func quoteProviderDidUpdate(_ quoteIndexes:[Int])
}

class QuoteProvider {
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(quoteStorageDidUpdateNotification(notification:)),
                                               name: Notification.Name.QuoteStorageDidUpdate, object: nil)
    }
    
    weak var delegate: QuoteProviderDelegate? = nil
    
    var numberOfQuotes:Int {
        return QuoteStorage.activeQuotes.count
    }
    
    func quoteTick(at index: Int) -> QuoteTick? {
        let activeQuotes = QuoteStorage.activeQuotes
        if  activeQuotes.count > index {
            let quote = activeQuotes[index]
            guard let quoteTick = QuoteStorage.quoteTicks.filter({ $0.quote == quote }).first
                else { return nil }
            return quoteTick
        }
        return nil
    }
    
    @objc func quoteStorageDidUpdateNotification(notification: Notification) {
        if let updatedQuotes = notification.object as? [Quote] {
            let activeQuotes = QuoteStorage.activeQuotes
            if  activeQuotes.count > 0 {
                let updatedIndexes = updatedQuotes.map({ (updatedQuote) -> Int in
                    if let index = activeQuotes.index(of: updatedQuote) {
                        return index
                    }
                    return 0
                })
                delegate?.quoteProviderDidUpdate(updatedIndexes)
            }
            
        }
    }
}
