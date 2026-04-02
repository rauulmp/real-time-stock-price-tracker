//
//  StocksFactory.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

struct StockFactory {
    
    static func makeInitialStocks() -> [Stock] {
        StockSeed.all.map {
            Stock(
                id: $0.symbol,
                symbol: $0.symbol,
                description: $0.description,
                price: Double.random(in: 100...500),
                change: 0
            )
        }
    }
}
