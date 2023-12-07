//
//  NavigationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct MainNavigationView: View {
    
    @Environment (\.horizontalSizeClass) private var horizontalSize
    
    var body: some View {
        switch horizontalSize{
        case .compact:
            SalahDetailView()
        case .regular:
            SidebarView()
        case .none:
            SidebarView()
        default:
            Text("Regular")
        }
    }
}

#Preview {
    MainNavigationView()
}
