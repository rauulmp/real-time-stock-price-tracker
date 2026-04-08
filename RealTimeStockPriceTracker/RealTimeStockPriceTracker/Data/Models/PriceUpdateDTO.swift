//
//  PriceUpdateDTO.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 3/4/26.
//

struct PriceUpdateDTO: Sendable {
    let symbol: String
    let price: Double
}

nonisolated extension PriceUpdateDTO: Codable {}
