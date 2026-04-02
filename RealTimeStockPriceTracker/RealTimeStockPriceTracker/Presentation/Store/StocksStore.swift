//
//  StocksStore.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import Foundation

@Observable @MainActor
final class StocksStore {
    
    private(set) var stocks: [Stock] = []
    
    init() {
        self.stocks = StockFactory.makeInitialStocks()
    }
    
    func update(with update: PriceUpdate) {
        guard let index = stocks.firstIndex(where: { $0.symbol == update.symbol }) else {
            return
        }
        
        let oldPrice = stocks[index].price
        let newPrice = update.price
        let change = newPrice - oldPrice
        
        stocks[index].price = newPrice
        stocks[index].change = change
    }
}
