//
//  AppButtons.swift
//  Salah
//
//  Created by Muhammad's on 19.03.24.
//

import Foundation
import SwiftUI

struct LocationButton : View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var viewModel: ContentViewModel
    var body : some View {
        Button {
            theme.primeryColor = .blue
            viewModel.tabViewModel.isListMode.toggle()
            viewModel.tabViewModel.tapIcon = viewModel.tabViewModel.isListMode ? "list.bullet.circle" : "square.arrowtriangle.4.outward"
            viewModel.tabViewModel.tapTitle = viewModel.tabViewModel.isListMode ? "Salah Locations List" : "Salah Location Details"
            viewModel.selectedItem = viewModel.selectedItem
        } label: {
            Image(systemName: viewModel.tabViewModel.isListMode ? "list.bullet.circle" : "square.arrowtriangle.4.outward")
        }
    }
}


struct QiblaButton : View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var viewModel: ContentViewModel
    var body : some View {
        Button {
            theme.primeryColor = .blue
            viewModel.isQiblaSelected.toggle()
            viewModel.tabViewModel.isListMode = false
            viewModel.tabViewModel.tapIcon = viewModel.isQiblaSelected ? "dot.arrowtriangles.up.right.down.left.circle" : "location.viewfinder"
            viewModel.tabViewModel.tapTitle = viewModel.isQiblaSelected ? "Salah Locations Qibla" : "Salah Location Details"
            viewModel.selectedItem = viewModel.selectedItem
        } label: {
            Image(systemName: viewModel.isQiblaSelected ? "dot.arrowtriangles.up.right.down.left.circle" : "location.viewfinder")
        }
    }
}

struct AddButton  : View{
    @EnvironmentObject var viewModel: ContentViewModel
    @EnvironmentObject var theme: Theme
    var body: some View{
        Button {
            theme.primeryColor = .red
            viewModel.isChooseCityViewPresented = true
        } label: {
            Image(systemName: "plus")
        }
    }
}

struct SettingsButton  : View{
    @EnvironmentObject var viewModel: ContentViewModel
    @EnvironmentObject var theme: Theme
    var body: some View{
        Button {
            theme.primeryColor = .red
            viewModel.isSettingsViewPresented = true
        } label: {
            Image(systemName: "gear")
        }
    }
}
