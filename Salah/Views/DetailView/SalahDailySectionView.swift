//
//  SalahDailySectionView.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/10/23.
//

import SwiftUI

struct SalahDailySectionView: View {
    
    @Binding var prayerTimes: [SalahTiming]
    @State private var nextPrayerName: String = ""
    @State private var remainingTime: String = ""
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    
    var body: some View {
        Section(header: Text("Prayer Times : " + nextPrayerName).bold().foregroundColor(.black)) {
            LazyVGrid(columns: column, spacing: 10) {
                ForEach(prayerTimes, id: \.self) { prayer in
                    PrayerItemView(prayer: prayer)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray))
            .padding()
            
            // Display next prayer remaining time
            Text("Next Prayer: \(nextPrayerName) - \(remainingTime)")
                .padding()
        }
        .onAppear {
            updateRemainingTime()
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateRemainingTime()
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
            if let prayerDate = convertTimeStringToDate(prayer.time, format: "HH:mm"), prayerDate > currentDate {
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
        guard let prayerDate = convertTimeStringToDate(time, format: "HH:mm") else {
            return "Unknown"
        }
        
        let now = Date()
        return now.timeRemainingString(to: prayerDate)
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
                .frame(width: 100)
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
extension Date {
    func timeRemainingString(to date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: self, to: date)
        
        guard let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
            return "Expired"
        }
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}


//#Preview {
//    @State var prayerTime = [SalahTiming(name: "Fajr", time: "06:00")]
//    SalahDailySectionView(prayerTimes: $prayerTime)
//}
