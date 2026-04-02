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
        List(store.stocks) { stock in
            NavigationLink {
                StockDetailView(stock: stock)
            } label: {
                StockRowView(stock: stock)
            }
           
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
       
        .navigationTitle("Stocks")
    }
}

#Preview {
    @Previewable @State var store = StocksStore()
    NavigationStack {
        StocksListView()
    }
    .environment(store)
}
