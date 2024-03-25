//
//  PrayerTodaySectionView.swift
//  Salah
//
//  Created by Muhammad's on 20.03.24.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct PrayerSectionView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    let column = [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))]
    var day: Day?
    var title: String
    
    var body: some View {
        VStack(alignment: .leading){
            LazyVGrid(columns: column, pinnedViews: .sectionHeaders, content: {
                Section(header: SectionHeaderView(title: title, dateTime: day?.date ?? "").foregroundColor(.white)) {
                    ForEach(day?.prayerTimings.filter { _ in viewModel.prayer?.id == viewModel.selectedItem?.id } ?? [], id: \.self) { prayer in
                        PrayerCellView(prayer: prayer)
                            .padding(.all, 15)
                            .frame(maxWidth: .infinity,minHeight: 120)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.blue, .white]),
                                               startPoint: .leading, endPoint: .trailing)
                            )// Use blue gradient for the next prayer
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                }
            })
        }
    }
}



struct PrayerSunSection: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var columns: [GridItem] {
        if horizontalSizeClass == .compact {
            return Array(repeating: .init(.flexible()), count: 2)
        } else {
            return Array(repeating: .init(.flexible()), count: 2)
        }
    }
    
    var body: some View {
        LazyVGrid(columns: columns, pinnedViews: .sectionHeaders, content: {
            Section(header: SectionHeaderView(title: "Sun Times", dateTime: viewModel.prayer?.today?.date ?? "").foregroundColor(.white)) {
                ForEach(viewModel.prayer?.today?.sunTimings.filter { _ in viewModel.prayer?.id == viewModel.selectedItem?.id } ?? [], id: \.self) { sunTime in
                    PrayerTodaySunCellView(prayer: sunTime)
                    .padding() // Add padding to the VStack
                    .background(
                        LinearGradient(gradient: Gradient(colors: gradientColors(for: sunTime)), startPoint: .leading, endPoint: .trailing)
                    ) // Apply gradient background
                    .shadow(radius: 5) // Add shadow
                    .cornerRadius(10) // Apply corner radius
                    .frame(maxWidth: .infinity) // Ensure the VStack fills the available width
                }
            }
        })
        .padding() // Add padding to the LazyVGrid
    }
    
    private func gradientColors(for sunTime: PrayerTiming) -> [Color] {
        if sunTime.name?.lowercased() == "sunrise" {
            return [.black.opacity(0.2), .orange.opacity(0.5), .blue.opacity(0.5), .white.opacity(0.5)]
        } else if sunTime.name?.lowercased() == "sunset" {
            return [.white.opacity(0.5), .blue.opacity(0.5), .orange.opacity(0.5), .black.opacity(0.2)]
        } else {
            return [.white]
        }
    }
}

struct WeeklyPrayerTimingsGridView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    
    var body: some View {
        if let weeklyPrayerTimings = viewModel.prayer?.weekly {
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack {
                    ForEach(weeklyPrayerTimings.indices, id: \.self) { index in
                        Section(header:SectionHeaderView(title: "Week Day \(index + 1)", dateTime: viewModel.prayer?.weekly?[index].date ??  "").foregroundColor(.white)) {
                            ScrollView(.horizontal, showsIndicators: true) {
                                LazyHStack {
                                    ForEach(weeklyPrayerTimings[index].prayerTimings) { prayerTiming in
                                        PrayerWeeeklyCellView(prayer: prayerTiming)
                                        .padding(.all, 15)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [.blue, .white]),
                                                           startPoint: .leading, endPoint: .trailing)
                                        )
                                        .shadow(radius: 10)
                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        .foregroundColor(.black) // Adjust font color for section header
                    }
                }
            }
        } else {
            Text("No weekly prayer timings available")
                .foregroundColor(.secondary)
                .italic()
        }
    }
}


