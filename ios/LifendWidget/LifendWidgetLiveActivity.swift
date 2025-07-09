//
//  LifendWidgetLiveActivity.swift
//  LifendWidget
//
//  Created by hatsu on 2025/07/10.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LifendWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LifendWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LifendWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LifendWidgetAttributes {
    fileprivate static var preview: LifendWidgetAttributes {
        LifendWidgetAttributes(name: "World")
    }
}

extension LifendWidgetAttributes.ContentState {
    fileprivate static var smiley: LifendWidgetAttributes.ContentState {
        LifendWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LifendWidgetAttributes.ContentState {
         LifendWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LifendWidgetAttributes.preview) {
   LifendWidgetLiveActivity()
} contentStates: {
    LifendWidgetAttributes.ContentState.smiley
    LifendWidgetAttributes.ContentState.starEyes
}
