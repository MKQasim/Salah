//
//  IPhoneView.swift
//  Salah
//
//  Created by Muhammad's on 19.03.24.
//

import Foundation
import SwiftUI
import SwiftData



extension ContentView {
    var iPhoneView: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            createTabView()
                .toolbar {
                    toolbarContent()
                }.toolbarTitleDisplayMode(.large)
                .onChange(of: viewModel.tabViewModel.isListMode) { _ , newValue in
                    print(newValue)
                }
                .onChange(of: viewModel.permissionManager.locationManager?.lastLocation) { _, newValue in
                    print(newValue)
                }
                .sheet(isPresented: $viewModel.isChooseCityViewPresented) {
                    getSheetView()
                }
        }
    }

    @ViewBuilder
    private func createTabView() -> some View {
        VStack {
            getViewForTab(isListMode: viewModel.tabViewModel.isListMode)
            HStack {
                Spacer()
                BottomTapButton()
                .padding(.bottom, 20)
                .padding(.trailing, 30)
            }
        }
    }

    @ViewBuilder
    private func getViewForTab(isListMode: Bool) -> some View {
        if isListMode {
            LocationListView()
        } else {
            ContainerView(viewModel: viewModel)
        }
    }

    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            AddButton()
        }
        
        ToolbarItem(placement: .topBarLeading) {
            LocationButton()
        }
        
        ToolbarItem(placement: .topBarLeading) {
            QiblaButton()
        }
        
        ToolbarItem(placement: .principal) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 50)
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(destination: SettingsView(), isActive: $viewModel.isSettingsViewPresented) {
                SettingsButton()
            }
        }
    }

    private func getSheetView() -> some View {
        ChooseCityView(onDismiss: {
            print("ChooseCityView dismiss")
        })
        .environmentObject(viewModel)
        .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        .frame(minWidth: 400, idealWidth: 600, minHeight: 400, idealHeight: 600, alignment: .center)
    }
}

