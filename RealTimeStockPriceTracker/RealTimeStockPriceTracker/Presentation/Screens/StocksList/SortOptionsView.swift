//
//  SortOptionsView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import SwiftUI

struct SortOptionsView: View {
    let selected: StockSortOption
    let isAscending: Bool
    let onSelect: (StockSortOption) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(StockSortOption.allCases, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    HStack(spacing: 4) {
                        Text(option.title)
                            .font(.caption.weight(.semibold))
                        
                        if selected == option {
                            Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                                .font(.caption2)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(selected == option ? Color.blue.opacity(0.2) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    SortOptionsView(selected: .change,
                    isAscending: true,
                    onSelect: {_ in })
        .padding()
}
