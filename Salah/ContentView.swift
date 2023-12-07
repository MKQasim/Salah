//
//  ContentView.swift
//  Salah
//
//  Created by Qassim on 12/6/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManger = LocationManager()
    @State private var prayerTimes:[String] = []
    var body: some View {
        Group{
            if locationManger.lastLocation == nil {
                LocationPermissionOnboard()
            }
            else{
                MainNavigationView()
            }
        }
        .environmentObject(locationManger)
//        NavigationView()
//        .onAppear{
//            let time = PrayTime()
//            time.setCalcMethod(3)
//            
//            print(time.getZone())
//            let getTime = time.getDatePrayerTimes(2023, andMonth: 12, andDay: 6, andLatitude: 49.44, andLongitude: 11.02, andtimeZone: 1.0)!
//            prayerTimes = getTime as! [String]
//            
//            
//
//            // Call the function to parse the local JSON data
//            parseLocalJSON()
//
//             
//
//
//        }
    }
    
    func parseLocalJSON() {
       
        if let path = Bundle.main.path(forResource: "data", ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let jsonData = try Data(contentsOf: fileUrl)
                print(jsonData)
                let location = try? JSONDecoder().decode([Location].self, from: jsonData)
                print(location?.first?.country)
            } catch {
                print("Error parsing JSON: \(error)")
            }
        } else {
            print("File not found")
        }
    }
}

#Preview {
    ContentView()
}


// MARK: - PostElement
struct Location: Codable {
    var city : String?
    var lat, lng: Double?
    var country: String?
    var id: Int?

    enum CodingKeys: String, CodingKey {
        case city
        case lat,lng
        case country
        case id
    }
    
}

typealias LocationDetails = [Location]

