//
//  LocationDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 18/12/2023.
//

import SwiftUI

struct LocationDetailView: View {
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
                        VStack{
                            Text(locationState.currentLocation?.city ?? "Nuremberg")
                        }
                        .onTapGesture {
                            navigationState.tabbarSelection = .currentLocation
                            isFullScreenView.toggle()
                        }
                    }
                    
                    ForEach(locationState.cities,id: \.self){city in
                        VStack{
                            Text(city.city)
                                .frame(maxWidth: .infinity,alignment: .leading)
                        }
                            .onTapGesture {
                                navigationState.tabbarSelection = .city(city)
                                isFullScreenView.toggle()
                            }
                    }
                }
            }
        }
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
    }
}

#Preview {
    @State var isViewFullScreen = false
    return LocationDetailView(isFullScreenView: $isViewFullScreen)
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}
