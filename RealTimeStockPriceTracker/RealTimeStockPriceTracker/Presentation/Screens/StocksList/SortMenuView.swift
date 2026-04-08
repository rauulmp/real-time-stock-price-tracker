//
//  SortMenuView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import SwiftUI

struct SortMenuView: View {
    let selected: StockSortOption
    let isAscending: Bool
    let onSelect: (StockSortOption) -> Void
    
    var body: some View {
        Menu {
            ForEach(StockSortOption.allCases, id: \.self) { option in
                Button {
                    onSelect(option)
                } label: {
                    HStack {
                        Text(option.title)
                        if selected == option {
                            Image(systemName: isAscending ? "chevron.up" : "chevron.down")
                        }
                    }
                }
                .accessibilityIdentifier("sort_option_\(option.rawValue)")
            }
        } label: {
            Label("sort_menu_label", systemImage: "arrow.up.arrow.down.circle")
        }
        .accessibilityIdentifier("sort_menu")
    }
}

#Preview {
    SortMenuView(selected: .price,
                 isAscending: true,
                 onSelect: {_ in })
        .padding()
}
