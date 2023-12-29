//
//  ManualLocationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI
import CoreLocation

// Custom SearchBar view
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.primary)
            
            // You can add a search icon or cancel button here if needed
        }
    }
}

struct ManualLocationView: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Environment (\.colorScheme) private var colorScheme
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @Binding var isSheet:Bool
    @Binding var searchable:String
    @Binding var isDetailView:Bool
    
    @State private var countryName = ""
    @State private var cityName = ""
    @State var dropDownList:[Location] = []
    @State private var selectedLocation: Location? = nil
    @State private var isAddCitySheet = false

    
    
    var body: some View {
                VStack {
//                    SearchBar(text: $searchable) // Assuming you have a custom SearchBar
//                        .padding(.horizontal)
//                        .padding(.bottom, 8)
                    
                    List {
                        ForEach(dropDownList.filter({ searchable.isEmpty ? true : $0.city!.localizedStandardContains(searchable) }), id: \.self.id) { item in
                                Button(action: {
                                    selectedLocation = item
                                    selectLocation()
                                }, label: {
                                    VStack(alignment: .leading){
                                        Text(item.city ?? "")
                                            .font(.headline)
                                        Text(item.country ?? "")
                                            .font(.subheadline)
                                            .foregroundColor(Color.secondary)
                                    }
                                    .frame(maxWidth: .infinity,alignment: .leading)
                                })
                                .tint(.clear)
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .listStyle(.plain)
                }
                .sheet(isPresented: $isAddCitySheet) {
                    if let location = selectedLocation {
                        NavigationStack {
                            PrayerDetailView(selectedLocation: location)
                                .navigationTitle(location.city ?? "Nuremberg")
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button(action: {
                                            isAddCitySheet = false
                                        }, label: {
                                            Text("Cancel")
                                        })
                                    }
                                    ToolbarItem(placement: .confirmationAction) {
                                        Button(action: {
                                            addLocation()
                                            isAddCitySheet = false
                                        }, label: {
                                            Text("Add")
                                        })
                                    }
                                }
                        }
                    }
                }
            .onAppear {
                parseLocalJSONtoFetchLocations()
            }
        }
    
    func selectLocation() {
        getTimeZone(lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0) { location in
            selectedLocation = location
            isAddCitySheet = true
        }
    }
    
    func addLocation() {
       
        locationState.cities.append(selectedLocation ?? Location())
        print(locationState.cities)
        print(selectedLocation)
        if let location = locationState.cities.last {
            navigationState.tabbarSelection = .location(selectedLocation ?? Location())
            navigationState.sidebarSelection = .location(selectedLocation ?? Location())
        }
        dismissSearch()
        isSheet.toggle()
        isDetailView.toggle()
    }
    
    func getTimeZone(lat: Double, long: Double, completion: @escaping (Location?) -> Void) {
        let offset = TimeZone.current.secondsFromGMT()
        print(offset) // Your current timezone offset in seconds
        
        let loc = CLLocation(latitude: lat, longitude: long)
        let coder = CLGeocoder()
        
        coder.reverseGeocodeLocation(loc) { (placemarks, error) in
            guard let place = placemarks?.last else {
                completion(nil)
                return
            }
            
            
            getTimeZone(lat: lat, long: long) { location in
                selectedLocation?.todayPrayerTimings = location?.todayPrayerTimings
                selectedLocation?.tomorrowPrayerTimings = location?.tomorrowPrayerTimings
                selectedLocation?.todaySunTimings = location?.todaySunTimings
                selectedLocation?.tomorrowSunTimings = location?.tomorrowSunTimings
                selectedLocation?.nextPrayer = location?.nextPrayer
            }
            selectedLocation?.lat = lat
            selectedLocation?.lng = long
            selectedLocation?.city = place.locality
            selectedLocation?.country = place.country
            selectedLocation?.dateTime = Date()
            print(place.timeZone)
            
            selectedLocation?.timeZone = place.timeZone
            if let secondsFromGMT = Double(place.timeZone?.secondsFromGMT() ?? 0) as? Double {
                let hours = secondsFromGMT / 3600
                selectedLocation?.offSet = hours
            } else {
                selectedLocation?.offSet = 0.0 // Default to 0.0 if an error occurs or no timezone information is available
            }
//            selectedLocation = updatedLocation
            completion(selectedLocation)
        }
        isSheet.toggle()

    }
    
//    func getTimeZone(lat: Double, long: Double, completion: @escaping (Location?) -> Void) {
//        let offset = TimeZone.current.secondsFromGMT()
//        print(offset) // Your current timezone offset in seconds
//        
//        let loc = CLLocation(latitude: lat, longitude: long)
//        let coder = CLGeocoder()
//
//        coder.reverseGeocodeLocation(loc) { (placemarks, error) in
//            guard let place = placemarks?.last else {
//                completion(nil)
//                return
//            }
//            
//            var location = Location( prayerTimings: <#[PrayerTiming]#>)
//            location.lat = lat
//            location.lng = long
//            location.city = place.locality
//            location.country = place.country
//            location.timezone = place.timeZone
//            location.dateTime = Date().getCurrentDateTime(for: place.country ?? "Makkah")
//            print(location.city)
//            
////            if let secondsFromGMT = Double(place.timeZone?.secondsFromGMT() ?? 0) as? Double {
////                let hours = secondsFromGMT / 3600
////                location.timezone = hours
////            } else {
////                location.timezone = 0.0 // Default to 0.0 if an error occurs or no timezone information is available
////            }
//            
//            completion(location)
//        }
//    }
//    
    func parseLocalJSONtoFetchLocations() {
        if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: fileUrl)
                let location = try? JSONDecoder().decode([Location].self, from: jsonData)
                dropDownList = location ?? []
                
            } catch {
                print("Error parsing JSON: \(error)")
            }
        } else {
            print("File not found")
        }
    }
}

#Preview {
    @State var isSheet = false
    @State var isDetailView = true

    @State var searching = ""
    return ManualLocationView(isSheet: $isSheet,searchable: $searching, isDetailView: $isDetailView)
        .environmentObject(LocationState())
}
