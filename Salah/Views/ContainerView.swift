//
//  ContainerView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

// MARK: - ContainerView
struct ContainerView: View {
    @ObservedObject var viewModel: ContentViewModel
    var navTitle : String = ""
    var body: some View {
        if viewModel.isQiblaSelected {
            // Qibla-specific view
            QiblaView()
        } else {
            DetailView()
        }
    }
}
