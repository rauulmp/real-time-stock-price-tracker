//
//  StockWebSocketServiceProtocol.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 3/4/26.
//

protocol StockWebSocketServiceProtocol: Actor, Sendable {
    func makePriceUpdatesStream() -> AsyncStream<PriceUpdate>
    func makeStatusStream() -> AsyncStream<ConnectionStatus>
    func makeErrorStream() -> AsyncStream<WebSocketError>
    
    func connect() async
    func disconnect() async
}
