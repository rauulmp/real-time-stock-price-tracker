//
//  ContentView.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(StocksStore.self) private var store
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var store = StocksStore()
    NavigationStack {
        ContentView()
    }
    .environment(store)
}
