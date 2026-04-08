//
//  StocksViewState.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

enum StocksViewState: Equatable {
    case idle
    case loading
    case active
    case paused
    case error(String)
}
