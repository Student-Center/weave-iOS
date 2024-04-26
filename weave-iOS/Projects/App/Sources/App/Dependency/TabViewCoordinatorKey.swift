//
//  TabViewCoordinatorKey.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/28/24.
//

import Foundation
import ComposableArchitecture

enum TabViewCoordinatorKey: DependencyKey {
    static var liveValue: TabViewCoordinator {
        return TabViewCoordinator.shared
    }
}

extension DependencyValues {
    var tabViewCoordinator: TabViewCoordinator {
        get { self[TabViewCoordinatorKey.self] }
        set { self[TabViewCoordinatorKey.self] = newValue }
    }
}
