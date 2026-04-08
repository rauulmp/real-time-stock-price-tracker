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
    
    var title: LocalizedStringResource {
        switch self {
        case .price: return LocalizedStringResource("stock_sort_option_price")
        case .change: return LocalizedStringResource("stock_sort_option_change")
        }
    }
}
