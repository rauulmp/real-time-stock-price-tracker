//
//  View+CardStyle.swift
//  RealTimeStockPriceTracker
//
//  Created by Raul Montoya Perez on 2/4/26.
//

import SwiftUI

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
