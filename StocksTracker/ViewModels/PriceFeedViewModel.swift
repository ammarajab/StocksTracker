//
//  PriceFeedViewModel.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import Combine
import Foundation

@MainActor
final class PriceFeedViewModel: ObservableObject {
    @Published private(set) var quotes: [StockQuote]
    @Published private(set) var connectionStatus: ConnectionStatus = .disconnected
    @Published private(set) var isRunning = false

    private let service: PriceStreaming
    private var cancellables = Set<AnyCancellable>()
    private let descriptions: [String: String]

    init(service: PriceStreaming, symbols: [String], descriptions: [String: String]) {
        self.service = service
        self.descriptions = descriptions
        self.quotes = symbols.map { symbol in
            let description = descriptions[symbol] ?? "A leading technology company."
            return StockQuote(symbol: symbol, price: Double.random(in: 100...500), description: description)
        }
        self.quotes.sort { $0.price > $1.price }
        bind()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        service.start()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false
        service.stop()
    }

    func quote(for symbol: String) -> StockQuote? {
        quotes.first(where: { $0.symbol == symbol })
    }

    private func bind() {
        service.updates
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.apply(update: update)
            }
            .store(in: &cancellables)

        service.status
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.connectionStatus = status
                if status == .disconnected {
                    self?.isRunning = false
                }
            }
            .store(in: &cancellables)
    }

    private func apply(update: PriceUpdate) {
        guard let index = quotes.firstIndex(where: { $0.symbol == update.symbol }) else { return }
        var quote = quotes[index]
        let movement: PriceMovement
        if update.price > quote.price {
            movement = .up
        } else if update.price < quote.price {
            movement = .down
        } else {
            movement = .none
        }
        quote.price = update.price
        quote.lastMovement = movement
        quote.lastUpdated = Date()
        quotes[index] = quote
        quotes.sort { $0.price > $1.price }
    }
}
