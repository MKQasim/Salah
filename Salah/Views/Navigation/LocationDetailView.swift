//
//  LocationDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 18/12/2023.
//

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
                Task{
                    if let location = location {
                        viewModel.fetchNextPrayerTime(for: location) { location in
                            viewModel.updateCounter(for: location)
                        }
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(UIColor.lightGray))
                .shadow(radius: 3)
        )
    }
    
    private func setupTimer(with prayerTiming: PrayerTiming?) {
        guard let prayerTiming = prayerTiming , let endDate = prayerTiming.time else { return }
        let currentDate = Date().getDateFromDecimalTimeZoneOffset(decimalOffset: location?.offSet ?? 0.0)
        guard let startDate = prayerTiming.updatedDateFormatAndTimeZoneString(for: currentDate, withTimeZoneOffset: location?.offSet ?? 0.0, calendarIdentifier: .gregorian)?.date else { return }
       
        startDate.startCountdownTimer(from: startDate, to: endDate) { formattedTime in
            self.viewModel.remTime = formattedTime
        }
    }
}

class PrayerTimeViewModel: ObservableObject {
    
    @Published var nextSalah: String = "" {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            // This will trigger UI updates in SwiftUI
        }
    }
    
    @Published var remTime: String = ""
    @Published var timeNow: String = ""
    @State private var selectedPrayer: PrayerTiming? = nil
    @State var selectedLocation: Location?
    @State private var targetDate: Date?
    @State private var startDate: Date?
    var prayerTimeHelper = PrayerTimeHelper.shared // Assuming PrayerTimeHelper is shared across instances
    
    func fetchNextPrayerTime(for location: Location?, completion: @escaping (Location) -> Void) {
        guard let location = location else { return }
        PrayerTimeHelper.shared.getSalahTimings(location: location) { [weak self] location in
            guard let self = self, let nextPrayer = location?.nextPrayer else { return }
            self.selectedLocation = location
            self.nextSalah = "\(nextPrayer.name ?? "") at \(nextPrayer.formatDateString(nextPrayer.time ?? Date()))"
            self.selectedPrayer = nextPrayer
            self.targetDate = nextPrayer.time
            completion(location ?? Location())
        }
    }

    func updateCounter(for location: Location?) {
        self.timeNow = "\(Date().updatedDateFormatAndTimeZone(for: Date(), withTimeZoneOffset: location?.offSet ?? 0.0, calendarIdentifier: .islamicCivil)?.formattedString ?? "")"
        let currentDate = Date().getDateFromDecimalTimeZoneOffset(decimalOffset: location?.offSet ?? 0.0)
        let startDate = location?.nextPrayer?.updatedDateFormatAndTimeZoneString(for: currentDate, withTimeZoneOffset: location?.offSet ?? 0.0, calendarIdentifier: .gregorian)?.date
        guard let endDate = location?.nextPrayer?.time , let unwrappedStartDate = startDate else { return }
        startDate?.startCountdownTimer(from: unwrappedStartDate, to: endDate) { formattedTime in
            self.remTime = formattedTime
        }
    }
}


#Preview {
    @State var isViewFullScreen = false
    return LocationDetailView(isFullScreenView: $isViewFullScreen)
        .environmentObject(LocationState())
        .environmentObject(NavigationState())
}


