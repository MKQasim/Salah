//
//  LocationDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 18/12/2023.
//

import SwiftUI
import Combine

struct LocationDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isSearching) var isSearching
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @State private var isSheet = false
    @State private var searchableText = ""
    @Binding var isFullScreenView: Bool
    
    var body: some View {
        List {
            Group {
                if !isSearching {
                    if let currentLocation = locationState.currentLocation {
                        DetailLocationListRowCellView(isFullScreenView: $isFullScreenView, location: currentLocation, isCurrent: true)
                    }
                    
                    ForEach(locationState.cities, id: \.self) { location in
                        DetailLocationListRowCellView(isFullScreenView: $isFullScreenView, location: location, isCurrent: false)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Cities")
        .searchable(text: $searchableText, prompt: "Search for a city")
        .overlay {
            ZStack {
                if locationState.cities.isEmpty && locationState.currentLocation == nil {
                    VStack {
                        Text("List of cities for prayers is currently empty. \n Please add a desired city.")
                            .foregroundColor(.gray)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                }
                if !searchableText.isEmpty {
                    VStack {
                        ManualLocationView(isSheet: $isSheet, searchable: $searchableText, isDetailView: $isFullScreenView)
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button(action: {
                                        isSheet.toggle()
                                    }, label: {
                                        Text("Cancel")
                                    })
                                }
                            }
                    }
                    .background(.thinMaterial)
                }
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(), label: {
                    Label("Settings", systemImage: "gear.circle").foregroundColor(.gray)
                }).foregroundColor(.gray)
            }
#endif
        }
    }
}

#Preview {
    @State var isViewFullScreen = false
    return LocationDetailView(isFullScreenView: $isViewFullScreen)
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}


