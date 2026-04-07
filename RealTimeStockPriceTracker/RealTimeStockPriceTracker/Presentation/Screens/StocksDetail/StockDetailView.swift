//
//  StockDetailView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

struct StockDetailView: View {
    
    @Environment(StocksStore.self) private var store
    
    let stock: Stock
    
    private var currentStock: Stock {
        store.stocks.first(where: { $0.id == stock.id }) ?? stock
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                VStack(spacing: 12) {
                    Text("$\(currentStock.formattedPrice)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    HStack(spacing: 4) {
                        Image(systemName: currentStock.isPositive ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                            .font(.headline)
                            .foregroundColor(currentStock.isPositive ? .green : .red)
                        
                        Text(currentStock.formattedChange)
                            .font(.subheadline)
                            .foregroundColor(currentStock.isPositive ? .green : .red)
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity)
                .cardStyle()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.caption.bold())
                        .textCase(.uppercase)
                    
                    Text(stock.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .cardStyle()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(stock.symbol)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var store = StocksStore(
        service: StockWebSocketService(symbols: StockSeed.all.map(\.symbol))
    )
    NavigationStack {
        StockDetailView(stock: .preview)
    }
    .environment(store)
}
