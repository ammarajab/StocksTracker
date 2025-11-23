//
//  StockRowView.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import SwiftUI

struct StockRowView: View {
    let viewModel: StockRowViewModel
    @State private var isPulsing = false

    var body: some View {
        HStack {
            Text(viewModel.symbolText)
                .font(.headline)
            Spacer()
            Text(viewModel.priceText)
                .font(.headline)
                .foregroundStyle(viewModel.changeColor)
            Text(viewModel.changeIndicator)
                .font(.caption)
                .foregroundStyle(viewModel.changeColor)
                .scaleEffect(isPulsing ? 1.5 : 1)
                .animation(.bouncy, value: isPulsing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .onChange(of: viewModel.priceText) { _,_ in
            triggerPulse()
        }
    }

    private func triggerPulse() {
        isPulsing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isPulsing = false
        }
    }
}
