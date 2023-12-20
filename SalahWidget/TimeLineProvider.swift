//
//  TimeLineProvider.swift
//  SalahWidgetExtension
//
//  Created by Haaris Iqubal on 12/20/23.
//

import Foundation
import WidgetKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let prayers = (try? getTime()) ?? []
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), time: prayers)
    }

    

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
            let prayers = (try? getTime()) ?? []
            return SimpleEntry(date: Date(), configuration: configuration,time: [])
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let prayers = (try? getTime()) ?? []
            let entry = SimpleEntry(date: entryDate, configuration: configuration, time: prayers)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    
    func getTime() throws -> [PrayerTiming]{
//        let prayTime = PrayerTimeHelper.getSalahTimings(lat: 49.11, long: 11.19, timeZone: +1.0)
        return []
    }
}
