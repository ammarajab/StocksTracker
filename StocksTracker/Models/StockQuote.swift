//
//  StockQuote.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import Foundation

enum PriceMovement: String, Codable {
    case up
    case down
    case none
}

struct PriceUpdate: Codable {
    let symbol: String
    let price: Double
    let timestamp: Date
}

struct StockQuote: Identifiable, Codable {
    let id: String
    let symbol: String
    var price: Double
    var description: String
    var lastMovement: PriceMovement
    var lastUpdated: Date

    init(symbol: String, price: Double, description: String) {
        self.id = symbol
        self.symbol = symbol
        self.price = price
        self.description = description
        self.lastMovement = .none
        self.lastUpdated = Date()
    }
}
