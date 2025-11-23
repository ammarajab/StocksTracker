//
//  StocksTrackerRootView.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import SwiftUI

struct StocksTrackerRootView: View {
    @StateObject private var viewModel: PriceFeedViewModel
    @State private var path: [String] = []

    init() {
        let symbols = Self.defaultSymbols
        let descriptions = Self.defaultDescriptions
        let service = WebSocketPriceService(symbols: symbols)
        _viewModel = StateObject(wrappedValue: PriceFeedViewModel(service: service, symbols: symbols, descriptions: descriptions))
    }

    var body: some View {
        NavigationStack(path: $path) {
            FeedView(viewModel: viewModel) { symbol in
                path.append(symbol)
            }
            .navigationDestination(for: String.self) { symbol in
                if let quote = viewModel.quote(for: symbol) {
                    SymbolDetailView(viewModel: SymbolDetailViewModel(quote: quote))
                } else {
                    Text("Symbol not found")
                }
            }
        }
        .onOpenURL { url in
            guard url.scheme == "stocks", url.host == "symbol" else { return }
            if let symbol = url.pathComponents.dropFirst().first {
                path = [symbol.uppercased()]
            }
        }
    }
}

extension StocksTrackerRootView {
    static let defaultSymbols: [String] = [
        "AAPL", "GOOG", "TSLA", "AMZN", "MSFT", "NVDA", "META", "NFLX", "ORCL", "INTC",
        "AMD", "IBM", "AVGO", "ADBE", "CSCO", "CRM", "SAP", "SONY", "BABA", "PYPL",
        "UBER", "LYFT", "SHOP", "SQ", "TWTR"
    ]

    static let defaultDescriptions: [String: String] = [
        "AAPL": "Apple Inc. designs and sells consumer electronics.",
        "GOOG": "Alphabet is Google's parent company, leading in search.",
        "TSLA": "Tesla builds electric vehicles and clean energy solutions.",
        "AMZN": "Amazon is a global e-commerce and cloud computing giant.",
        "MSFT": "Microsoft creates software, hardware, and cloud services.",
        "NVDA": "NVIDIA designs graphics and AI computing platforms.",
        "META": "Meta Platforms builds social networking technologies.",
        "NFLX": "Netflix streams movies and television series worldwide.",
        "ORCL": "Oracle delivers database software and cloud systems.",
        "INTC": "Intel develops semiconductor chips and processors.",
        "AMD": "Advanced Micro Devices produces CPUs and GPUs.",
        "IBM": "IBM offers enterprise hardware, software, and services.",
        "AVGO": "Broadcom designs semiconductors for networking and storage.",
        "ADBE": "Adobe delivers creative and digital media software.",
        "CSCO": "Cisco provides networking hardware and telecommunications.",
        "CRM": "Salesforce offers cloud-based CRM solutions.",
        "SAP": "SAP builds enterprise software for business operations.",
        "SONY": "Sony produces electronics, gaming consoles, and entertainment.",
        "BABA": "Alibaba runs e-commerce and cloud computing platforms.",
        "PYPL": "PayPal enables digital payments worldwide.",
        "UBER": "Uber offers ride-sharing and food delivery services.",
        "LYFT": "Lyft provides transportation solutions via mobile apps.",
        "SHOP": "Shopify powers e-commerce for online retailers.",
        "SQ": "Block (Square) offers financial and merchant services.",
        "TWTR": "Twitter is a microblogging and social networking service."
    ]
}
