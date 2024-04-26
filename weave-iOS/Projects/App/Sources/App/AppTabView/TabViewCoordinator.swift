//
//  TabViewCoordinator.swift
//  Weave-ios
//
//  Created by Jisu Kim on 4/26/24.
//

import Foundation

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
