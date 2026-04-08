//
//  WebSocketError.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 3/4/26.
//

enum WebSocketError: Error, Sendable, Equatable {
    case connectionFailed(String)
    case sendFailed(String)
    case receiveFailed(String)
    case decodingFailed(String)
}

extension WebSocketError {
    var message: String {
        switch self {
        case .connectionFailed(let message),
             .sendFailed(let message),
             .receiveFailed(let message),
             .decodingFailed(let message):
            return message
        }
    }
}
