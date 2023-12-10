//
//  HomeView.swift
//  Salah
//
//  Created by Qassim on 12/9/23.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var locationState: LocationState
    var body: some View {
        TabView {
            PageView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)
            VStack {
                Text("Second")
                    .font(.largeTitle)
                NavigationLink(destination: ManualLocationView()) {
                    Text("Select Manual Location")
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    NavigationLink(destination: SalahDetailView(lat: locationState.latitude, long: locationState.longitude, timeZone: +1.0)) {
                        Image(systemName: "plus.circle.fill")
                            .font(.subheadline)
                    }
                   
                    Spacer()
                    Button(action: {
                        // Action for the home button
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.subheadline)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(LocationState())
}



struct PageView: View {
    @StateObject private var prayerViewModel: PrayerViewModel

    init(lat: Double, long: Double, timeZone: Double) {
        _prayerViewModel = StateObject(wrappedValue: PrayerViewModel(lat: lat, long: long, timeZone: timeZone))
    }

    var body: some View {
        ZStack {
            Color.white.opacity(0.9).ignoresSafeArea(.all)
            ScrollView {
                VStack(spacing: 12) {
                    sunTimesSection
                    prayerTimesSection
                    weeklyTimingSection
                }
                .padding()
            }
        }
        .onAppear {
            prayerViewModel.getSalahTimings(lat: 40.7128, long: -74.0060, timeZone: 5.5)
        }
    }

    // Sun Times Section
    @ViewBuilder
    private var sunTimesSection: some View {
        if !prayerViewModel.sunTimes.isEmpty {
            Section(header: Text("Sun Times").foregroundColor(.black)) {
                ForEach(prayerViewModel.sunTimes, id: \.self) { sunTime in
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                        Text("\(sunTime.name): \(sunTime.time)")
                            .foregroundColor(.black)
                            .font(.headline)
                    }
                }
            }
            .frame(width: 350, height: 45)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray))
            .padding()
        } else {
            EmptyView()
        }
    }

    // Prayer Times Section
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    @ViewBuilder
    private var prayerTimesSection: some View {
        Section(header: Text("Prayer Times").foregroundColor(.black)) {
            LazyVGrid(columns: column, spacing: 10) {
                ForEach(prayerViewModel.prayerTimes, id: \.self) { prayer in
                    PrayerItemView(prayer: prayer)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray))
            .padding()
        }
    }

    // Weekly Timing Section
    @ViewBuilder
    private var weeklyTimingSection: some View {
        Section(header: Text("Weekly Timing").foregroundColor(.black)) {
            Text("Your weekly timing content goes here")
                .foregroundColor(.black)
                .font(.title3)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray))
                .padding()
        }
    }
}

struct PrayerItemView: View {
    let prayer: SalahTiming

    var body: some View {
        VStack {
            Image(systemName: "moon.stars.fill")
                .foregroundColor(.purple) // Adjust color as needed
                .font(.title)
            Text(prayer.name)
                .fontWeight(.bold)
                .foregroundColor(.black)
            Text(prayer.time)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}



class PrayerViewModel: ObservableObject {
    @Published var prayerTimes: [SalahTiming] = []
    @Published var sunTimes: [SalahTiming] = []

    private let lat: Double
    private let long: Double
    private let timeZone: Double

    init(lat: Double, long: Double, timeZone: Double) {
        self.lat = lat
        self.long = long
        self.timeZone = timeZone
    }
    
    func getSalahTimings(lat: Double, long:Double, timeZone:Double){
//        guard let userCoordinates = locationManager.lastLocation?.coordinate else {return}
        let date = Date()
#if os(iOS)
        let time = PrayTime()
        time.setCalcMethod(3)
        let mutableNames = time.timeNames!
        let salahNaming:[String] = mutableNames.compactMap({$0 as? String})
//        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)), andMonth: Int32(date.get(.month)), andDay: Int32(date.get(.day)), andLatitude: userCoordinates.latitude.magnitude, andLongitude: userCoordinates.longitude.magnitude, andtimeZone: 1.0)!
        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)), andMonth: Int32(date.get(.month)), andDay: Int32(date.get(.day)), andLatitude: lat, andLongitude: long, andtimeZone: timeZone)!
        let salahTiming = getTime.compactMap({$0 as? String})
        for (index,name) in salahNaming.enumerated() {
            let newSalahTiming = SalahTiming(name: name, time: salahTiming[index])
            if (name != "Sunset" && name != "Sunrise"){
                prayerTimes.append(newSalahTiming)
            }
            else{
                sunTimes.append(newSalahTiming)
            }
        }
#endif
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(lat: 40.7128, long: -74.0060, timeZone: 5.5)
    }
}


