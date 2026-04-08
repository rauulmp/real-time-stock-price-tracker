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
    private var priceUpdatesTask: Task<Void, Never>?
    private var statusTask: Task<Void, Never>?
    private var errorTask: Task<Void, Never>?
    private var symbolIndexBySymbol: [String: Int] = [:]
    private var hasStarted = false
    
    private(set) var stocks: [Stock] = []
    private(set) var connectionStatus: ConnectionStatus = .disconnected
    private(set) var lastError: WebSocketError?
    
    var sortOption: StockSortOption = .price
    var isAscending: Bool = false

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
    
    init(service: StockWebSocketServiceProtocol) {
        self.service = service
        self.stocks = StockFactory.makeInitialStocks()
        self.symbolIndexBySymbol = Dictionary(
            uniqueKeysWithValues: stocks.enumerated().map { ($1.symbol, $0) }
        )
    }
    
    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        subscribeToUpdates()
    }
    
    func stop() async {
        guard hasStarted else { return }
        hasStarted = false
        connectionStatus = .disconnected
        cancelSubscriptions()
        await service.disconnect()
    }
    
    func shutdown() async {
        await stop()
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
        print("selection sort option = \(option.rawValue)")
        if sortOption == option {
            isAscending.toggle()
        } else {
            sortOption = option
            isAscending = false
        }
    }
    
    private func subscribeToUpdates() {
        priceUpdatesTask = Task { [weak self, service = self.service] in
            for await priceUpdate in await service.makePriceUpdatesStream() {
                guard let self else { break }
                self.updatePrices(with: priceUpdate)
            }
        }
        
        statusTask = Task { [weak self, service = self.service] in
            for await newStatus in await service.makeStatusStream() {
                guard let self else { break }
                self.connectionStatus = newStatus
                if newStatus == .connected {
                    self.lastError = nil
                }
            }
        }
        
        errorTask = Task { [weak self, service = self.service] in
            for await newError in await service.makeErrorStream() {
                guard let self else { break }
                self.lastError = newError
            }
        }
    }
    
    private func cancelSubscriptions() {
        priceUpdatesTask?.cancel()
        statusTask?.cancel()
        errorTask?.cancel()
        priceUpdatesTask = nil
        statusTask = nil
        errorTask = nil
    }
    
    private func updatePrices(with update: PriceUpdate) {
        guard let index = symbolIndexBySymbol[update.symbol] else {
            return
        }
        
        let oldPrice = stocks[index].price
        let newPrice = update.price
        let change = newPrice - oldPrice
        
        stocks[index].price = newPrice
        stocks[index].change = change
    }
    
}
