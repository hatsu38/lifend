//
//  LifendWidgetBundle.swift
//  LifendWidget
//
//  Created by hatsu on 2025/07/10.
//

import WidgetKit
import SwiftUI

@main
struct LifendWidgetBundle: WidgetBundle {
    var body: some Widget {
        LifendWidget()
        LifendWidgetControl()
        LifendWidgetLiveActivity()
    }
}
