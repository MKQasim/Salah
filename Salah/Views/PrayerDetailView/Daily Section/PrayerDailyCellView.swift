//
//  Prayer.swift
//  Salah
//
//  Created by Haaris Iqubal on 12/12/23.
//

import SwiftUI

struct PrayerDailyCellView: View {
    let prayer: PrayerTiming

    var body: some View {
        VStack{
            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
                .font(.title)
            Text(prayer.name ?? "")
            Text("\(prayer.time?.formatted(date: .omitted, time: .standard) ?? "")")
                .foregroundStyle(.gray)
        }
        .padding()
        .frame(minWidth: 120, maxWidth: .infinity,minHeight: 120)
        .background(.thinMaterial)
        .cornerRadius(10)
    }
}

#Preview {
    let prayerTime = PrayerTiming(name: "Fajr", time: Date())
    return PrayerDailyCellView(prayer: prayerTime)
}
