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
        SimpleEntry(date: Date(), dateLastYear: Date(), imageID: nil, dateString: "", numberOfIds: 0, imageIds: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let imageIds = Helper.getImageIdsFromUserDefault()
        
        let entry = SimpleEntry(date: Date(), dateLastYear: Date(), imageID: imageIds.first!, dateString: "", numberOfIds: 0, imageIds: [])
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        
        let imageIds = Helper.getImageIdsFromUserDefault()
        guard !imageIds.isEmpty else {
            entries.append(SimpleEntry(date: Date(), dateLastYear: Date(), imageID: "empty", dateString: "today", numberOfIds: 1, imageIds: ["empty"]))
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return
        }
        // testing for 5 seconds
        let daySeconds = 60 * 60 * 24
        let timeRangeInSecond = daySeconds / imageIds.count
        
        for index in 0 ..< imageIds.count {
            
            let entryDate = Calendar.current.date(byAdding: .second, value: index * timeRangeInSecond, to: currentDate)!
            
            let components = imageIds[index].split(separator: "@", omittingEmptySubsequences: true)
            var dateString: String?
            var dateLastYear: Date? = nil
            if components.count > 1 {
                dateString = String(components.last!)
                dateLastYear = Formatters.dateFormatter.date(from: dateString!)
            }
            let entry = SimpleEntry(date: entryDate, dateLastYear: dateLastYear, imageID: imageIds[index], dateString: dateString, numberOfIds: imageIds.count, imageIds: imageIds)
            
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dateLastYear: Date?
    let imageID: String?
    let dateString: String?
    let numberOfIds: Int
    let imageIds: [String]
}

struct LYwidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: SimpleEntry
    
    var text: String {
        var text = String(entry.numberOfIds)
        text += entry.numberOfIds == 1 ? " memory" : " memories"
        
        if let dateLastYear = entry.dateLastYear {
            text += " from \(Formatters.shortYearDateFormatter.string(from: dateLastYear))"
        }
        
        return text
    }
    
    var body: some View {
        switch widgetFamily {
        case .accessoryCircular:
            ZStack {
                Image(systemName: "arrow.counterclockwise")
                    .resizable()
                    .scaledToFit()
                    .clipped()
                    .padding(1)
                Text(String(entry.numberOfIds))
                    .padding(.top)
            }
        case .accessoryRectangular, .accessoryInline:
            ZStack {
                Color.blue.opacity(0.2)
                    .cornerRadius(20)
                Text(text)
                    .multilineTextAlignment(.center)
            }
        case .systemLarge:
            ZStack {
                Color("backgroundColor")
                VStack {
                    HStack {
                        Image(uiImage: Helper.getImageFromUserDefaults(key: entry.imageIds[0]))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .cornerRadius(20)
                        Image(uiImage: Helper.getImageFromUserDefaults(key: entry.imageIds[1]))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .cornerRadius(20)
                    }
                    HStack {
                        Image(uiImage: Helper.getImageFromUserDefaults(key: entry.imageIds[2]))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .cornerRadius(20)
                        Image(uiImage: Helper.getImageFromUserDefaults(key: entry.imageIds[3]))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .cornerRadius(20)
                    }
                }
                .padding(6)
            }
        case .systemMedium:
            if let imageID = entry.imageID {
                ZStack {
                    Color("backgroundColor")
                    HStack {
                        Image(uiImage: Helper.getImageFromUserDefaults(key: imageID))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .clipped()
                            .cornerRadius(20)
                            .padding(6)
                            .onAppear {
                                os_log("1 LOOKING FOR IMAGE %{public}@", log: OSLog.default, type: .debug, imageID)
                            }
                        VStack {
                            if let dateString = entry.dateString {
                                Text(dateString)
                                    .font(Font.custom("Poppins-Bold", size: 20))
                                    .foregroundColor(.white)
                            }
                            VStack(spacing: 0) {
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
                }
            } else {
                Text("No Image")
            }
        default:
            if let imageID = entry.imageID {
                ZStack {
                    Image(uiImage: Helper.getImageFromUserDefaults(key: imageID))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipped()
                    VStack(spacing: 0) {
                        Spacer()
                        if let dateString = entry.dateString {
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
                Text("No Image")
            }
        }
    }
}

@main
struct LYwidget: Widget {
    
    let kind: String = "LYwidget"
    
    var supportedTypes: [WidgetFamily] {
        if #available(iOS 16, *) {
            return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .accessoryCircular, .accessoryRectangular, .accessoryInline]
        } else {
            return [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        }
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LYwidgetEntryView(entry: entry)
        }
        .supportedFamilies(supportedTypes)
        .configurationDisplayName("Last Year")
        .description("The time machine widget.")
    }
}

struct LYwidget_Previews: PreviewProvider {
    static var previews: some View {
        LYwidgetEntryView(entry: SimpleEntry(date: Date.now, dateLastYear: Date.now, imageID: "", dateString: "", numberOfIds: 12, imageIds: []))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

extension Color {
    
    public static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
    
}
