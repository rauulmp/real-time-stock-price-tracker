//
//  RealTimeStockPriceTrackerApp.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

@main
struct RealTimeStockPriceTrackerApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
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
            .onChange(of: scenePhase, initial: true) { oldPhase, newPhase in
                handleScenePhaseChange(newPhase)
            }
        }
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            store.start()
            
        case .background:
            Task {
                await store.pause()
            }
            
        case .inactive:
            break
            
        @unknown default:
            break
        }
    }
}
