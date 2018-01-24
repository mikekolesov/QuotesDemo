//
//  SubscriptionService.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation

class SubscriptionManager {
    
    // connection failure detection flags
    var backgroundDisconnection = false
    var networkLost = false
    var reconnectionStarted = false
    var userNotified = false
    
    let webSocketService: WebSocketService
    
    public static let shared: SubscriptionManager = {
        let service = WebSocketService(with: Configuration.shared.webSocketURL)
        return SubscriptionManager(with: service)
    }()
    
    init(with webSocketService:WebSocketService) {
        self.webSocketService = webSocketService
        self.webSocketService.delegate = self
    }
    
    func renewSubscription() {
        backgroundDisconnection = false
        
        let activeQuotes = QuoteStorage.activeQuotes
        let request = QuoteRequest(with: activeQuotes, command: .subscribe)
        webSocketService.connect(with: request)
    }
    
    func cancelSubscription() {
        backgroundDisconnection = true
        Alert.dissmiss() // if needed
        
        let activeQuotes = QuoteStorage.activeQuotes
        let request = QuoteRequest(with: activeQuotes, command: .unsubscribe)
        webSocketService.disconnect(with: request)
    }
    
    func addSubscriptions(_ quotes: [Quote]) {
        QuoteStorage.addActiveQuotes(quotes)
        let request = QuoteRequest(with: quotes, command: .subscribe)
        webSocketService.send(request)
    }
    
    func removeSubscription(_ quotes: [Quote]) {
        QuoteStorage.removeActiveQuotes(quotes)
        let request = QuoteRequest(with: quotes, command: .unsubscribe)
        webSocketService.send(request)
    }
    
}

extension SubscriptionManager: WebSocketServiceDelegate {
    
    func webSocketServiceDidResponse(_ response: QuoteResponse) {
        if let quoteTicks = response.quoteTicks {
            print("QuoteTicks:\n\(quoteTicks)")
            // add new quote ticks
            QuoteStorage.quoteTicks = quoteTicks
        } else {
            print("No quote ticks found")
        }
    }
    
    func webSocketServiceDidConnect() {
        networkLost = false
        userNotified = false
        reconnectionStarted = false
    }
    
    func webSocketServiceDidDisconnect() {
        if backgroundDisconnection {
            print("backgroundDisconnection? \(String(backgroundDisconnection)). That's ok. Will be handled back on foreground")
        } else {
            print("backgroundDisconnection? \(String(backgroundDisconnection)). Network lost. Need to alart once and retry connection")
            
            if !reconnectionStarted {
                reconnectionStarted = true
                let delay: Double = 3.0
                let when = DispatchTime.now() + delay
                print("Retring connection in \(delay) seconds..")
                DispatchQueue.global().asyncAfter(deadline: when, execute: { [unowned self] in
                    self.renewSubscription()
                    self.reconnectionStarted = false
                })
            }
            
            if !userNotified {
                print("Nofitying user for Network Lost with Alert")
                let title = "Network lost"
                let message = "Please check you internet connection and try again"
                Alert.show(with: title, and: message)
                userNotified = true
            }
            
        }
    }
}
