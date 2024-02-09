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
                    ForEach(locationState.cities, id: \.self) { location in
                        DetailLocationListRowCellView(isFullScreenView: $isFullScreenView, location: location, isCurrent: false)
                    }
                    .onDelete(perform: delete)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Cities")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 50)
                
            }
        }
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
                        ManualLocationView(
                            searchable: $searchableText,
                            isDetailView: $isFullScreenView,
                            onDismiss: {
                                // Handle the dismissal of ManualLocationView, e.g., pop the view
                                isFullScreenView = false // Set the state variable to dismiss the view
                                // Additional logic for dismissal if needed
                                isSheet.toggle()
                            }
                        )
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(action: {
                                    isSheet.toggle()
                                }) {
                                    Text("Cancel")
                                }
                            }
                        }

                    }
                    .background(.thinMaterial)
                }
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    isFullScreenView.toggle()
                }, label: {
                    Label("Close", systemImage: "multiply")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SettingsView(), label: {
                    Label("Settings", systemImage: "gear.circle").foregroundColor(.gray)
                }).foregroundColor(.gray)
            }
#endif
        }
    }
    
    func delete(at offsets: IndexSet) {
        locationState.cities.remove(atOffsets: offsets)
    }

}

#Preview {
    @State var isViewFullScreen = false
    return LocationDetailView(isFullScreenView: $isViewFullScreen)
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}


