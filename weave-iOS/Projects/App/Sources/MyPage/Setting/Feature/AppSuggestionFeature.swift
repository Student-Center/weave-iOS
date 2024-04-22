//
//  AppSuggestionFeature.swift
//  Weave-ios
//
//  Created by 김지수 on 4/22/24.
//

import Foundation
import ComposableArchitecture
import Services
import CoreKit

struct AppSuggestionFeature: Reducer {
    @Dependency(\.coordinator) var appCoordinator
    
    struct State: Equatable {

    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {

            case .binding(_):
                return .none
            }
        }
    }
}
