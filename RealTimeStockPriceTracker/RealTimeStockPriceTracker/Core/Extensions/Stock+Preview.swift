//
//  Stock+Preview.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

#if DEBUG

import Foundation

extension Stock {
    
    static let previewList: [Stock] = StockSeed.all.prefix(5).map {
        Stock(
            id: $0.symbol,
            symbol: $0.symbol,
            description: $0.description,
            price: Double.random(in: 100...500),
            change: Double.random(in: -10...10)
        )
    }
    
    static let preview: Stock = previewList.first!
}

#endif
