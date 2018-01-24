//
//  SubscriptionRequest.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation

enum RequestCommand: String {
    case subscribe
    case unsubscribe
}

struct QuoteRequest {
    let requestBody: String
    init(with quotes: [Quote], command: RequestCommand) {
        var requestBuilder = "\(command.rawValue.uppercased()):"
        for (index, quote) in quotes.enumerated() {
            requestBuilder += index > 0 ? "," : " "
            requestBuilder += quote.rawValue
        }
        self.requestBody = requestBuilder
    }
}
