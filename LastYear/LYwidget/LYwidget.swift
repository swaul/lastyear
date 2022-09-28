//
//  LYwidget.swift
//  LYwidget
//
//  Created by Paul Kühnel on 27.09.22.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imageID: nil)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), imageID: nil)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        let currentDate = Date()
        
        let imageIds = Helper.getImageIdsFromUserDefault()
        print(imageIds)

        // testing for 5 seconds
        let timeRangeInSecond = 5
        
        for index in 0 ..< imageIds.count {
            
            let entryDate = Calendar.current.date(byAdding: .second, value: index * timeRangeInSecond, to: currentDate)!
            
            let entry = SimpleEntry(date: entryDate, imageID: imageIds[index])
            
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageID: String?
}

struct LYwidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        if let imageID = entry.imageID {
            Image(uiImage: Helper.getImageFromUserDefaults(key: imageID))
                .resizable()
                .scaledToFill()
                .onAppear {
                    print("tapped")
                }
        } else {
            Image("fallback")
                .resizable()
                .scaledToFill()
                .onAppear {
                    print("tapped")
                }
        }
    }
}

@main
struct LYwidget: Widget {
    let kind: String = "LYwidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            LYwidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct LYwidget_Previews: PreviewProvider {
    static var previews: some View {
        LYwidgetEntryView(entry: SimpleEntry(date: Date(), imageID: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
