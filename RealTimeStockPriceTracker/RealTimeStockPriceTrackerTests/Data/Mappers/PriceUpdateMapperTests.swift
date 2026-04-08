//
//  PriceUpdateMapperTests.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 8/4/26.
//

import Testing
@testable import RealTimeStockPriceTracker

@MainActor
struct PriceUpdateMapperTests {
    @Test("Correct transformation from DTO to Domain Model")
    func testMapping() {
        let dto = PriceUpdateDTO(symbol: "AAPL", price: 400.0)
        let domain = PriceUpdateMapper.map(dto)
        
        #expect(domain.symbol == "AAPL")
        #expect(domain.price == 400.0)
    }
}
