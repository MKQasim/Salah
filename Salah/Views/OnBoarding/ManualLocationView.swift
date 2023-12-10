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

    @Binding var isSheet:Bool
    @State private var countryName = ""
    @State private var cityName = ""
    
    @State var dropDownList:[Location] = []
    @State private var selectedLocation: Location? = nil
    @State private var searchable = ""

    var body: some View {
        NavigationView{
            Form{
                List{
                    ForEach(dropDownList.filter({searchable.isEmpty ? true : $0.city!.localizedStandardContains(searchable)}), id: \.self.id){item in
                        HStack{
                            Text(item.city ?? "")
                            Spacer()
                            if (selectedLocation == item) {
                                Image(systemName: "checkmark").foregroundStyle(.blue)
                            }
                        }
                        .onTapGesture {
                            selectedLocation = item
                        }
                        
                    }
                }
            }
            .navigationTitle("Manual Location")
            #if os(iOS)
            .searchable(text: $searchable)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar{
                ToolbarItem(placement: .primaryAction){
                    if selectedLocation != nil {
                        Button(action: {
                            
                            getTimeZone(lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0) { timeZone in
                                print("Time zone offset: \(timeZone) hours")
                                // Use the timeZone value here or perform additional actions
                                let newCity = Cities(city: selectedLocation?.city ?? "Nuremberg", lat: selectedLocation?.lat ?? 0.0, long: selectedLocation?.lng ?? 0.0, timeZone: timeZone)
                                locationState.cities.append(newCity)
                                isSheet.toggle()
                            }
                           
                        }, label: {
                            Text("Done")
                        })
                    }
                }
            }
        }
        
        .onAppear{
            parseLocalJSONtoFetchLocations()
        }
    }
    
    func getTimeZone(lat: Double, long: Double, completion: @escaping (Double) -> Void) {
        let offset = TimeZone.current.secondsFromGMT()
        print(offset) // Your current timezone offset in seconds

        let loc = CLLocation(latitude: lat, longitude: long) // Paris's lon/lat
        let coder = CLGeocoder()
        
        coder.reverseGeocodeLocation(loc) { (placemarks, error) in
            if let place = placemarks?.last,
               let secondsFromGMT = Double(place.timeZone?.secondsFromGMT() ?? 0) as? Double{
                let hours = secondsFromGMT / 3600
                let offsetString = String(format: "%+f", hours)
                print(offsetString)
                completion(hours)
            } else {
                completion(0.0) // Default to 0.0 if an error occurs or no timezone information is available
            }
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
