//
//  LocationDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 18/12/2023.
//

import SwiftUI
import SwiftUI

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
                        ListRowCellView(isFullScreenView: $isFullScreenView, location: currentLocation, isCurrent: true)
                    }

                    ForEach(locationState.cities, id: \.self) { location in
                        ListRowCellView(isFullScreenView: $isFullScreenView, location: location, isCurrent: false)
                    }
                }
            }
            
//            .listRowSeparator(.hidden, edges: .all)
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
//            ToolbarItem(placement: .navigationBarTrailing) {
////                 NavigationLink(destination: SettingsView(), label: {
////                     Label("Settings", systemImage: "gear.circle").foregroundColor(.white)
////                 })
//            }
        }
    }
}

struct ListRowCellView: View {
    @EnvironmentObject var navigationState: NavigationState
    @Binding var isFullScreenView: Bool
    var location: Location?
    let isCurrent: Bool
    @StateObject var viewModel = PrayerTimeViewModel()

    var body: some View {
        VStack {
            Button(action: {
                if isCurrent {
                    navigationState.tabbarSelection = .currentLocation
                } else {
                    navigationState.tabbarSelection = .location(location ?? Location())
                }
                isFullScreenView.toggle()
            }, label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(location?.city ?? "")
                            .font(.headline)
                        Text(location?.country ?? "")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text(viewModel.nextSalah) // Display nextSalah from the ViewModel
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Text(viewModel.remTime)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.lightGray))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
            })
            .buttonStyle(.plain)
            .cornerRadius(8)
            .padding(5)
            .onAppear {
                // Fetch the next prayer time when the view appears
                print(location?.country)
                viewModel.fetchNextPrayerTime(for: location)
            }
        }
    }
}

class PrayerTimeViewModel: ObservableObject {
    @Published var nextSalah: String = ""
    @Published var remTime: String = ""

    var prayerTimeHelper = PrayerTimeHelper.shared // Assuming PrayerTimeHelper is shared across instances

    func fetchNextPrayerTime(for location: Location?) {
        prayerTimeHelper.findNextPrayerTime(now: Date(), selectedLocation: location ?? Location()) { nextPrayerTime in
            if let prayerTime = nextPrayerTime {
                let prayerTimeName = prayerTime.name ?? ""
                let prayerTimeValue = prayerTime.time ?? ""
                self.nextSalah = "\(prayerTimeName) at \(prayerTimeValue)"
                
                // Start the timer to update the remaining time for this specific cell
                self.startTimerToUpdateRemainingTime(for: location)
            } else {
                print("No prayer time found or an error occurred.")
                self.nextSalah = "No prayer time found"
            }
        }
    }

    // Function to start the timer to update the remaining time
    func startTimerToUpdateRemainingTime(for location: Location?) {
        // Assuming each instance manages its own timer
        prayerTimeHelper.startTimerToUpdatePrayerTime(for: location) { remainingTime in
            DispatchQueue.main.async {
                self.remTime = remainingTime ?? ""
            }
        }
    }

    // Stop timer if needed (when the view disappears, etc.)
    func stopTimer() {
        prayerTimeHelper.stopTimer()
    }
}



#Preview {
    @State var isViewFullScreen = false
    return LocationDetailView(isFullScreenView: $isViewFullScreen)
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}


