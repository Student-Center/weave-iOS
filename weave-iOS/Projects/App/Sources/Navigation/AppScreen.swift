//
//  AppScreen.swift
//  weave-ios
//
//  Created by 강동영 on 2/21/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case chat
    case request
    case home
    case myTeam
    case myPage
    
    var id: AppScreen { self }
}

@Observable final class TabViewCoordinator {
    public var currentTab: AppScreen
    
    static let shared: TabViewCoordinator = TabViewCoordinator()
    
    private init(currentTab: AppScreen = .home) {
        self.currentTab = currentTab
    }
    
    public func changeTab(to tab: AppScreen) {
        currentTab = tab
    }
}
