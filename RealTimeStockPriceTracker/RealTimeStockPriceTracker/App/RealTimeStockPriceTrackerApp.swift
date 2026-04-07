//
//  RealTimeStockPriceTrackerApp.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

@main
struct RealTimeStockPriceTrackerApp: App {
    @State private var store = {
        let symbols = StockSeed.all.map(\.symbol)
        let service = StockWebSocketService(symbols: symbols)
        return StocksStore(service: service)
    }()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StocksListView()
            }
            .environment(store)
        }
    }
}
