//
//  IPadView.swift
//  Salah
//
//  Created by Muhammad's on 19.03.24.
//

import Foundation
import SwiftUI

// MARK: - Spacific for IPadView
extension ContentView {
    var iPadView: some View {
        NavigationSplitView {
            SideView()
                .toolbar {
                ToolbarItem(placement: .automatic) {
                    LocationButton()
                }
                ToolbarItem(placement: .automatic) {
                    AddButton()
                }
            }.frame(minWidth: 240) // Set minimum width for Mac
        } detail: {
            ContainerView(viewModel: viewModel)
                .frame(minWidth: 400) // Set minimum width for Mac
        }
        .sheet(isPresented: $viewModel.isChooseCityViewPresented) {
            ChooseCityView(onDismiss: {
                print("ChooseCityView dismiss")
            })
                .environmentObject(viewModel)
                .navigationSplitViewColumnWidth(min: 180, ideal: 200)
                .frame(minWidth: 400, idealWidth: 600, minHeight: 400, idealHeight: 600, alignment: .center)
        }
        
        .navigationSplitViewStyle(.automatic)
    }
}
