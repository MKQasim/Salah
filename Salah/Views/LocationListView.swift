//
//  LocationListView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

struct LocationListView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    var body: some View {
        VStack(spacing: 0) {
            List(selection: $viewModel.selectedItem) {
                ForEach(viewModel.locations, id: \.id) { location in
                    ListItem(item: location)
                        .swipeActions(edge: .trailing) {
                            Button {
                                viewModel.deleteItem(location)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    .onTapGesture {
                        viewModel.selectedItem = location
                        viewModel.tabViewModel.isListMode = false
                        print("LocationListView selectedItemId: \(viewModel.selectedItem?.id ?? 0)")
                    }
                }
            }
            .listStyle(PlainListStyle())
            .padding(.horizontal, 16) // Adjust this value as needed
            .cornerRadius(20)
            .padding(.top, 0) // Adjust this value as needed
            .navigationTitle(viewModel.tabViewModel.tapTitle)
            .onAppear{
                if viewModel.selectedItem == nil {
                    viewModel.selectedItem = viewModel.locations.first
                    viewModel.tabViewModel.isListMode = true
                   
                }
            }
        }
    }
}
