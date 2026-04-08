//
//  StockSkeletonRow.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import SwiftUI

struct StockSkeletonRow: View {
    @State private var opacity = 0.3
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(opacity))
                    .frame(width: 60, height: 16)
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(opacity))
                    .frame(width: 120, height: 12)
            }
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(.gray.opacity(opacity))
                .frame(width: 80, height: 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                opacity = 0.7
            }
        }
    }
}

#Preview {
    StockSkeletonRow()
        .padding()
}
