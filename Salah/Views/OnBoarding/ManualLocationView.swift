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
        List {
            ForEach(dropDownList.filter({ searchable.isEmpty ? true : $0.city!.localizedStandardContains(searchable) }), id: \.self.id) { item in
                Button(action: {
                    selectedLocation = item
                    selectLocation { isPassed in
                        if isPassed {
                            if let location = selectedLocation {
                                isSheet.toggle()
                                isAddCitySheet = true
                            }else{
                             print("")
                            }
                           
                        }
                    }
                }, label: {
                    VStack(alignment: .leading){
                        Text(item.city ?? "")
                            .font(.title3)
                            .foregroundStyle(Color.primary)
                        Text(item.country ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity,alignment: .leading)
                })
                .tint(.clear)
                .buttonStyle(.borderedProminent)
            }
        }
        .listStyle(.plain)
        .sheet(isPresented: $isAddCitySheet) {
             NavigationStack {
                    PrayerDetailView(selectedLocation: selectedLocation)
                     .navigationTitle(selectedLocation?.city ?? "Nuremberg")
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
        .onAppear {
            parseLocalJSONtoFetchLocations()
        }
    }
    
    func selectLocation(completion: ((Bool) -> Void)? = nil) {
        guard let timeZoneIdentifier = selectedLocation?.timeZoneIdentifier else {
            print("No time zone identifier found for selected location")
            return
        }
        
        if let timeZone = TimeZone(identifier: timeZoneIdentifier) {
            // Get current date in the specified time zone
            let currentDate = Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let currentDateInTimeZone = dateFormatter.string(from: currentDate)
            
            // Manipulating selectedLocation based on the current time zone
            selectedLocation?.dateTime = dateFormatter.date(from: currentDateInTimeZone)
            selectedLocation?.offSet = Double(timeZone.secondsFromGMT(for: currentDate)) / 3600.0
            
            // Check condition for selectedLocation?.offSet and perform callback
            if let offset = selectedLocation?.offSet, offset > 0 {
                completion?(true)
            } else {
                completion?(false)
            }
            
            // You might not want to update the timeZoneIdentifier here, as it represents the location's identifier
            
        } else {
            print("Invalid time zone identifier")
        }
    }



    func addLocation() {
        
        locationState.cities.append(selectedLocation ?? Location())
        if let location = locationState.cities.last {
            navigationState.tabbarSelection = .location(selectedLocation ?? Location())
            navigationState.sidebarSelection = .location(selectedLocation ?? Location())
        }
        dismissSearch()
        isSheet.toggle()
        isDetailView.toggle()
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

#Preview {
    @State var isSheet = false
    @State var isDetailView = true
    
    @State var searching = ""
    return ManualLocationView(isSheet: $isSheet,searchable: $searching, isDetailView: $isDetailView)
        .environmentObject(LocationState())
}
