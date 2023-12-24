//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//

import SwiftUI

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var locationState: LocationState
    let currentDate = Date()
    @State var selectedLocation: Location
    
    // MARK: View States
    @State private var todayPrayersTimes: [PrayerTiming] = []
    @State private var tomorrowPrayerTimes: [PrayerTiming] = []
    @State private var sunTimes: [PrayerTiming] = []
    @State private var selectedPrayer: PrayerTiming? = nil
    @State private var isUpdate = true
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remTime = "00:00:00"
    @State private var timer: Timer?
        
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                VStack(spacing: 10) {
                    if selectedPrayer != nil {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.green)
                                .font(.title2)
                                .fontWeight(.black)
                            
                            Text("Next Prayer in: \(remTime)")
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    HStack {
                        Image(systemName: "clock.arrow.circlepath").font(.title2)
                            .foregroundColor(.orange)
                        Text("\(nextSalah)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "calendar").font(.title2)
                            .foregroundColor(.blue)
                        Text("\(timeNow)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                    }
                    .onAppear {
                        setUpView()
                        startTimer()
                    }
                }
                .padding()
                .background(Color.gray)
                .cornerRadius(20)
                .frame(minWidth: 140)
                PrayerSunSection(sunTimes: $sunTimes)
                PrayerTodaySectionView(prayerTimes: $todayPrayersTimes, nextSalah: $selectedPrayer)
                PrayerTomorowSection(prayerTimes: $tomorrowPrayerTimes)
                PrayerWeeklySectionView(selectedLocation: selectedLocation)
            }
            .padding(.top, 10)
            .padding([.leading, .trailing])
        }
    }

    private func setUpView() {
        if isUpdate {
            PrayerTimeHelper.shared.getSalahTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, offSet: selectedLocation.offSet ?? 0.0, completion: { location in
                selectedLocation = location
                 print(selectedLocation.offSet)
                todayPrayersTimes = location.prayerTimings ?? []
            })
            
            sunTimes = PrayerTimeHelper.shared.getSunTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, timeZone: selectedLocation.offSet ?? 0.0)
            
            if var cal = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
                cal.dateByAdding(timeZoneOffset: selectedLocation.offSet ?? 0)
                PrayerTimeHelper.shared.getSalahTimings(lat: selectedLocation.lat ?? 0.0, long: selectedLocation.lng ?? 0.0, offSet: selectedLocation.offSet ?? 0.0, date: currentDate, completion: { location in
                       selectedLocation = location
                    print(selectedLocation.offSet)
                     tomorrowPrayerTimes = location.prayerTimings ?? []
                })
            }
            
            isUpdate = false
        }
        
    }

      func startTimer() {
          self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTimeAndRemainingTime()
        }
          self.timer?.fire()
    }

    private func updateTimeAndRemainingTime() {
        let endDate = PrayerTimeHelper.shared.targetDate
        
        let hours = selectedLocation.offSet ?? 0.0 // get the hours from GMT as a Double
        let secondsFromGMT = Int(hours * 3600) // convert hours to seconds and cast to Int
        let timeZone = TimeZone(secondsFromGMT: secondsFromGMT) // create a TimeZone object
        
        guard let timeZone = timeZone else {
            // Handle the case where timeZone is nil
            // You might want to show an error message or handle this situation accordingly
            return
        }
        
        let currentDate = PrayerTimeHelper.shared.currentTime(for: timeZone, dateFormatString: "yyyy MMM d HH:mm").0
        let startDate = PrayerTimeHelper.shared.currentTime(for: timeZone, dateFormatString: "yyyy MMM d HH:mm").1
        
        timeNow = currentDate ?? ""
        
        PrayerTimeHelper.shared.findNextPrayerTime(now: startDate ?? Date(), selectedLocation: selectedLocation) { nextPrayer in
            if let nextPrayer = nextPrayer {
                if let name = nextPrayer.name as? String, let time = nextPrayer.time as? String {
                    self.nextSalah = "\(name) at \(time)"
                }
            }
        }
        
        selectedPrayer = PrayerTimeHelper.shared.selectedPrayer
        
        PrayerTimeHelper.shared.calculateRemainingTimeUntilNextPrayer(now: startDate ?? Date(), selectedLocation: selectedLocation) { remainingTime in
            self.remTime = remainingTime ?? ""
        }
    }

}


//#Preview {
//    let city = Cities(city: "Nuremberg", lat: 28.61, long: 77.20, timeZone: +5.5)
//    return PrayerDetailView(city: city)
//        .environmentObject(LocationManager())
//        .environmentObject(LocationState())
//}




