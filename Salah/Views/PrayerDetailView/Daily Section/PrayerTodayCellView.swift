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
            Text(prayer.name)
            Text(prayer.time)
                .foregroundStyle(.gray)
        }
        
    }
}

#Preview {
    let prayerTime = PrayerTiming(name: "Fajr", time: "6:00")
    return PrayerTodayCellView(prayer: prayerTime)
}
