//
//  StockWebSocketService.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 3/4/26.
//

import Foundation
import OSLog

actor StockWebSocketService: StockWebSocketServiceProtocol {
    
    private var priceUpdatesContinuations: [UUID: AsyncStream<PriceUpdate>.Continuation] = [:]
    private var statusContinuations: [UUID: AsyncStream<ConnectionStatus>.Continuation] = [:]
    private var errorContinuations: [UUID: AsyncStream<WebSocketError>.Continuation] = [:]
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var isRunning = false
    private var hasConfirmedConnection = false
    
    private var sendTask: Task<Void, Never>?
    private var receiveTask: Task<Void, Never>?
    
    private let url: URL
    private let session: URLSession
    private let symbols: [String]
    private let logger = Logger(
        subsystem: "com.raulfmp.real-time-stock-price-tracker",
        category: "StockWebSocketService"
    )

    
    init(
        url: URL = URL(string: "wss://ws.postman-echo.com/raw")!,
        session: URLSession = .shared,
        symbols: [String]
    ) {
        self.url = url
        self.session = session
        self.symbols = symbols
    }

    func makePriceUpdatesStream() -> AsyncStream<PriceUpdate> {
        AsyncStream { continuation in
            let id = UUID()
            self.priceUpdatesContinuations[id] = continuation
            continuation.onTermination = { _ in
                Task { await self.removePriceUpdatesContinuation(id) }
            }
        }
    }

    func makeStatusStream() -> AsyncStream<ConnectionStatus> {
        AsyncStream { continuation in
            let id = UUID()
            self.statusContinuations[id] = continuation
            continuation.onTermination = { _ in
                Task { await self.removeStatusContinuation(id) }
            }
        }
    }
    
    func makeErrorStream() -> AsyncStream<WebSocketError> {
        AsyncStream { continuation in
            let id = UUID()
            self.errorContinuations[id] = continuation
            continuation.onTermination = { _ in
                Task { await self.removeErrorContinuation(id) }
            }
        }
    }

    func connect() async {
        guard !isRunning else { return }
        guard !symbols.isEmpty else {
            let error = WebSocketError.connectionFailed("No symbols were configured for price feed.")
            logger.error("Connection error: \(error.message)")
            broadcastError(error)
            broadcastStatus(.disconnected)
            return
        }
        
        isRunning = true
        hasConfirmedConnection = false
        
        broadcastStatus(.connecting)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveTask = Task { await listen() }
        sendTask = Task {
            await emitRandomPrices()
        }
    }

    func disconnect() async {
        guard isRunning else {
            broadcastStatus(.disconnected)
            return
        }
        
        stopRuntime()
        broadcastStatus(.disconnected)
    }

    private func listen() async {
        while !Task.isCancelled && isRunning {
            do {
                guard let message = try await webSocketTask?.receive() else { break }
                
                switch message {
                case .string(let text):
                    await processIncomingMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        await processIncomingMessage(text)
                    }
                @unknown default:
                    break
                }
            } catch {
                let webSocketError = WebSocketError.receiveFailed(error.localizedDescription)
                logger.error("Listening error: \(error.localizedDescription)")
                await handleError(webSocketError)
                break
            }
        }
    }

    private func emitRandomPrices() async {
        while !Task.isCancelled && isRunning {
            try? await Task.sleep(for: .seconds(1))
            
            guard let symbol = symbols.randomElement() else { continue }
            let priceUpdate = PriceUpdateDTO(symbol: symbol, price: .random(in: 100...500))
            
            await send(priceUpdate)
        }
    }
    
    private func processIncomingMessage(_ text: String) async {
        guard let data = text.data(using: .utf8) else { return }
        do {
            let priceUpdate = try JSONDecoder().decode(PriceUpdateDTO.self, from: data)
            if !hasConfirmedConnection {
                hasConfirmedConnection = true
                broadcastStatus(.connected)
            }
            broadcastPriceUpdate(PriceUpdateMapper.map(priceUpdate))
        } catch {
            let webSocketError = WebSocketError.decodingFailed(error.localizedDescription)
            logger.error("Decoding error: \(error.localizedDescription)")
            broadcastError(webSocketError)
        }
    }

    private func send(_ update: PriceUpdateDTO) async {
        do {
            let jsonString = String(data: try JSONEncoder().encode(update), encoding: .utf8)!
            try await webSocketTask?.send(.string(jsonString))
        } catch {
            let webSocketError = WebSocketError.sendFailed(error.localizedDescription)
            logger.error("Send error: \(error.localizedDescription)")
            await handleError(webSocketError)
        }
    }

    private func handleError(_ error: WebSocketError) async {
        stopRuntime()
        broadcastError(error)
        broadcastStatus(.disconnected)
    }

    deinit {
        for continuation in priceUpdatesContinuations.values {
            continuation.finish()
        }
        for continuation in statusContinuations.values {
            continuation.finish()
        }
        for continuation in errorContinuations.values {
            continuation.finish()
        }
        receiveTask?.cancel()
        sendTask?.cancel()
    }
    
    private func broadcastPriceUpdate(_ update: PriceUpdate) {
        for continuation in priceUpdatesContinuations.values {
            continuation.yield(update)
        }
    }
    
    private func broadcastStatus(_ status: ConnectionStatus) {
        for continuation in statusContinuations.values {
            continuation.yield(status)
        }
    }
    
    private func broadcastError(_ error: WebSocketError) {
        for continuation in errorContinuations.values {
            continuation.yield(error)
        }
    }
    
    private func stopRuntime() {
        isRunning = false
        hasConfirmedConnection = false
        receiveTask?.cancel()
        sendTask?.cancel()
        receiveTask = nil
        sendTask = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    private func removePriceUpdatesContinuation(_ id: UUID) {
        priceUpdatesContinuations[id] = nil
    }
    
    private func removeStatusContinuation(_ id: UUID) {
        statusContinuations[id] = nil
    }
    
    private func removeErrorContinuation(_ id: UUID) {
        errorContinuations[id] = nil
    }
}
