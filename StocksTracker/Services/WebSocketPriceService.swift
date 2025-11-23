//
//  WebSocketPriceService.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import Combine
import Foundation

protocol PriceStreaming {
    var updates: AnyPublisher<PriceUpdate, Never> { get }
    var status: AnyPublisher<ConnectionStatus, Never> { get }
    func start()
    func stop()
}

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
}

final class WebSocketPriceService: PriceStreaming {
    private let url = URL(string: "wss://ws.postman-echo.com/raw")!
    private let symbols: [String]
    private let basePrices: [String: Double]
    private let updatesSubject = PassthroughSubject<PriceUpdate, Never>()
    private let statusSubject = CurrentValueSubject<ConnectionStatus, Never>(.disconnected)
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    private var task: URLSessionWebSocketTask?
    private let session: URLSession
    private var latestPrices: [String: Double]

    var updates: AnyPublisher<PriceUpdate, Never> {
        updatesSubject.eraseToAnyPublisher()
    }

    var status: AnyPublisher<ConnectionStatus, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    init(symbols: [String]) {
        self.symbols = symbols
        var defaults = [String: Double]()
        for symbol in symbols {
            defaults[symbol] = Double.random(in: 100...500)
        }
        self.basePrices = defaults
        self.latestPrices = defaults
        self.session = URLSession(configuration: .default)
    }

    func start() {
        guard task == nil else { return }
        statusSubject.send(.connecting)
        task = session.webSocketTask(with: url)
        task?.resume()
        receive()
        startTimer()
    }

    func stop() {
        timer?.cancel()
        timer = nil
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        statusSubject.send(.disconnected)
    }

    private func startTimer() {
        timer = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.sendBatchUpdates()
            }
    }

    private func sendBatchUpdates() {
        guard let task else { return }
        symbols.forEach { symbol in
            let current = latestPrices[symbol] ?? basePrices[symbol] ?? 100
            let delta = Double.random(in: -5...5)
            let newPrice = max(1, (current + delta).rounded(toPlaces: 2))
            latestPrices[symbol] = newPrice
            let update = PriceUpdate(symbol: symbol, price: newPrice, timestamp: Date())
            send(update: update, through: task)
        }
    }

    private func send(update: PriceUpdate, through task: URLSessionWebSocketTask) {
        guard let data = try? JSONEncoder().encode(update),
              let text = String(data: data, encoding: .utf8) else { return }
        task.send(.string(text)) { [weak self] error in
            if let error {
                self?.statusSubject.send(.disconnected)
            }
        }
    }

    private func receive() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                statusSubject.send(.disconnected)
            case .success(let message):
                statusSubject.send(.connected)
                handle(message: message)
            }
            if self.task != nil {
                self.receive()
            }
        }
    }

    private func handle(message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            if let data = text.data(using: .utf8),
               let update = try? JSONDecoder().decode(PriceUpdate.self, from: data) {
                updatesSubject.send(update)
            }
        case .data(let data):
            if let update = try? JSONDecoder().decode(PriceUpdate.self, from: data) {
                updatesSubject.send(update)
            }
        @unknown default:
            break
        }
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
