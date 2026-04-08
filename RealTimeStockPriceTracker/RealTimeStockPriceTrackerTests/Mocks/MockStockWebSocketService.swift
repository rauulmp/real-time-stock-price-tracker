//
//  MockStockService.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import Foundation
@testable import RealTimeStockPriceTracker

actor MockStockWebSocketService: StockWebSocketServiceProtocol {
    private var priceContinuation: AsyncStream<PriceUpdate>.Continuation?
    private var statusContinuation: AsyncStream<ConnectionStatus>.Continuation?
    private var errorContinuation: AsyncStream<WebSocketError>.Continuation?
    
    var shouldSendAutomaticUpdates = false

    func makePriceUpdatesStream() -> AsyncStream<PriceUpdate> {
        AsyncStream { priceContinuation = $0 }
    }
    
    func makeStatusStream() -> AsyncStream<ConnectionStatus> {
        AsyncStream { statusContinuation = $0 }
    }
    
    func makeErrorStream() -> AsyncStream<WebSocketError> {
        AsyncStream { errorContinuation = $0 }
    }

    func feedPrice(_ update: PriceUpdate) {
        priceContinuation?.yield(update)
    }
    
    func feedStatus(_ status: ConnectionStatus) {
        statusContinuation?.yield(status)
    }
    
    func feedError(_ error: WebSocketError) {
        errorContinuation?.yield(error)
    }

    var connectCalled = false
    var disconnectCalled = false

    func connect() async {
        connectCalled = true
    }
    
    func disconnect() async {
        disconnectCalled = true
    }
}
