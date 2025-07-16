//
//  AppIntent.swift
//  LifendWidget
//
//  Created by hatsu on 2025/07/10.
//

import WidgetKit
import AppIntents

// 表示タイプの定義
enum DisplayType: String, CaseIterable, AppEnum {
    case days = "days"
    case weeks = "weeks"
    case months = "months"
    case years = "years"
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "表示タイプ")
    }
    
    static var caseDisplayRepresentations: [DisplayType: DisplayRepresentation] {
        [
            .days: DisplayRepresentation(title: "日数", subtitle: "残り日数を表示"),
            .weeks: DisplayRepresentation(title: "週数", subtitle: "残り週数を表示"),
            .months: DisplayRepresentation(title: "月数", subtitle: "残り月数を表示"),
            .years: DisplayRepresentation(title: "年数", subtitle: "残り年数を表示")
        ]
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "表示設定" }
    static var description: IntentDescription { "Widgetに表示する時間単位を選択してください" }
    
    @Parameter(title: "表示タイプ", description: "表示する時間単位を選択")
    var displayType: DisplayType?
    
    init() {
        self.displayType = .days  // デフォルト値
    }
}
