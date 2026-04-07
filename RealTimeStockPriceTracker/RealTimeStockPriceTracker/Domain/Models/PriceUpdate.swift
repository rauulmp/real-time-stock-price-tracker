//
//  PriceUpdate.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

struct PriceUpdate: Sendable {
    let symbol: String
    let price: Double
}
