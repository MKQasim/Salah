//
//  TabbarView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct TabbarView: View {
    
    @EnvironmentObject var locationState: LocationState
    @State private var selectionTabbar = 0
    @State private var isSheet = false
    
    init(){
#if os(iOS)
        let coloredAppearance = UIToolbarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .orange.withAlphaComponent(0.1)
              UIToolbar.appearance().standardAppearance = coloredAppearance
        UIToolbar.appearance().compactAppearance = coloredAppearance
        UIToolbar.appearance().scrollEdgeAppearance = coloredAppearance
        UIToolbar.appearance().tintColor = .red
#endif
    }
    
    var body: some View {
        TabView(selection: $selectionTabbar) {
            if locationState.isLocation {
                PrayerDetailView(city: Cities(city: "Nuremberg", lat: 43.33, long: 19.23, timeZone: 1.0))
                    .tag(0)
                    .tabItem {
                        Label("Current Location", systemImage: "location.fill")
                    }
            }
            ForEach(locationState.cities, id: \.self){location in
                VStack{
                    PrayerDetailView(city: location)
                }
                .tag(location)
            }
        }
        #if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .fullScreenCover(isPresented: $isSheet, content: {
            ManualLocationView(isSheet: $isSheet)
        })
        #endif
        .toolbar {
            #if !os(macOS)
            ToolbarItemGroup(placement: .bottomBar){
                    Spacer()
                    Button(action: {
                        isSheet.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.subheadline)
                    }
            }
            #endif
        }
    }
}

#Preview {
    TabbarView()
}
