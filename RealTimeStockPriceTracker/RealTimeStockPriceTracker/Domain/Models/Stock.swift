//
//  Stock.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import Foundation

struct Stock: Identifiable, Codable, Hashable {
    let id: String
    let symbol: String
    let description: String
    var price: Double
    var change: Double
    
    var formattedPrice: String {
        String(format: "%.2f", price)
    }
    
    var formattedChange: String {
        String(format: "%@%.2f", change >= 0 ? "+" : "", change)
    }
    
    var isPositive: Bool {
        change >= 0
    }
}
