//
//  StocksStoreTests.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import Testing
import Foundation
@testable import RealTimeStockPriceTracker

@MainActor
struct StocksStoreTests {
    
    @Test
    func start_loadsInitialStocks_andBecomesActive() async throws {
        let (store, _) = makeStore(stocks: [("AAPL", 100)])
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(store.state == .active)
        #expect(store.stocks.count == 1)
    }

    @Test
    func sort_by_price_descending() async throws {
        let (store, _) = makeStore(stocks: [
            ("AAPL", 100),
            ("GOOG", 200),
            ("MSFT", 150)
        ])
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        store.selectSortOption(.price)
        store.selectSortOption(.price)
        
        let sorted = store.sortedStocks.map(\.symbol)
        
        #expect(sorted == ["GOOG", "MSFT", "AAPL"])
    }

    @Test
    func sort_toggle_ascending() async throws {
        let (store, _) = makeStore(stocks: [
            ("AAPL", 100),
            ("GOOG", 200)
        ])
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        store.selectSortOption(.price)
        
        let sorted = store.sortedStocks.map(\.symbol)
        
        #expect(sorted == ["AAPL", "GOOG"])
    }

    @Test
    func price_update_applies_to_stock() async throws {
        let (store, service) = makeStore(stocks: [("AAPL", 100)])
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        await service.feedPrice(.init(symbol: "AAPL", price: 150))
        
        try await Task.sleep(for: .milliseconds(400))
        
        let stock = store.stocks.first
        
        #expect(stock?.price == 150)
        #expect(stock?.change == 50)
    }

    @Test
    func throttling_batches_multiple_updates() async throws {
        let (store, service) = makeStore(stocks: [("AAPL", 100)])
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        await service.feedPrice(.init(symbol: "AAPL", price: 110))
        await service.feedPrice(.init(symbol: "AAPL", price: 120))
        await service.feedPrice(.init(symbol: "AAPL", price: 130))
        
        try await Task.sleep(for: .milliseconds(400))
        
        let price = store.stocks.first?.price
        
        #expect(price == 130)
    }

    @Test
    func connection_status_updates() async throws {
        let (store, service) = makeStore()
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        await service.feedStatus(.connecting)
        try await Task.sleep(for: .milliseconds(100))
        #expect(store.connectionStatus == .connecting)
        
        await service.feedStatus(.connected)
        try await Task.sleep(for: .milliseconds(100))
        #expect(store.connectionStatus == .connected)
    }

    @Test
    func error_is_propagated() async throws {
        let (store, service) = makeStore()
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        let error = WebSocketError.receiveFailed("fail")
        await service.feedError(error)
        
        try await Task.sleep(for: .milliseconds(100))
        #expect(store.lastError == error)
    }

    @Test
    func pause_sets_state_to_paused() async throws {
        let (store, _) = makeStore()
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        await store.pause()
        
        #expect(store.state == .paused)
    }

    @Test
    func refresh_resets_and_restarts_flow() async throws {
        let (store, _) = makeStore(stocks: [("AAPL", 100)])
        
        store.start()
        try await Task.sleep(for: .milliseconds(100))
        
        store.refresh()
        
        try await Task.sleep(for: .milliseconds(100))
        
        #expect(store.state == .active)
    }
}
