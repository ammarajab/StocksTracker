//
//  QuoteDisplayProviding.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import SwiftUI

protocol QuoteDisplayProviding {
    var quote: StockQuote { get }
}

extension QuoteDisplayProviding {
    var symbolText: String {
        quote.symbol
    }

    var priceText: String {
        String(format: "$%.2f", quote.price)
    }

    var changeIndicator: String {
        switch quote.lastMovement {
        case .up:
            return "▲"
        case .down:
            return "▼"
        case .none:
            return ""
        }
    }

    var changeColor: Color {
        switch quote.lastMovement {
        case .up:
            return .green
        case .down:
            return .red
        case .none:
            return .primary
        }
    }
}
