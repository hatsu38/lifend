//
//  LifendWidget.swift
//  LifendWidget
//
//  Created by hatsu on 2025/07/10.
//

import WidgetKit
import SwiftUI

// ダークモード対応のカラーパレット
struct AppColors {
    static let primaryColor = Color(red: 0.424, green: 0.388, blue: 1.0) // #6C63FF
    static let secondaryColor = Color(red: 0.612, green: 0.153, blue: 0.690) // #9C27B0
    static let accentColor = Color(red: 1.0, green: 0.647, blue: 0.0) // #FFA500
    
    // ダークモード対応背景グラデーション
    static func backgroundGradient(for colorScheme: ColorScheme) -> [Color] {
        switch colorScheme {
        case .dark:
            return [
                Color(red: 0.1, green: 0.1, blue: 0.12),
                Color(red: 0.08, green: 0.08, blue: 0.1)
            ]
        case .light:
            return [
                Color(red: 0.95, green: 0.95, blue: 0.97),
                Color(red: 0.92, green: 0.92, blue: 0.96)
            ]
        @unknown default:
            return [
                Color(red: 0.95, green: 0.95, blue: 0.97),
                Color(red: 0.92, green: 0.92, blue: 0.96)
            ]
        }
    }
    
    static let primaryGradient = [primaryColor, secondaryColor]
    static let accentGradient = [accentColor, Color(red: 1.0, green: 0.4, blue: 0.4)]
    
    // ダークモード対応のカード背景色
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.15, green: 0.15, blue: 0.17).opacity(0.8)
        case .light:
            return Color.white.opacity(0.7)
        @unknown default:
            return Color.white.opacity(0.7)
        }
    }
    
    // ダークモード対応のセカンダリテキストカラー
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        switch colorScheme {
        case .dark:
            return Color(red: 0.7, green: 0.7, blue: 0.7)
        case .light:
            return Color.secondary
        @unknown default:
            return Color.secondary
        }
    }
}

// 表示設定構造体
struct DisplayConfig {
    let value: String
    let unit: String
    let color: Color
    
    static func getConfig(for type: DisplayType, from entry: SimpleEntry) -> DisplayConfig {
        switch type {
        case .days:
            return DisplayConfig(value: entry.days, unit: "日", color: AppColors.accentColor)
        case .weeks:
            return DisplayConfig(value: entry.weeks, unit: "週", color: AppColors.primaryColor)
        case .months:
            return DisplayConfig(value: entry.months, unit: "月", color: AppColors.secondaryColor)
        case .years:
            return DisplayConfig(value: entry.years, unit: "年", color: AppColors.primaryColor)
        }
    }
}

// 桁数に応じたフォントサイズ調整の拡張
extension String {
    /// カンマを除去して純粋な数字の桁数を取得
    func digitCount() -> Int {
        return self.replacingOccurrences(of: ",", with: "").count
    }
    
    /// 桁数に応じてフォントサイズを返す（メインディスプレイ用）
    func getFontSizeForDigitCount(isSmall: Bool = false) -> CGFloat {
        let digitCount = self.digitCount()
        let baseMultiplier: CGFloat = isSmall ? 0.9 : 1.0
        
        switch digitCount {
        case 1, 2:
            return 52 * baseMultiplier // 年（2桁）: さらに大きな文字サイズ
        case 3:
            return 42 * baseMultiplier // 月（3桁）: 中程度の文字サイズ
        case 4:
            return 36 * baseMultiplier // 週（4桁）: 小さめの文字サイズ
        case 5:
            fallthrough
        default:
            return 32 * baseMultiplier // 日（5桁以上）: 最小の文字サイズ
        }
    }
    
    /// 桁数に応じてフォントサイズを返す（詳細情報用）
    func getDetailFontSizeForDigitCount() -> CGFloat {
        let digitCount = self.digitCount()
        
        switch digitCount {
        case 1, 2:
            return 20 // 年（2桁）: より大きな文字サイズ
        case 3:
            return 18 // 月（3桁）: 中程度の文字サイズ
        case 4:
            return 16 // 週（4桁）: 小さめの文字サイズ
        case 5:
            fallthrough
        default:
            return 14 // 日（5桁以上）: 最小の文字サイズ
        }
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), years: "0", months: "0", weeks: "0", days: "0", targetAge: 0, displayType: .days)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let entry = getWidgetData(configuration: configuration)
        return entry
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = getWidgetData(configuration: configuration)
        
        // 次回更新は1時間後
        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        return Timeline(entries: [entry], policy: .after(nextUpdateDate))
    }
    
    func getWidgetData(configuration: ConfigurationAppIntent) -> SimpleEntry {
        let userDefaults = UserDefaults(suiteName: "group.lifend.homeWidget")
        let years = userDefaults?.string(forKey: "years") ?? "0"
        let months = userDefaults?.string(forKey: "months") ?? "0"
        let weeks = userDefaults?.string(forKey: "weeks") ?? "0"
        let days = userDefaults?.string(forKey: "days") ?? "0"
        let targetAge = userDefaults?.integer(forKey: "targetAge") ?? 0
        
        // 表示タイプを取得（App Intentから優先、フォールバックでUserDefaults）
        let displayType: DisplayType
        if let configDisplayType = configuration.displayType {
            displayType = configDisplayType
        } else {
            let displayTypeString = userDefaults?.string(forKey: "displayType") ?? "days"
            displayType = DisplayType(rawValue: displayTypeString) ?? .days
        }
        
        return SimpleEntry(date: Date(), configuration: configuration, years: years, months: months, weeks: weeks, days: days, targetAge: targetAge, displayType: displayType)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let years: String
    let months: String
    let weeks: String
    let days: String
    let targetAge: Int
    let displayType: DisplayType
}

struct LifendWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // ダークモード対応背景グラデーション
                LinearGradient(
                    colors: AppColors.backgroundGradient(for: colorScheme),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(spacing: 0) {
                    // ヘッダー部分
                    headerView
                        .padding(.horizontal, 8)
                        .padding(.top, 6)
                    
                    // メインコンテンツ（中央配置のため調整）
                    Spacer()
                    
                    mainContentView
                        .padding(.horizontal, 8)
                    
                    Spacer()
                }
            }
        }
    }
    
    // ヘッダービュー
    private var headerView: some View {
        HStack(spacing: 8) {
            // アイコン部分
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: AppColors.primaryGradient, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 36, height: 36)
                    .shadow(color: AppColors.primaryColor.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Text("🌟")
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.targetAge)歳まであと")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppColors.secondaryText(for: colorScheme))
            }
            
            Spacer()
        }
    }
    
    // メインコンテンツビュー
    private var mainContentView: some View {
        GeometryReader { geometry in
            let isSmallWidget = geometry.size.width < 180 // 小サイズの判定
            let displayConfig = DisplayConfig.getConfig(for: entry.displayType, from: entry)
            
            VStack(spacing: 12) {
                if displayConfig.value != "0" {
                    // 選択された表示タイプに応じた数値表示（中央配置を強化）
                    VStack(spacing: 8) {
                        displayValueView(config: displayConfig, isSmall: isSmallWidget)
                            .frame(maxWidth: .infinity) // 横幅いっぱいに
                        
                        // 中サイズのWidgetのみ詳細情報を表示
                        if !isSmallWidget {
                            detailInfoCard
                        }
                    }
                    
                } else {
                    // 達成表示
                    achievementView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 全体を中央配置
        }
    }
    
    // 表示値ビュー
    private func displayValueView(config: DisplayConfig, isSmall: Bool) -> some View {
        VStack(spacing: 6) {
            // 数値表示（中央配置を強化）
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Spacer() // 左側のスペーサー
                
                Text(config.value)
                    .font(.system(size: config.value.getFontSizeForDigitCount(isSmall: isSmall), weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [config.color, config.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                    )
                    .shadow(color: config.color.opacity(0.3), radius: 2, x: 0, y: 1)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Text(config.unit)
                    .font(.system(size: isSmall ? 18 : 24, weight: .bold))
                    .foregroundColor(AppColors.secondaryText(for: colorScheme))
                    .baselineOffset(-4)
                
                Spacer() // 右側のスペーサー
            }
            .frame(maxWidth: .infinity) // 横幅いっぱいに
        }
    }
    
    // 詳細情報カード
    private var detailInfoCard: some View {
        HStack(spacing: 12) {
            // 表示タイプに応じて、そのタイプ以外の3つの情報を表示
            switch entry.displayType {
            case .days:
                // 表示タイプが「日」の場合：年、月、週を表示（日は除く）
                DetailInfoItem(value: entry.years, unit: "年", color: AppColors.primaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.months, unit: "月", color: AppColors.secondaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.weeks, unit: "週", color: AppColors.accentColor, colorScheme: colorScheme)
                
            case .weeks:
                // 表示タイプが「週」の場合：年、月、日を表示（週は除く）
                DetailInfoItem(value: entry.years, unit: "年", color: AppColors.primaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.months, unit: "月", color: AppColors.secondaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.days, unit: "日", color: AppColors.accentColor, colorScheme: colorScheme)
                
            case .months:
                // 表示タイプが「月」の場合：年、週、日を表示（月は除く）
                DetailInfoItem(value: entry.years, unit: "年", color: AppColors.primaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.weeks, unit: "週", color: AppColors.secondaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.days, unit: "日", color: AppColors.accentColor, colorScheme: colorScheme)
                
            case .years:
                // 表示タイプが「年」の場合：月、週、日を表示（年は除く）
                DetailInfoItem(value: entry.months, unit: "月", color: AppColors.primaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.weeks, unit: "週", color: AppColors.secondaryColor, colorScheme: colorScheme)
                DetailInfoItem(value: entry.days, unit: "日", color: AppColors.accentColor, colorScheme: colorScheme)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.cardBackground(for: colorScheme))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // 達成表示
    private var achievementView: some View {
        VStack(spacing: 8) {
            Text("🎉")
                .font(.system(size: 40))
                .scaleEffect(1.2)
            
            Text("目標達成!")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(colors: AppColors.accentGradient, startPoint: .leading, endPoint: .trailing)
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.cardBackground(for: colorScheme))
                .shadow(color: AppColors.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
    
    // フッタービュー（空にする）
    private var footerView: some View {
        EmptyView()
    }
}

// 詳細情報アイテム
struct DetailInfoItem: View {
    let value: String
    let unit: String
    let color: Color
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(spacing: 2) {
            Text(value)
                .font(.system(size: value.getDetailFontSizeForDigitCount(), weight: .bold, design: .rounded))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(unit)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppColors.secondaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
    }
}

struct LifendWidget: Widget {
    let kind: String = "Lifend"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider(),
            content: { entry in
                LifendWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            }
        )
        .configurationDisplayName("Lifend")
        .description("目標年齢までの日数を表示")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var daysConfig: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayType = .days
        return intent
    }
    
    fileprivate static var weeksConfig: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayType = .weeks
        return intent
    }
    
    fileprivate static var monthsConfig: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayType = .months
        return intent
    }
    
    fileprivate static var yearsConfig: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.displayType = .years
        return intent
    }
}

#Preview(as: .systemSmall) {
    LifendWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .daysConfig, years: "5", months: "60", weeks: "260", days: "25,559", targetAge: 80, displayType: .days)
    SimpleEntry(date: .now, configuration: .weeksConfig, years: "5", months: "60", weeks: "260", days: "25,559", targetAge: 80, displayType: .weeks)
    SimpleEntry(date: .now, configuration: .monthsConfig, years: "5", months: "60", weeks: "260", days: "25,559", targetAge: 80, displayType: .months)
    SimpleEntry(date: .now, configuration: .yearsConfig, years: "5", months: "60", weeks: "260", days: "25,559", targetAge: 80, displayType: .years)
}
