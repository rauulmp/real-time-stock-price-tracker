//
//  StockRowView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

struct StockRowView: View {
    
    let stock: Stock
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(stock.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(stock.formattedPrice)")
                    .font(.headline)
                    .monospacedDigit()
              
                HStack(spacing: 4) {
                    Image(systemName: stock.isPositive ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .font(.caption2)
                    
                    Text(stock.formattedChange)
                        .font(.caption)
                        .monospacedDigit()
                }
                .foregroundColor(stock.isPositive ? .green : .red)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    StockRowView(stock: .preview)
        .padding()
}
