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
    @State private var prayerTimes: [SalahTiming] = []
    @State private var sunTimes: [SalahTiming] = []
    @State private var selectedPrayer: SalahTiming? = nil
    @State private var isUpdate = true
    
    let city: Cities
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeNow = ""
    @State private var nextSalah = ""
    @State private var remainingTime: TimeInterval = 0
    @State private var targetDate: Date = Date() // Set your specific time here
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15) {
                
                HStack {
                    Image(systemName: "house")
                        .foregroundColor(.brown)
                    Text(city.city)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
              
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
////                        .fill(
////                            LinearGradient(
////                                gradient: Gradient(colors: [Color.orange, Color.red]),
////                                startPoint: .topLeading,
////                                endPoint: .bottomTrailing
////                            )
////                        )
//                        .background(.thinMaterial)
//                )
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.green)
                    Text("Currently: \(timeNow)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .onReceive(timer) { _ in updateTime() }
                                            .onAppear { }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
                
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
////                        .fill(
////                            LinearGradient(
////                                gradient: Gradient(colors: [Color.green, Color.blue]),
////                                startPoint: .topLeading,
////                                endPoint: .bottomTrailing
////                            )
////                        )
//                        .background(.thinMaterial)
//                )
                
                HStack {
                    Image(systemName: "alarm")
                        .foregroundColor(.orange)
                    Text("Next Salah: \(nextSalah)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(10)
                
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
////                        .fill(
////                            LinearGradient(
////                                gradient: Gradient(colors: [Color.purple, Color.pink]),
////                                startPoint: .topLeading,
////                                endPoint: .bottomTrailing
////                            )
////                        )
//                        .background(.thinMaterial)
//                )
                
                if let selectedPrayer = selectedPrayer {
                    HStack {
                        Image(systemName: "hourglass")
                            .foregroundColor(.black)
                        Text("Remaining Time for \(selectedPrayer.name): \(formattedTime())")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    
//                    .background(
//                        RoundedRectangle(cornerRadius: 10)
////                            .fill(
////                                LinearGradient(
////                                    gradient: Gradient(colors: [Color.yellow, Color.orange]),
////                                    startPoint: .topLeading,
////                                    endPoint: .bottomTrailing
////                                )
////                            )
//
//                    )
                }
                
                PrayerHeaderSection(sunTimes: $sunTimes)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                PrayerDailySectionView(prayerTimes: $prayerTimes)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                PrayerWeeklySectionView(city: city)
                    .background(.ultraThickMaterial)
                .cornerRadius(10)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(
//                            LinearGradient(
//                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            )
//                        )
                        
//                )
            }
            .padding()
        }
#if os(iOS)
        .navigationBarTitle(city.city)
#endif
        .onAppear {
            if isUpdate {
                getSalahTimings(lat: city.lat, long: city.long, timeZone: city.timeZone)
                isUpdate = false
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
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
        
        for prayer in prayerTimes {
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
            nextSalah = "\(prayerTimes[0].name) at \(prayerTimes[0].time)"
            selectedPrayer = prayerTimes.first
            targetDate = convertTimeStringToDate(prayerTimes[0].time, format: "HH:mm") ?? Date()
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
    
    private func getSalahTimings(lat: Double, long: Double, timeZone: Double) {
        let date = Date()
        let time = PrayTime()
        time.setCalcMethod(3)
        let mutableNames = time.timeNames!
        let salahNaming: [String] = mutableNames.compactMap({ $0 as? String })
        
        let getTime = time.getDatePrayerTimes(Int32(date.get(.year)),
                                              andMonth: Int32(date.get(.month)),
                                              andDay: Int32(date.get(.day)),
                                              andLatitude: lat,
                                              andLongitude: long,
                                              andtimeZone: timeZone)!
        let salahTiming = getTime.compactMap({ $0 as? String })
        
        for (index, name) in salahNaming.enumerated() {
            let newSalahTiming = SalahTiming(name: name, time: salahTiming[index])
            
            if (name != "Sunset" && name != "Sunrise") {
                prayerTimes.append(newSalahTiming)
                isUpdate = true
            } else {
                sunTimes.append(newSalahTiming)
                isUpdate = true
            }
        }
    }
}


extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Date {
    func adjusted(byHours hours: Int, minutes: Int, seconds: Int) -> Date {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = seconds
        
        return calendar.date(byAdding: dateComponents, to: self) ?? self
    }
}

extension Date {
    func dateByAdding(hours: Int, minutes: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = hours
        dateComponents.minute = minutes
        
        return calendar.date(byAdding: dateComponents, to: self)
    }
    
    func dateByAdding(timeZoneOffset: Double) -> Date? {
        let hours = Int(timeZoneOffset)
        let minutes = Int((timeZoneOffset - Double(hours)) * 60)
        return dateByAdding(hours: hours, minutes: minutes)
    }
}




#Preview {
    let city = Cities(city: "Nurember", lat: 43.22, long: 11.32, timeZone: +1.0)
    return PrayerDetailView(city: city)
        .environmentObject(LocationManager())
        .environmentObject(LocationState())
}

