//
//  ManualLocationView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/7/23.
//

import SwiftUI

struct ManualLocationView: View {
    @EnvironmentObject private var locationState: LocationState
    @State private var countryName = ""
    @State private var cityName = ""
    
    @State var dropDownList:[Location] = []
    @State private var selectedLocation: Location? = nil
    @State var searchable = ""

    var body: some View {
        VStack{
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
        }
        .navigationTitle("Manual Location")
        #if os(iOS)
        .searchable(text: $searchable,placement: .navigationBarDrawer(displayMode: .always))
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar{
            ToolbarItem(placement: .primaryAction){
                if selectedLocation != nil {
                    Button(action: {
                        locationState.latitude = selectedLocation!.lat!
                        locationState.longitude = selectedLocation!.lng!
                        locationState.isLocation = true
                    }, label: {
                        Text("Done")
                    })
                }
            }
        }
        .onAppear{
            parseLocalJSON()
        }
    }
    
    func parseLocalJSON() {
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
    ManualLocationView()
        .environmentObject(LocationState())
}
