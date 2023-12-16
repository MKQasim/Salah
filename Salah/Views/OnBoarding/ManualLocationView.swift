//
//  ManualLocationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI
import CoreLocation

struct ManualLocationView: View {
    @EnvironmentObject private var locationState: LocationState
    @EnvironmentObject private var navigationState: NavigationState
    @Binding var isSheet:Bool
    @State private var countryName = ""
    @State private var cityName = ""
    
    @State var dropDownList:[Location] = []
    @State private var selectedLocation: Location? = nil
    @State private var searchable = ""
    
    
    var body: some View {
        Form{
            List{
                ForEach(dropDownList.filter({searchable.isEmpty ? true : $0.city!.localizedStandardContains(searchable)}), id: \.self.id){item in
                    VStack(alignment: .leading){
                        HStack{
                            Text(item.city ?? "")
                            Spacer()
                            if (selectedLocation == item) {
                                Image(systemName: "checkmark").foregroundStyle(.blue)
                            }
                        }
                        Text(item.country ?? "")
                            .foregroundStyle(.gray)
                    }
                    .onTapGesture {
                        selectedLocation = item
#if os(macOS)

//                        addLocation()
#endif
                    }
                    
                }
            }
        }
        .navigationTitle("Manual Location")
#if !os(macOS) && !os(watchOS)
        .searchable(text: $searchable,placement: .navigationBarDrawer(displayMode: .always))
        .navigationBarTitleDisplayMode(.large)
#endif
        .toolbar{
            ToolbarItemGroup(placement: .confirmationAction){
                if selectedLocation != nil {
                    Button(action: {
                        addLocation()
                        
                    }, label: {
                        Text("Done")
                    })
                }
            }
        }
        .onAppear{
            parseLocalJSONtoFetchLocations()
        }
    }
    
    func addLocation() {
        getTimeZone(lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0) { timeZone in
            let newCity = Cities(city: selectedLocation?.city ?? "Nuremberg", lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0, timeZone: timeZone?.timezone ?? 0.0)
            locationState.cities.append(newCity)
            if let location = locationState.cities.last {
                navigationState.tabbarSelection = .city(location)
                navigationState.sidebarSelection = .city(location)
            }
            isSheet.toggle()
        }
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
                location.timezone = hours
            } else {
                location.timezone = 0.0 // Default to 0.0 if an error occurs or no timezone information is available
            }
            
            completion(location)
        }
    }
    
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

//#Preview {
//    ManualLocationView()
//        .environmentObject(LocationState())
//}
