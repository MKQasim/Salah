//
//  PrayerTodayCellView.swift
//  Salah
//
//  Created by Haaris Iqubal on 13.12.23.
//

import SwiftUI

struct PrayerTodayCellView: View {
    let prayer: PrayerTiming
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                Image(systemName: "bell.fill")
                    .font(.headline)
                    .padding(5)
                    .background(.white)
                    .cornerRadius(20)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            
            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
                .font(.title)
            Text(prayer.name ?? "")
            Text("\(prayer.time?.formatted(date: .omitted, time: .standard) ?? "")")
                .foregroundStyle(.gray)
        }
        
    }
    
    func convertDateTimeString(_ originalDateTimeString: String, from originalFormat: String? = "yyyy-MM-dd HH:mm:ss Z", to targetFormat: String? = "MMM dd, yyyy HH:mm:ss Z", originalTimeZone: TimeZone, targetTimeZone: TimeZone) -> String? {
        let originalDateFormatter = DateFormatter()
        originalDateFormatter.dateFormat = originalFormat
        originalDateFormatter.timeZone = originalTimeZone
        
        if let originalDate = originalDateFormatter.date(from: originalDateTimeString) {
            let targetDateFormatter = DateFormatter()
            targetDateFormatter.dateFormat = targetFormat
            targetDateFormatter.timeZone = targetTimeZone
            
            return targetDateFormatter.string(from: originalDate)
        } else {
            print("Failed to convert original date and time string to Date.")
            return nil
        }
    }



}

#Preview {
    let prayerTime = PrayerTiming(name: "Fajr", time: Date())
    return PrayerTodayCellView(prayer: prayerTime)
}
