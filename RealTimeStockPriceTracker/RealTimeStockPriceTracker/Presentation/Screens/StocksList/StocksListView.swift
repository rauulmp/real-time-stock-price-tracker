//
//  StocksListView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

struct StocksListView: View {
    @Environment(StocksStore.self) private var store
    
    private var statusText: String {
        switch store.connectionStatus {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        }
    }
    
    private var statusColor: Color {
        switch store.connectionStatus {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        }
    }
    
    private var isFeedActive: Bool {
        store.connectionStatus != .disconnected
    }
    
    var body: some View {
        List {
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                
                Text(statusText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(statusColor)
                
                Spacer()
                
                Button {
                    Task { await store.toggleConnection() }
                } label: {
                    Text(isFeedActive ? "Stop Feed" : "Start Feed")
                        .font(.subheadline.weight(.bold))
                        .frame(minWidth: 110)
                }
                .buttonStyle(.borderedProminent)
                .tint(isFeedActive ? .red : .green)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            
            if let error = store.lastError {
                Text(error.message)
                    .font(.caption)
                    .foregroundColor(.red)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            }
            
            ForEach(store.stocks) { stock in
                NavigationLink {
                    StockDetailView(stock: stock)
                } label: {
                    StockRowView(stock: stock)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Stocks")
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
