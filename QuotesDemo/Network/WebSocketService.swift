//
//  WebSocketService.swift
//  QuotesDemo
//
//  Created by MKolesov on 21/01/2018.
//  Copyright © 2018 Mikhail Kolesov. All rights reserved.
//

import Foundation
import Starscream

protocol WebSocketServiceDelegate:class {
    func webSocketServiceDidResponse(_ response: QuoteResponse)
    func webSocketServiceDidDisconnect()
    func webSocketServiceDidConnect()
}


class WebSocketService {
    
    let address:URL
    var socket: WebSocket?
    var deferedRequest: QuoteRequest? = nil
    weak var delegate: WebSocketServiceDelegate? = nil
    
    init(with address:URL) {
        self.address = address
    }
    
    func connect(with request:QuoteRequest) {
        deferedRequest = request
        socket = WebSocket(url: address)
        socket?.delegate = self
        socket?.connect()
    }
    
    func send(_ request:QuoteRequest) {
        print("Sending Request: \(request.requestBody)")
        socket?.write(string: request.requestBody, completion: nil)
    }
    
    func disconnect(with request:QuoteRequest) {
        print("Disconnect.Request: \(request.requestBody)")
        socket?.write(string: request.requestBody, completion: { [unowned self] in
            self.socket?.disconnect()
        })
    }
}

extension WebSocketService: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
        delegate?.webSocketServiceDidConnect()
        if let requestBody = deferedRequest?.requestBody {
            print("Request: \(requestBody)")
            socket.write(string: requestBody, completion: nil)
        }
    }

    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect")
        print("error: \(String(describing: error?.localizedDescription))")
        socket.delegate = nil
        delegate?.webSocketServiceDidDisconnect()
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("websocketDidReceiveMessage:\n\(text)")

        let response = QuoteResponse(responseBody: text)
        delegate?.webSocketServiceDidResponse(response)
    }

    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("websocketDidReceiveData:\n\(data)")
    }

}


