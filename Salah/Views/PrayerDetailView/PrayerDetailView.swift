//
//  SalahDetailView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/6/23.
//
import SwiftUI

struct SalahTiming: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let time: String
}

struct PrayerDetailView: View {
    @EnvironmentObject private var locationManager: LocationManager
    let city: Cities
    // MARK: View States
    @State private var todayPrayersTimes: [SalahTiming] = []
    @State private var tomorrowPrayerTimes: [SalahTiming] = []
    @State private var sunTimes: [SalahTiming] = []
    @State private var selectedPrayer: SalahTiming? = nil
    @State private var isUpdate = true
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remainingTime: TimeInterval = 0
    @State private var targetDate: Date = Date()
    
    var body: some View {
        ScrollView {
                VStack{
                    VStack {
                        Image(systemName: "clock")
                            .foregroundColor(.green)
                            .font(.title)
                        Text("Currently: \(timeNow)")
                            .font(.subheadline)
                            .onReceive(timer) { _ in updateTime() }
                            .onAppear { }
                    }
                    .frame(maxWidth: .infinity, minHeight: 120)
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .padding([.leading,.trailing])
                    
                    
                    LazyVGrid(columns: [.init(.flexible(minimum: 120, maximum: .infinity)), .init(.flexible(minimum: 120, maximum: .infinity))]){
                        VStack {
                            Image(systemName: "alarm")
                                .foregroundColor(.orange)
                            Text("Next Salah: \(nextSalah)")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 120)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        
                        
                        if let selectedPrayer = selectedPrayer {
                            VStack {
                                Image(systemName: "hourglass")
                                    .foregroundColor(.black)
                                Text("Remaining Time for \(selectedPrayer.name): \(formattedTime())")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(.thinMaterial)
                            .cornerRadius(10)
                        }
                    }
                    .padding([.leading,.trailing])
                    
                    VStack{
                        PrayerHeaderSection(sunTimes: $sunTimes)
                        PrayerTodaySectionView(prayerTimes: $todayPrayersTimes)
                        PrayerTomorowSection(prayerTimes: $tomorrowPrayerTimes)
                        PrayerWeeklySectionView(city: city)
                    }
                    .padding([.leading,.trailing])
                }
                .padding(.top,10)
        }
        .onAppear{
            setUpView()
            }
        
        
    }
    
    private func setUpView() {
        if isUpdate {
            todayPrayersTimes = []
            tomorrowPrayerTimes = []
            let today = Date()
            todayPrayersTimes = PrayerTimeHelper.getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone)
            if let cal = Calendar.current.date(byAdding: .day,value: 1, to: today) {
                tomorrowPrayerTimes = PrayerTimeHelper.getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone,date: cal)
            }
            isUpdate = false
        }

    }


    private func updateTime() {
        timeNow = currentTime(for: city.timeZone) ?? ""
        getNextPrayerTime()
    }
    
    private func formattedTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .full
        return formatter.string(from: remainingTime) ?? ""
    }
    
    private func getNextPrayerTime() {
        let currentDate = Date().dateByAdding(timeZoneOffset: city.timeZone)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for prayer in todayPrayersTimes {
            let addedCurrentDate = dateFormatter.string(from: currentDate!) + " " + prayer.time
            if let prayerTime = convertTimeStringToDate(addedCurrentDate, format: "dd/MM/yyyy HH:mm") {
                if prayerTime > currentDate! {
                    nextSalah = "\(prayer.name) at \(prayer.time)"
                    selectedPrayer = prayer
                    targetDate = prayerTime
                    startTimer()
                    return
                }
            }
        }
        
        if nextSalah.isEmpty {
            nextSalah = "\(todayPrayersTimes[0].name) at \(todayPrayersTimes[0].time)"
            selectedPrayer = todayPrayersTimes.first
            targetDate = convertTimeStringToDate(todayPrayersTimes[0].time, format: "HH:mm") ?? Date()
            startTimer()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            remainingTime = max(self.targetDate.timeIntervalSinceNow, 0)
            
            if remainingTime == 0 {
                timer.invalidate()
                // Timer reached zero
            }
        }
        .fire()
    }
    
    private func convertTimeStringToDate(_ timeString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: timeString)
    }
    
    private func currentTime(for timeZone: Double) -> String? {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL dd, hh:mm:ss a"
        
        if let dateTime = currentDate.dateByAdding(timeZoneOffset: timeZone) {
            return dateFormatter.string(for: dateTime) ?? ""
        } else {
            print("Error occurred while calculating the date.")
            return ""
        }
    }
}

#Preview {
    let city = Cities(city: "Nurember", lat: 43.22, long: 11.32, timeZone: +1.0)
    return PrayerDetailView(city: city)
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}

