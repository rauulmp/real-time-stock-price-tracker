//
//  StockSortOption.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import Foundation

enum StockSortOption: String, CaseIterable {
    case price
    case change
    
    var title: String {
        switch self {
        case .price: return "Price"
        case .change: return "Change"
        }
    }
}
