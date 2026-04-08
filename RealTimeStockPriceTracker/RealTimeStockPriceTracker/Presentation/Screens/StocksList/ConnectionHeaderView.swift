//
//  ConnectionHeaderView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import SwiftUI

struct ConnectionHeaderView: View {
    let status: ConnectionStatus
    let isActive: Bool
    let onToggle: () -> Void
    
    private var statusText: String {
        switch status {
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            
            Text(statusText)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(statusColor)
            
            Spacer()
            
            Button(action: onToggle) {
                Text(isActive ? "Stop Feed" : "Start Feed")
                    .font(.subheadline.weight(.bold))
                    .frame(minWidth: 110)
            }
            .buttonStyle(.borderedProminent)
            .tint(isActive ? .red : .green)
        }
    }
}

#Preview {
    ConnectionHeaderView(status: .connected,
                         isActive: true,
                         onToggle: {})
        .padding()
}
