//
//  LifendWidget.swift
//  LifendWidget
//
//  Created by hatsu on 2025/07/10.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), years: "0", months: "0", weeks: "0", days: "0", targetAge: 0)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let entry = getWidgetData()
        return SimpleEntry(date: Date(), configuration: configuration, years: entry.years, months: entry.months, weeks: entry.weeks, days: entry.days, targetAge: entry.targetAge)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entryData = getWidgetData()
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, configuration: configuration, years: entryData.years, months: entryData.months, weeks: entryData.weeks, days: entryData.days, targetAge: entryData.targetAge)
        
        // 次回更新は1時間後
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdateDate))
    }
    
    func getWidgetData() -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.lifend.homeWidget")
        let years = userDefaults?.string(forKey: "years") ?? "0"
        let months = userDefaults?.string(forKey: "months") ?? "0"
        let weeks = userDefaults?.string(forKey: "weeks") ?? "0"
        let days = userDefaults?.string(forKey: "days") ?? "0"
        let targetAge = userDefaults?.integer(forKey: "targetAge") ?? 0
        
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), years: years, months: months, weeks: weeks, days: days, targetAge: targetAge)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let years: String
    let months: String
    let weeks: String
    let days: String
    let targetAge: Int
}

struct LifendWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 8) {
            // ヘッダー
            HStack {
                Text("🌟")
                    .font(.title2)
                Text("Lifend")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Spacer()
            
            // メインコンテンツ
            VStack(spacing: 6) {
                Text("目標まであと")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if entry.days != "0" {
                    VStack(spacing: 2) {
                        Text(entry.days)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("日")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(spacing: 2) {
                        Text("🎉")
                            .font(.title)
                        Text("達成!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // フッター
            HStack {
                Spacer()
                Text("目標: \(entry.targetAge)歳")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct LifendWidget: Widget {
    let kind: String = "LifendWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            LifendWidgetEntryView(entry: entry)
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
    LifendWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, years: "5", months: "60", weeks: "260", days: "1,825", targetAge: 80)
    SimpleEntry(date: .now, configuration: .starEyes, years: "10", months: "120", weeks: "520", days: "3,650", targetAge: 85)
}
