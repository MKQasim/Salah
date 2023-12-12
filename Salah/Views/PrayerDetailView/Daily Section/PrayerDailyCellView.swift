//
//  Prayer.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/12/23.
//

import SwiftUI

struct PrayerDailyCellView: View {
    let prayer: SalahTiming

    var body: some View {
        VStack{
            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
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

#Preview {
    let prayerTime = SalahTiming(name: "Fajr", time: "6:00")
    return PrayerDailyCellView(prayer: prayerTime)
}
