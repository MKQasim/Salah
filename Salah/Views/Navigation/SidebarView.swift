//
//  SidebarView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct SidebarView: View {
    var body: some View {
        NavigationSplitView{
            
        } detail: {
            SalahDetailView()
        }
    }
}

#Preview {
    SidebarView()
}
