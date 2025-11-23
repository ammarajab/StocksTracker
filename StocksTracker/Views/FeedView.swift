//
//  FeedView.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: PriceFeedViewModel
    var onSelectSymbol: (String) -> Void

    var body: some View {
        VStack {
            topBar
            List(viewModel.quotes) { quote in
                StockRowView(viewModel: StockRowViewModel(quote: quote))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelectSymbol(quote.symbol)
                    }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Feed")
        .toolbarTitleDisplayMode(.inline)
    }

    private var topBar: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(color(for: viewModel.connectionStatus))
                    .frame(width: 10, height: 10)
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: toggleFeed) {
                Text(viewModel.isRunning ? "Stop" : "Start")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private func toggleFeed() {
        if viewModel.isRunning {
            viewModel.stop()
        } else {
            viewModel.start()
        }
    }

    private var statusText: String {
        switch viewModel.connectionStatus {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        }
    }

    private func color(for status: ConnectionStatus) -> Color {
        switch status {
        case .connected:
            return .green
        case .connecting:
            return .orange
        case .disconnected:
            return .red
        }
    }
}
