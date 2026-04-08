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
        Group {
            switch store.state {
            case .idle, .loading:
                loadingView
                
            case .active, .paused:
                if store.stocks.isEmpty {
                    emptyStateView
                } else {
                    mainListView
                }
                
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle("Market")
        .navigationDestination(for: Stock.self) { stock in
            StockDetailView(stock: stock)
        }
    }
    
    private var loadingView: some View {
        List {
            ForEach(0..<10) { _ in
                StockSkeletonRow()
            }
        }
        .listStyle(.insetGrouped)
        .redacted(reason: .placeholder)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Stocks Available", systemImage: "chart.line.downtrend.xyaxis")
        } description: {
            Text("There are no symbols available to track at this moment.")
        } actions: {
            Button("Refresh") {
                store.refresh()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("Market Data Unavailable", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        } actions: {
            Button("Retry") {
                store.refresh()
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var mainListView: some View {
        List {
            serviceStatusSection
            symbolsSection
        }
        .listStyle(.insetGrouped)
        .toolbar {
            sortMenuToolbarItem
        }
        .animation(.default, value: store.sortedStocks)
    }
    
    private var serviceStatusSection: some View {
        Section {
            ConnectionHeaderView(
                status: store.connectionStatus,
                isActive: store.connectionStatus != .disconnected,
                onToggle: { store.handleConnectionToggle() }
            )
        } header: {
            Text("Service Status")
        }
    }
    
    private var symbolsSection: some View {
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
                Text(error.message)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var sortMenuToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            SortMenuView(
                selected: store.sortOption,
                isAscending: store.isAscending,
                onSelect: { store.selectSortOption($0) }
            )
        }
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
