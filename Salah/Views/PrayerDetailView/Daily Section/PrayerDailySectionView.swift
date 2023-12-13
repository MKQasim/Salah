//
//  SalahDailySectionView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct PrayerDailySectionView: View {
    
    @Binding var prayerTimes: [SalahTiming]
    @State private var nextPrayerName: String = ""
    @State private var remainingTime: String = ""
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        
        VStack(alignment: .center){
            Section(header: Text("Prayer Times").bold()) {
                VStack{
                    LazyVGrid(columns: column, content: {
                        ForEach(prayerTimes, id: \.self) { prayer in
                            PrayerDailyCellView(prayer: prayer)
                        }
                        .background(.thinMaterial)
                        .cornerRadius(20.0)
                    }).padding()
                }
            }
        }
    }
    
    private func updateRemainingTime() {
        guard let nextPrayerTime = getNextPrayerTime() else { return }
        
        let remaining = remainingTimeToNextPrayer(from: nextPrayerTime.time)
        DispatchQueue.main.async {
            self.nextPrayerName = nextPrayerTime.name
            self.remainingTime = remaining
        }
    }
    
    private func getNextPrayerTime() -> SalahTiming? {
        let currentDate = Date()
        let sortedPrayerTimes = prayerTimes.sorted(by: { $0.time < $1.time })
        
        for prayer in sortedPrayerTimes {
            if let prayerDate = convertTimeStringToDate(prayer.time, format: "HH:mm:ss"), prayerDate > currentDate {
                return prayer
            }
        }
        return nil
    }
    
    private func convertTimeStringToDate(_ timeString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: timeString)
    }
    
    private func remainingTimeToNextPrayer(from time: String) -> String {
        guard let prayerDate = convertTimeStringToDate(time, format: "HH:mm:ss") else {
            return "Unknown"
        }
        let now = Date()
        return now.timeRemainingString(to: prayerDate)
    }
}


extension Date {
    func timeRemainingString(to date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self, to: date)
        
        guard let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
            return "Expired"
        }
        
        if hours > 0 {
            return String(format: "%02f:%02f:%02f", hours, minutes, seconds)
        } else {
            return String(format: "%02f:%02f", minutes, seconds)
        }
    }
}


#Preview {
    @State var prayerTime = [SalahTiming(name: "Fajr", time: "06:00"), SalahTiming(name: "Duhr", time: "12:00"), SalahTiming(name: "Asr", time: "14:00"),SalahTiming(name: "Magrib", time: "17:00"),SalahTiming(name: "Isah", time: "19:00")]
    return PrayerDailySectionView(prayerTimes: $prayerTime)
}
