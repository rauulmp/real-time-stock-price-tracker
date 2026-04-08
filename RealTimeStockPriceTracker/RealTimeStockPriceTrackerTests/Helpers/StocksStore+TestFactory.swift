//
//  StocksStore+TestFactory.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import Foundation
@testable import RealTimeStockPriceTracker

@MainActor func makeStore(
    stocks: [(String, Double)] = []
) -> (StocksStore, MockStockWebSocketService) {
    
    let service = MockStockWebSocketService()
    
    let store = StocksStore(
        service: service,
        fetchInitialStocks: {
            stocks.map {
                Stock(
                    id: $0.0,
                    symbol: $0.0,
                    description: "",
                    price: $0.1,
                    change: 0
                )
            }
        }
    )
    
    return (store, service)
}
