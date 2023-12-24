//
//  LocationDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 18/12/2023.
//

import SwiftUI

struct LocationDetailView: View {
    @Environment (\.colorScheme) var colorScheme
    @Environment (\.isSearching) var isSearching
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @State private var isSheet = false
    @State private var searchableText = ""
    
    @Binding var isFullScreenView:Bool
    var body: some View {
        List{
            Group{
                if !isSearching {
                    if locationState.currentLocation != nil {
                        ListRowCellView(navigationItem: .currentLocation, city: locationState.currentLocation ?? Cities(city: "No City", lat: 49.19, long: 19.11, offSet: +1.0))
                    }
                    
                    ForEach(locationState.cities,id: \.self){city in
                        ListRowCellView(navigationItem: .city(city), city: city)
                    }
                }
            }
#if !os(watchOS)
            .listRowSeparator(.hidden, edges: .all)
#endif
        }
#if !os(watchOS)
        .listStyle(.plain)
#endif
        .navigationTitle("Cities")
        .searchable(text: $searchableText, prompt: "Search for a city")
        .overlay{
            ZStack{
                if locationState.cities.count == 0 && locationState.currentLocation == nil {
                    VStack{
                        Text("List of cities for prayers is currently empty. \n Please add desired city.")
                            .foregroundStyle(.gray)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                }
                if !searchableText.isEmpty {
                    VStack{
                        ManualLocationView(isSheet: $isSheet,searchable: $searchableText, isDetailView: $isFullScreenView)
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
                    .background(.thinMaterial)
                }
            }
        }
        .toolbar {
#if !os(watchOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(), label: {
                    Label("Settings", systemImage: "gear.circle")
                })
            }
#endif
        }
    }
    
    @ViewBuilder
    func ListRowCellView(navigationItem: NavigationItem, city: Cities) -> some View {
        Button(action: {
            navigationState.tabbarSelection = navigationItem
            isFullScreenView.toggle()
        }, label: {
            HStack{
                VStack(alignment: .leading){
                    Text(city.city)
                    //                    Text("Dec 21 12:10")
                    //                        .foregroundStyle(.gray)
                }
                Spacer()
                //                VStack(alignment: .trailing){
                //                    Text("Next Salah Asr")
                //                    Text("In 10 mins")
                //                }
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .foregroundStyle(colorScheme == .light ? .black : .white)
            .cornerRadius(5)
        })
        .background(LinearGradient(colors: [.journal, .journal2], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(5)
        .padding(5)
        .background(navigationState.tabbarSelection == navigationItem ? .gray : .clear)
        .buttonStyle(.borderless)
        .cornerRadius(5)
    }
    
}

#Preview {
    @State var isViewFullScreen = false
    return LocationDetailView(isFullScreenView: $isViewFullScreen)
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}
