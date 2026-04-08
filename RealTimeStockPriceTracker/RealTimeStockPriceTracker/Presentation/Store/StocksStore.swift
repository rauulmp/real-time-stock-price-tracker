//
//  StocksStore.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import Foundation

@Observable @MainActor
final class StocksStore {
    
    private let service: StockWebSocketServiceProtocol
    private let fetchInitialStocks: () async throws -> [Stock]
    
    private(set) var state: StocksViewState = .idle
    private(set) var stocks: [Stock] = []
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    private(set) var lastError: WebSocketError?
    
    private(set) var sortOption: StockSortOption = .price
    private(set) var isAscending: Bool = false
    
    private var symbolIndexBySymbol: [String: Int] = [:]
    private var pendingUpdates: [String: PriceUpdate] = [:]
    
    private var priceUpdatesTask: Task<Void, Never>?
    private var statusTask: Task<Void, Never>?
    private var errorTask: Task<Void, Never>?
    private var throttleTask: Task<Void, Never>?

    var sortedStocks: [Stock] {
        stocks.sorted { lhs, rhs in
            switch sortOption {
            case .price:
                if lhs.price == rhs.price {
                    return lhs.symbol < rhs.symbol
                }
                return isAscending ? lhs.price < rhs.price : lhs.price > rhs.price
               
            case .change:
                if lhs.change == rhs.change {
                    return lhs.symbol < rhs.symbol
                }
                return isAscending ? lhs.change < rhs.change : lhs.change > rhs.change
            }
        }
    }
    
    init(service: StockWebSocketServiceProtocol,
         fetchInitialStocks: @escaping () async throws -> [Stock] = { try await StockFactory.makeInitialStocks() }
    ) {
        self.service = service
        self.fetchInitialStocks = fetchInitialStocks
    }
    
    func start() {
        switch state {
        case .active, .loading:
            return
            
        case .idle, .error:
            loadInitialData()
            
        case .paused:
            Task {
                await resumeStreams()
            }
        }
    }
    
    func refresh() {
        pendingUpdates.removeAll()
        cancelSubscriptions()
        state = .idle
        start()
    }
    
    func stop() async {
        guard state != .idle else { return }
        state = .idle
        connectionStatus = .disconnected
        cancelSubscriptions()
        pendingUpdates.removeAll()
        await service.disconnect()
    }
    
    func pause() async {
        guard state == .active else { return }
        cancelSubscriptions()
        pendingUpdates.removeAll()
        await service.disconnect()
        state = .paused
    }
    
    private func loadInitialData() {
        state = .loading
        Task {
            do {
                let initialStocks = try await fetchInitialStocks()
                self.stocks = initialStocks
                self.symbolIndexBySymbol = Dictionary(
                    uniqueKeysWithValues: stocks.enumerated().map { ($0.element.symbol, $0.offset) }
                )
                await resumeStreams()
            } catch {
                state = .error("Error de conexión")
            }
        }
    }

    private func resumeStreams() async {
        subscribeToUpdates()
        startThrottleTimer()
        
        await service.connect()
        state = .active
    }
    
    func handleConnectionToggle() {
        Task {
            if connectionStatus == .disconnected {
                await service.connect()
            } else {
                await service.disconnect()
            }
        }
    }
    
    func selectSortOption(_ option: StockSortOption) {
        if sortOption == option {
            isAscending.toggle()
        } else {
            sortOption = option
            isAscending = false
        }
    }
    
    private func subscribeToUpdates() {
        cancelSubscriptions()
        
        priceUpdatesTask = Task { [weak self] in
            guard let service = self?.service else { return }
            
            for await priceUpdate in await service.makePriceUpdatesStream() {
                guard let self else { break }
                self.pendingUpdates[priceUpdate.symbol] = priceUpdate
            }
        }
        
        statusTask = Task { [weak self] in
            guard let service = self?.service else { return }
            
            for await newStatus in await service.makeStatusStream() {
                guard let self else { break }
                self.connectionStatus = newStatus
                if newStatus == .connected {
                    self.lastError = nil
                }
            }
        }
        
        errorTask = Task { [weak self] in
            guard let service = self?.service else { return }
            
            for await newError in await service.makeErrorStream() {
                guard let self else { break }
                self.lastError = newError
            }
        }
    }
    
    private func startThrottleTimer() {
        throttleTask?.cancel()
        throttleTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(300))
                
                if !pendingUpdates.isEmpty {
                    applyPendingUpdates()
                }
            }
        }
    }

    private func applyPendingUpdates() {
        let updates = pendingUpdates
        pendingUpdates.removeAll()
        
        for (_, update) in updates {
            guard let index = symbolIndexBySymbol[update.symbol] else { continue }
            
            let oldPrice = stocks[index].price
            stocks[index].price = update.price
            stocks[index].change = update.price - oldPrice
        }
    }
    
    private func cancelSubscriptions() {
        priceUpdatesTask?.cancel()
        statusTask?.cancel()
        errorTask?.cancel()
        throttleTask?.cancel()
        priceUpdatesTask = nil
        statusTask = nil
        errorTask = nil
        throttleTask = nil
    }
    
}
