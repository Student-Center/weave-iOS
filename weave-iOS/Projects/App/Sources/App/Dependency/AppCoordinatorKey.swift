//
//  CoordinatorKey.swift
//  weave-ios
//
//  Created by 강동영 on 3/19/24.
//

import Foundation
import ComposableArchitecture

enum CoordinatorKey: DependencyKey {
    static var liveValue: AppCoordinator = AppCoordinator.shared
}

extension DependencyValues {
    var coordinator: AppCoordinator {
        get { self[CoordinatorKey.self] }
        set { self[CoordinatorKey.self] = newValue }
    }
}
