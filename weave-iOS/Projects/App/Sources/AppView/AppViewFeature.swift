//
//  AppFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 4/2/24.
//

import Foundation
import ComposableArchitecture

struct AppViewFeature: Reducer {
    @Dependency(\.coordinator) var appCoordinator
    
    struct State: Equatable {
        
    }
    
    enum Action {
        
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
        }
    }
}
