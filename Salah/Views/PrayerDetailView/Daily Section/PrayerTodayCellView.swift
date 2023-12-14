//
//  PrayerTodayCellView.swift
//  Salah
//
//  Created by Haaris Iqubal on 13.12.23.
//

import SwiftUI

struct PrayerTodayCellView: View {
    let prayer: SalahTiming
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Spacer()
                Image(systemName: "bell.fill")
                    .padding()
                    .background(.white)
                    .cornerRadius(50)
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            
            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
                .font(.title)
            Text(prayer.name)
                .fontWeight(.bold)
            Text(prayer.time)
                .fontWeight(.medium)
        }
        .padding()
        .frame(maxWidth: .infinity,minHeight: 120)
        .background(.thinMaterial)
        .cornerRadius(10)
    }
}

#Preview {
    let prayerTime = SalahTiming(name: "Fajr", time: "6:00")
    return PrayerTodayCellView(prayer: prayerTime)
}
