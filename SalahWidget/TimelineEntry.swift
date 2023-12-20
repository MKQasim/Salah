//
//  TimelineEntry.swift
//  SalahWidgetExtension
//
//  Created by Haaris Iqubal on 12/20/23.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let time: [PrayerTiming]
}
