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
                .navigationTitle(viewModel.tabViewModel.tapTitle)
                .toolbar {
                    getToolbarItems()
                }
                .onChange(of: viewModel.tabViewModel.isListMode) { newValue in
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
        TabView(selection: Binding<Bool>(
            get: { self.viewModel.tabViewModel.isListMode ?? false },
            set: { self.viewModel.tabViewModel.isListMode = $0 }
        )) {
            createTab(isListMode: true)
            createTab(isListMode: false)
        }
    }

    @ViewBuilder
    private func createTab(isListMode: Bool) -> some View {
        getViewForTab(isListMode: isListMode)
            .tabItem {
                Label(viewModel.tabViewModel.tapTitle, systemImage: viewModel.tabViewModel.tapIcon)
            }
            .tag(isListMode)
    }

    @ViewBuilder
    private func getViewForTab(isListMode: Bool) -> some View {
        if isListMode {
            LocationListView()
        } else {
            ContainerView(viewModel: viewModel)
        }
    }

    private func getToolbarItems() -> some View {
        HStack {
            AddButton()
            LocationButton()
            QiblaButton()
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

