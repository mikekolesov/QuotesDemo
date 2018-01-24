//
//  QuoteModels.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation

enum Quote: String, Codable {
    case EURUSD
    case EURGBP
    case USDJPY
    case GBPUSD
    case USDCHF
    case USDCAD
    case AUDUSD
    case EURJPY
    case EURCHF
    
    static let all:[Quote] = [EURUSD, EURGBP, USDJPY, GBPUSD, USDCHF, USDCAD, AUDUSD, EURJPY, EURCHF]
    
    func symbol() -> String {
        return self.rawValue
    }
    
    func symbolSlash() -> String {
        let fullSymbol = self.rawValue
        let nextSymbolIndex = fullSymbol.index(fullSymbol.startIndex, offsetBy: 3)
        let symbol1 = fullSymbol[fullSymbol.startIndex..<nextSymbolIndex]
        let symbol2 = fullSymbol[nextSymbolIndex...]
        return String(symbol1) + "/" + String(symbol2)
    }
}

struct QuoteTick: Codable {
    var quote: Quote
    let bid: String
    let ask: String
    let spread: String
    
    init(quote: Quote, bid: String, ask: String, spread: String) {
        self.quote = quote
        self.bid = bid
        self.ask = ask
        self.spread = spread
    }
}

extension QuoteTick: Equatable {}
func ==(lhs: QuoteTick, rhs: QuoteTick) -> Bool {
    return lhs.quote == rhs.quote
}

