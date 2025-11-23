//
//  SymbolDetailViewModel.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import SwiftUI

struct SymbolDetailViewModel: QuoteDisplayProviding {
    let quote: StockQuote

    var descriptionText: String {
        quote.description
    }
}
