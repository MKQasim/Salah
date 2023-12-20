//
//  SalahWidget.swift
//  SalahWidget
//
//  Created by Qassim on 12/13/23.
//

import WidgetKit
import SwiftUI




struct SalahWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    var body: some View {
        switch widgetFamily{
        case .systemSmall:
            SmallWidgetView()
        case .systemMedium:
            MediumWidgetView()
        case .systemLarge:
            LargeWidgetView()
        case .systemExtraLarge:
            ExtraLargeWidgetView()
        case .accessoryCircular:
            AccessoryWidgetView()
        case .accessoryRectangular:
            AccessoryWidgetRectangle()
        case .accessoryInline:
            AccessoryWidgetInline()
        @unknown default:
            Text("Def")
        }
    }
}
    
    struct SmallWidgetView: View {
        var body: some View {
            Text("Small")
        }
    }
    
    struct MediumWidgetView: View {
        var body: some View {
            Text("Small")
        }
    }
    
    struct LargeWidgetView: View {
        var body: some View {
            Text("Small")
        }
    }
    
    struct ExtraLargeWidgetView: View {
        var body: some View {
            Text("Small")
        }
    }
    
    struct AccessoryWidgetView: View {
        var body: some View {
            Text("Accesory View")
        }
    }
    
    struct AccessoryWidgetRectangle: View {
        var body: some View {
            Text("Rect")
        }
    }
    
    struct AccessoryWidgetInline: View {
        var body: some View {
            Text("Inline")
        }
    }

struct SalahWidget: Widget {
    let kind: String = "SalahWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            SalahWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    SalahWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, time: [])
    SimpleEntry(date: .now, configuration: .starEyes, time: [])
}
