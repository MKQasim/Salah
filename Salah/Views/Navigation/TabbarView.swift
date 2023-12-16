//
//  TabbarView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct TabbarView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject var locationState: LocationState
    @State private var selectionTabbar = 0
    @State private var isSheet = false
    
    var body: some View {
        TabView(selection: $navigationState.tabbarSelection) {
            if locationManager.locationStatus == .denied {
                if locationState.cities.count == 0 {
                    VStack{
                        Text("Add Location to View screen")
                    }
                    .tag(NavigationItem.nocurrentLocation)
                }
            }
            else{
//                if locationState.isLocation {
//                    PrayerDetailView(city: Cities(country: "", city: "Nuremberg", lat: 43.33, long: 19.23, timeZone)))
//                        .navigationTitle("Nuremberg")
//                        .tag(NavigationItem.currentLocation)
//                        .tabItem {
//                            Label("Current Location", systemImage: "location.fill")
//                        }
//                }
            }
            ForEach(locationState.cities, id: \.self){location in
                VStack{
                    PrayerDetailView(city: location)
                }
                .navigationTitle(location.city ?? "Title")
                .tag(NavigationItem.city(location))
            }
        }
        #if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .fullScreenCover(isPresented: $isSheet, content: {
            NavigationStack{
                ManualLocationView(isSheet: $isSheet)
                    .toolbar{
                        ToolbarItem(placement: .cancellationAction, content: {
                            Button(action: {
                                isSheet.toggle()
                            }, label: {
                                Text("Cancel")
                            })
                        })
                    }
            }
            
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
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}
