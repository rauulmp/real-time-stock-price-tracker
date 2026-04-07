//
//  PriceUpdateMapper.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 7/4/26.
//

struct PriceUpdateMapper {
    nonisolated static func map(_ dto: PriceUpdateDTO) -> PriceUpdate {
        PriceUpdate(symbol: dto.symbol, price: dto.price)
    }
}
