//
//  RealTimeStockPriceTrackerApp.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

@main
struct RealTimeStockPriceTrackerApp: App {
    @State private var store = StocksStore()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environment(store)
        }
    }
}
