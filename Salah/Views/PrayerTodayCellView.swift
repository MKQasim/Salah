//
//  PrayerTodayCellView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI
struct PrayerCellView: View {
    let prayer: PrayerTiming
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .font(.headline)
                    .padding(5)
                    .background(Color.white)
                    .clipShape(Circle())
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
                .font(.title)
            
            Text(prayer.name ?? "")
                .foregroundColor(.primary) // Set text color
                .font(.headline)
                .lineLimit(1) // Limit text to one line
                
            
            Text(prayer.time ?? "")
                .foregroundColor(.white) // Set text color
                .font(.subheadline)
                .lineLimit(1) // Limit text to one line
        }
        .padding(10) // Adjust padding to the VStack
        .background(
            LinearGradient(gradient: Gradient(colors: [.gray, .blue]), startPoint: .leading, endPoint: .trailing)
        ) // Apply gradient background
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius
        .shadow(radius: 5) // Add shadow
    }
}



struct PrayerTodaySunCellView: View {
    let prayer: PrayerTiming
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(prayer.name ?? "")
                    .foregroundColor(.black) // Set text color
                    .font(.headline)
                Image(systemName: "bell.fill")
                    .font(.headline)
                    .padding(5)
                    .background(Color.white)
                    .clipShape(Circle())
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
            Spacer()
            
            VStack(alignment: .leading) {
                if prayer.name?.lowercased() == "sunrise" {
                    HStack {
                        Image(systemName: "moon.fill") // Moon icon for sunrise
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.trailing, 5) // Add padding to separate the icon from the text
                        
                        Spacer()
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                            .padding(.top, 5)
                            .padding(.bottom, 5)// Add padding to separate the icon from the text
                    }
                    HStack {
                        Text(prayer.time ?? "")
                            .foregroundColor(.white) // Set text color
                            .font(.title2)
                            .lineLimit(1) // Limit the text to one line
                        Spacer()
                    }
                } else if prayer.name?.lowercased() == "sunset" {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                            .padding(.trailing, 5) // Add padding to separate the icon from the text
                        
                        Spacer()
                        Image(systemName: "moon.fill") // Moon icon for sunset
                            .foregroundColor(.white)
                            .font(.title)
                            .padding(.top, 5)
                            .padding(.bottom, 5)// Add padding to separate the icon from the text
                    }
                    
                    HStack {
                        Spacer()
                        Text(prayer.time ?? "")
                            .foregroundColor(.white) // Set text color
                            .font(.title2)
                            .lineLimit(1) // Limit the text to one line
                    }
                } else {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                        .font(.title)
                        .padding(.bottom, 5) // Add padding to separate the icon from the text
                }
            }
        }
        .padding() // Add padding to the VStack
        .background(
            LinearGradient(gradient: Gradient(colors: [.white.opacity(0.2), .white.opacity(0.2)]), startPoint: .leading, endPoint: .trailing)
        ) // Apply gradient background
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius
        .shadow(radius: 5) // Add shadow
    }
}


struct PrayerWeeeklyCellView: View {
    let prayer: PrayerTiming
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: "bell.fill")
                    .font(.headline)
                    .padding(5)
                    .background(Color.white)
                    .clipShape(Circle())
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)

            Image(systemName: "sun.max.fill")
                .foregroundColor(.orange)
                .font(.title)
            
            Text(prayer.name ?? "")
                .foregroundColor(.primary) // Set text color
                .font(.headline)
            
            Text(prayer.time ?? "")
                .foregroundColor(.white) // Set text color
                .font(.subheadline)
        }
        .padding() // Add padding to the VStack
        .background(
            LinearGradient(gradient: Gradient(colors: [.gray, .blue]), startPoint: .leading, endPoint: .trailing)
        ) // Apply gradient background
        .clipShape(RoundedRectangle(cornerRadius: 10)) // Apply corner radius
        .shadow(radius: 5) // Add shadow
    }
}



struct PrayerTodayCellView_Previews: PreviewProvider {
    static var previews: some View {
        let prayerTime = PrayerTiming(name: "Fajr", time: "5:30 AM", timeZoneIdentifier: "")
        return PrayerCellView(prayer: prayerTime)
    }
}
