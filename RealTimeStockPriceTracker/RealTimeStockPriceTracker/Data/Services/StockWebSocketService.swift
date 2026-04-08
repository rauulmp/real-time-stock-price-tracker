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
    private var shouldMaintainConnection = false
    private var reconnectAttempt = 0
    
    private var sendTask: Task<Void, Never>?
    private var receiveTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    
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
        shouldMaintainConnection = true
        reconnectTask?.cancel()
        reconnectTask = nil
        
        guard !isRunning else { return }
        guard !symbols.isEmpty else {
            let error = WebSocketError.connectionFailed("No symbols were configured for price feed.")
            logger.error("Connection error: \(error.message)")
            broadcastError(error)
            broadcastStatus(.disconnected)
            shouldMaintainConnection = false
            return
        }
        
        startRuntime()
    }

    func disconnect() async {
        shouldMaintainConnection = false
        reconnectAttempt = 0
        reconnectTask?.cancel()
        reconnectTask = nil
        
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
                await handleRuntimeFailure(webSocketError)
                break
            }
        }
        
        if !Task.isCancelled && shouldMaintainConnection && !hasConfirmedConnection {
            let closedError = WebSocketError.receiveFailed("Socket closed before first message.")
            await handleRuntimeFailure(closedError)
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
                reconnectAttempt = 0
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
        guard webSocketTask != nil else {
            let webSocketError = WebSocketError.sendFailed("Socket unavailable.")
            logger.error("Send error: \(webSocketError.message)")
            await handleRuntimeFailure(webSocketError)
            return
        }
        
        do {
            let jsonString = String(data: try JSONEncoder().encode(update), encoding: .utf8)!
            try await webSocketTask?.send(.string(jsonString))
        } catch {
            let webSocketError = WebSocketError.sendFailed(error.localizedDescription)
            logger.error("Send error: \(error.localizedDescription)")
            await handleRuntimeFailure(webSocketError)
        }
    }

    private func handleRuntimeFailure(_ error: WebSocketError) async {
        stopRuntime()
        broadcastError(error)
        
        guard shouldMaintainConnection else {
            broadcastStatus(.disconnected)
            return
        }
        
        scheduleReconnectIfNeeded()
    }
    
    private func scheduleReconnectIfNeeded() {
        guard reconnectTask == nil else { return }
        
        reconnectTask = Task {
            while !Task.isCancelled && shouldMaintainConnection && !isRunning {
                reconnectAttempt += 1
                let delayNanoseconds = reconnectDelayNanoseconds(for: reconnectAttempt)
                
                logger.info("Reconnect attempt \(self.reconnectAttempt, privacy: .public) in \(delayNanoseconds, privacy: .public)ns")
                broadcastStatus(.connecting)
                
                do {
                    try await Task.sleep(nanoseconds: delayNanoseconds)
                } catch {
                    break
                }
                
                guard !Task.isCancelled && shouldMaintainConnection else { break }
                startRuntime()
            }
            
            reconnectTask = nil
        }
    }
    
    private func reconnectDelayNanoseconds(for attempt: Int) -> UInt64 {
        let baseDelaySeconds = 1.0
        let maxDelaySeconds = 30.0
        let exponentialDelay = min(maxDelaySeconds, baseDelaySeconds * pow(2.0, Double(max(attempt - 1, 0))))
        let jitterFactor = Double.random(in: 0.8...1.2)
        let delaySeconds = exponentialDelay * jitterFactor
        
        return UInt64(delaySeconds * 1_000_000_000)
    }
    
    private func startRuntime() {
        isRunning = true
        hasConfirmedConnection = false
        
        broadcastStatus(.connecting)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        receiveTask = Task { await listen() }
        sendTask = Task { await emitRandomPrices() }
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
        reconnectTask?.cancel()
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
        reconnectTask?.cancel()
        receiveTask = nil
        sendTask = nil
        reconnectTask = nil
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
