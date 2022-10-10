//
//  LYwidget.swift
//  LYwidget
//
//  Created by Paul Kühnel on 27.09.22.
//

import WidgetKit
import OSLog
import SwiftUI

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), imageID: nil, dateString: "")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let imageIds = Helper.getImageIdsFromUserDefault()
        
        let entry = SimpleEntry(date: Date(), imageID: imageIds.first!, dateString: "")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        
        let currentDate = Date()
        
        let imageIds = Helper.getImageIdsFromUserDefault()
        print(imageIds)

        guard !imageIds.isEmpty else { return }
        // testing for 5 seconds
        let daySeconds = 60 * 60 * 24
        let timeRangeInSecond = daySeconds / imageIds.count
        
        for index in 0 ..< imageIds.count {
            
            let entryDate = Calendar.current.date(byAdding: .second, value: index * timeRangeInSecond, to: currentDate)!
            
            let components = imageIds[index].split(separator: "@", omittingEmptySubsequences: true)
            var dateString: String?
            if components.count > 1 {
                dateString = String(components.last!)
            }
            let entry = SimpleEntry(date: entryDate, imageID: imageIds[index], dateString: dateString)
            
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let imageID: String?
    let dateString: String?
}

struct LYwidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily

    var imageID: String?
    var dateString: String?
    
    var body: some View {
        if let imageID = imageID {
            ZStack {
                Image(uiImage: Helper.getImageFromUserDefaults(key: imageID))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                VStack(spacing: 0) {
                    Spacer()
                    if let dateString = dateString {
                        Text(dateString)
                            .font(Font.custom("Poppins-Bold", size: 20))
                            .foregroundColor(.white)
                    }
                    HStack(spacing: 0) {
                        Text("About")
                            .font(Font.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                        Text("Last")
                            .font(Font.custom("Poppins-Bold", size: 16))
                            .foregroundColor(Color("primary"))
                        Text("Year.")
                            .font(Font.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.white)
                    }
                    .padding(2)
                }
            }
        } else {
            ZStack {
                Color.white
                Image("fallback")
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(20)
            }

        }
    }
}

@main
struct LYwidget: Widget {
    
    let kind: String = "LYwidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LYwidgetEntryView(imageID: entry.imageID, dateString: entry.dateString)
                .onAppear {
                    os_log("IMAGE %{public}@", log: OSLog.default, type: .error, entry.imageID ?? "no image")
                }
        }
        .configurationDisplayName("Last Year")
        .description("The time machine widget.")
    }
}

struct LYwidget_Previews: PreviewProvider {
    static var previews: some View {
        LYwidgetEntryView(imageID: nil, dateString: "")
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension Color {
    
    public static var random: Color {
        return Color(red: .random(in: 0...1),
                             green: .random(in: 0...1),
                             blue: .random(in: 0...1))
    }
    
}
