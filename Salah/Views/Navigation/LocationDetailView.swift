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
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                 NavigationLink(destination: SettingsView(), label: {
                     Label("Settings", systemImage: "gear.circle").foregroundColor(.gray)
                 })
            }
            #endif
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
                        Text("\(location?.city ?? "") \(location?.country ?? "")")
                            .font(.headline)
                        Text(viewModel.timeNow )
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
                Task{
                    await viewModel.fetchNextPrayerTime(for: location)
                }
            }
        }
        .background(
        RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.lightGray))
                .shadow(radius: 3)
        )
    }
}

class PrayerTimeViewModel: ObservableObject {
    @Published var nextSalah: String = "" {
        didSet {
            objectWillChange.send() // This will trigger UI updates in SwiftUI
        }
    }

    @Published var remTime: String = ""
    @Published var timeNow: String = ""

    var prayerTimeHelper = PrayerTimeHelper.shared // Assuming PrayerTimeHelper is shared across instances

    func fetchNextPrayerTime(for location: Location?) async {
        await PrayerTimeHelper.shared.getSalahTimings(location: location ?? Location(), completion: { location in
            guard let location = location else { return  }
         
            self.nextSalah = "\(location.nextPrayer?.name ?? "") at \(location.nextPrayer?.time ?? Date())"
            
            // Update UI or perform actions with the formattedTime
            let hours = location.offSet ?? 0.0 // get the hours from GMT as a Double
            let secondsFromGMT = Int(hours * 3600) // convert hours to seconds and cast to Int
            let timeZone = TimeZone(secondsFromGMT: secondsFromGMT) // create a TimeZone object
            
            guard let timeZone = timeZone else {
                // Handle the case where timeZone is nil
                // You might want to show an error message or handle this situation accordingly
                return
            }
            
            let currentDate = PrayerTimeHelper.shared.currentTime(for: timeZone, dateFormatString: "yyyy MMM d HH:mm").0
           
            self.timeNow = currentDate ?? ""
            
            
//            let countdownTimer = CountdownTimer(remainingTime: 0)
//            countdownTimer.startCountdownTimer(with: location.timeDifference ?? 0.0) { formattedTime in
//                print("Remaining Time: \(formattedTime)")
//                self.remTime = "Next Prayer In : \(formattedTime)"
//               
//                
//            }
            
        })
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


