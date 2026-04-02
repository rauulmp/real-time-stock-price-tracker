//
//  StockSeed.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

struct StockSeed {
    let symbol: String
    let description: String
}

extension StockSeed {
    static let all: [StockSeed] = [
        .init(symbol: "AAPL", description: "Apple Inc."),
        .init(symbol: "GOOG", description: "Alphabet Inc."),
        .init(symbol: "TSLA", description: "Tesla Inc."),
        .init(symbol: "AMZN", description: "Amazon.com Inc."),
        .init(symbol: "MSFT", description: "Microsoft Corporation"),
        .init(symbol: "NVDA", description: "NVIDIA Corporation"),
        .init(symbol: "META", description: "Meta Platforms Inc."),
        .init(symbol: "NFLX", description: "Netflix Inc."),
        .init(symbol: "AMD", description: "Advanced Micro Devices"),
        .init(symbol: "INTC", description: "Intel Corporation"),
        .init(symbol: "BABA", description: "Alibaba Group"),
        .init(symbol: "ORCL", description: "Oracle Corporation"),
        .init(symbol: "UBER", description: "Uber Technologies"),
        .init(symbol: "LYFT", description: "Lyft Inc."),
        .init(symbol: "SHOP", description: "Shopify Inc."),
        .init(symbol: "SQ", description: "Block Inc."),
        .init(symbol: "PYPL", description: "PayPal Holdings"),
        .init(symbol: "CRM", description: "Salesforce Inc."),
        .init(symbol: "ADBE", description: "Adobe Inc."),
        .init(symbol: "CSCO", description: "Cisco Systems"),
        .init(symbol: "QCOM", description: "Qualcomm Inc."),
        .init(symbol: "TXN", description: "Texas Instruments"),
        .init(symbol: "AVGO", description: "Broadcom Inc."),
        .init(symbol: "IBM", description: "IBM Corporation"),
        .init(symbol: "SONY", description: "Sony Group Corporation")
    ]
}
