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
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            
            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
                .font(.title)
                .padding(.top, 8)
            
            Text(prayer.name ?? "")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.top, 4)
            
            Text(formatTimeString(prayer.formatDateString(prayer.time ?? Date())))
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
        .padding()
        .frame(minWidth: 140, maxWidth: .infinity, minHeight: 140) // Adjusted width and height
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue, .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(15)
    }
    
    private func formatTimeString(_ originalDateTimeString: String?) -> String {
        guard let originalDateTimeString = originalDateTimeString else { return "" }
        return convertDateTimeString(originalDateTimeString)
    }
    
    private func convertDateTimeString(_ originalDateTimeString: String, from originalFormat: String? = "yyyy-MM-dd HH:mm:ss Z", to targetFormat: String? = "MMM dd, yyyy HH:mm:ss Z", originalTimeZone: TimeZone = .current, targetTimeZone: TimeZone = .current) -> String {
        let originalDateFormatter = DateFormatter()
        originalDateFormatter.dateFormat = originalFormat
        originalDateFormatter.timeZone = originalTimeZone
        
        if let originalDate = originalDateFormatter.date(from: originalDateTimeString) {
            let targetDateFormatter = DateFormatter()
            targetDateFormatter.dateFormat = targetFormat
            targetDateFormatter.timeZone = targetTimeZone
            
            return targetDateFormatter.string(from: originalDate)
        } else {
            print("Failed to convert the original date and time string to Date.")
            return ""
        }
    }
}


#Preview {
    let prayerTime = PrayerTiming(name: "Fajr", time: Date())
    return PrayerTodayCellView(prayer: prayerTime)
}
