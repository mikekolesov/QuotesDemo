//
//  Configuration.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case BadParse(String)
}

struct Configuration: Decodable  {
    
    var webSocketURL: URL {
        return URL(string: webSocketAddress) ?? Configuration.fallbackURL
    }
    
    fileprivate var webSocketAddress: String
    
    static fileprivate let fallbackURL = URL(string:"http://localhost")!
    
    static let shared:Configuration = {
        do {
            guard let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist")
                else { throw ParseError.BadParse("Cannot find configuration plist in bundle") }
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let configuration = try decoder.decode(Configuration.self, from: data)
            return configuration
        } catch {
            print(error)
            return Configuration(webSocketAddress: Configuration.fallbackURL.absoluteString)
        }
    }()

}

