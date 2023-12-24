//
//  ManualLocationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI
import CoreLocation

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
        Form{
            List{
                ForEach(dropDownList.filter({searchable.isEmpty ? true : $0.city!.localizedStandardContains(searchable)}), id: \.self.id){item in
                    Button(action: {
                        selectedLocation = item
                        selectLocation()
                    }, label: {
                        VStack(alignment: .leading){
                            Text(item.city ?? "")
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Text(item.country ?? "")
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity,alignment:.leading)
                        
//                        Spacer()
//                        if (selectedLocation == item) {
//                            Image(systemName: "checkmark").foregroundStyle(.blue)
//                        }
                    })
                    .frame(maxWidth: .infinity,alignment:.leading)
                    .buttonStyle(.borderedProminent)
                    .padding([.leading,.trailing],0)
                    .tint(.clear)
                    
                }
            }
        }
        .navigationTitle("Manual Location")
        //#if !os(macOS) && !os(watchOS)
        //        .searchable(text: $searchable,placement: .navigationBarDrawer(displayMode: .always))
        //        .navigationBarTitleDisplayMode(.large)
        //#endif
        .toolbar{
            ToolbarItemGroup(placement: .confirmationAction){
                if selectedLocation != nil {
                    Button(action: {
                        selectLocation()
                    }, label: {
                        Text("Done")
                    })
                }
            }
        }
        .sheet(isPresented: $isAddCitySheet){
            NavigationStack{
                PrayerDetailView(city: Cities(city: selectedLocation?.city ?? "Nuremberg", lat: selectedLocation?.lat ?? 49.11, long: selectedLocation?.lng ?? 19.11, offSet: selectedLocation?.offSet ?? 0.0))
                    .navigationTitle(selectedLocation?.city ?? "Nuremberg")
                    .toolbar{
                        ToolbarItem(placement: .cancellationAction, content: {
                            Button(action: {
                                isAddCitySheet = false
                            }, label: {
                                Text("Cancel")
                            })
                        })
                        ToolbarItem(placement: .confirmationAction, content: {
                            Button(action: {
                                addLocation()
                                isAddCitySheet = false
                            }, label: {
                                Text("Add")
                            })
                        })
                    }
            }
        }
        .onAppear{
            parseLocalJSONtoFetchLocations()
        }
    }
    
    func selectLocation() {
        getTimeZone(lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0) { timeZone in
            selectedLocation?.offSet = timeZone?.offSet
            isAddCitySheet = true
            
            //            let newCity = Cities(city: selectedLocation?.city ?? "Nuremberg", lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0, offSet: timeZone?.offSet ?? 0.0)
            //            locationState.cities.append(newCity)
            //            if let location = locationState.cities.last {
            //                navigationState.tabbarSelection = .city(location)
            //                navigationState.sidebarSelection = .city(location)
            //            }
            ////            dismissSearch()
            //            isSheet.toggle()
        }
    }
    
    func addLocation() {
        let newCity = Cities(city: selectedLocation?.city ?? "Nuremberg", lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0, offSet: selectedLocation?.offSet ?? 0.0)
        locationState.cities.append(newCity)
        if let location = locationState.cities.last {
            navigationState.tabbarSelection = .city(location)
            navigationState.sidebarSelection = .city(location)
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
            
            var location = Location()
            location.lat = lat
            location.lng = long
            location.city = place.locality
            location.country = place.country
            location.dateTime = Date()
            
            if let secondsFromGMT = Double(place.timeZone?.secondsFromGMT() ?? 0) as? Double {
                let hours = secondsFromGMT / 3600
                location.offSet = hours
            } else {
                location.offSet = 0.0 // Default to 0.0 if an error occurs or no timezone information is available
            }
            
            completion(location)
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
