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
    
    private var statusText: LocalizedStringResource {
        switch status {
        case .connected: return LocalizedStringResource("connection_status_connected")
        case .connecting: return LocalizedStringResource("connection_status_connecting")
        case .disconnected: return LocalizedStringResource("connection_status_disconnected")
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
                Text(isActive ? "connection_stop_feed_btn" : "connection_start_feed_btn")
                    .font(.subheadline.weight(.bold))
                    .frame(minWidth: 110)
            }
            .buttonStyle(.borderedProminent)
            .tint(isActive ? .red : .green)
            .accessibilityIdentifier("connection_toggle_button")
        }
    }
}

#Preview {
    ConnectionHeaderView(status: .connected,
                         isActive: true,
                         onToggle: {})
        .padding()
}
