//
//  NavigationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct MainNavigationView: View {

    @Environment (\.horizontalSizeClass) private var horizontalSize
    @StateObject var navigationState = NavigationState()

    var body: some View {
        switch horizontalSize{
        case .compact:
            NavigationStack{
                TabbarView()
            }
        case .regular:
            SidebarView()
                .environmentObject(navigationState)
        case .none:
            SidebarView()
                .environmentObject(navigationState)
        default:
            Text("Regular")
        }
    }
}

#Preview {
    MainNavigationView()
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}
