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
        VStack {
            Text("Current Location")
                .font(.title)
                .foregroundColor(.white)
                .padding(.top, 20)
            Spacer()
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
            .padding(.horizontal, 16)
            .cornerRadius(20)
            .padding()
            .onAppear{
                if viewModel.selectedItem == nil {
                    viewModel.selectedItem = viewModel.locations.first
                    viewModel.tabViewModel.isListMode = true
                    print(viewModel.selectedItem )
                }
            }
//            .toolbar {
//                ToolbarItem(placement: .automatic) {
//                    Button(action: {
//
//                        if viewModel.locations.count < 7 {
//                            print("viewModel.locations.count : \(viewModel.locations.count)")
//                            viewModel.isChooseCityViewPresented = true
//                        } else {
//                            viewModel.showAlert = true
//                        }
//
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
            
//            .alert(isPresented: $viewModel.showAlert) {
//                Alert(
//                    title: Text("Location Limit Reached"),
//                    message: Text("You have reached the maximum limit of \(viewModel.locations.count) locations. Please remove an existing location to add a new one."),
//                    dismissButton: .default(
//                        Text("Understood"),
//                        action: {
//                            // Add action here if needed
//                            print("Understood")
//                        }
//                    )
//                )
//            }
//
//
//            .toolbar {
//                ToolbarItem(placement: .automatic) {
//                    Button(action: viewModel.qiblaView) {
//                        Image(systemName: viewModel.isQiblaSelected ? "location.fill" : "location")
//
//                    }
//                }
//            }
            
        }
    }
}

