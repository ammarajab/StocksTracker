//
//  SymbolDetailView.swift
//  StocksTracker
//
//  Created by Ammar on 23/11/2025.
//

import SwiftUI

struct SymbolDetailView: View {
    let viewModel: SymbolDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.symbolText)
                .font(.largeTitle)
                .fontWeight(.bold)
            HStack(spacing: 8) {
                Text(viewModel.priceText)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(viewModel.changeColor)
                    .padding(6)
                Text(viewModel.changeIndicator)
                    .font(.title2)
                    .foregroundStyle(viewModel.changeColor)
                    .padding(6)
            }
            Text(viewModel.descriptionText)
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle("Symbol Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
