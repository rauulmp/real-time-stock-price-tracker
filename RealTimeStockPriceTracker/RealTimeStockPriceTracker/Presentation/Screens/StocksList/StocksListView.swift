//
//  StocksListView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

struct StocksListView: View {
    @Environment(StocksStore.self) private var store
    
    var body: some View {
        List {
            Section {
                ConnectionHeaderView(
                    status: store.connectionStatus,
                    isActive: store.connectionStatus != .disconnected,
                    onToggle: { store.handleConnectionToggle() }
                )
            } header: {
                Text("Service Status")
            }

            Section {
                ForEach(store.sortedStocks) { stock in
                    NavigationLink(value: stock) {
                        StockRowView(stock: stock)
                    }
                }
            } header: {
                Text("Symbols")
            } footer: {
                if let error = store.lastError {
                    Text(error.message).foregroundColor(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Market")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                SortMenuView(
                    selected: store.sortOption,
                    isAscending: store.isAscending,
                    onSelect: { store.selectSortOption($0) }
                )
            }
        }
        .navigationDestination(for: Stock.self) { stock in
            StockDetailView(stock: stock)
        }
        .animation(.default, value: store.sortedStocks)
    }
}

#Preview {
    @Previewable @State var store = StocksStore(
        service: StockWebSocketService(symbols: StockSeed.all.map(\.symbol))
    )
    NavigationStack {
        StocksListView()
    }
    .environment(store)
}
