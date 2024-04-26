//
//  MyHeightEditFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/24/24.
//

import Foundation
import ComposableArchitecture
import Services

struct MyHeightEditFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        @BindingState var heightText: String
        
        init(height: Int?) {
            if let height {
                self.heightText = String(height)
            } else {
                self.heightText = String()
            }
        }
        
        init() {
            self.heightText = String()
        }
    }
    
    enum Action: BindableAction {
        case didTappedSaveButton
        case dismiss
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .didTappedSaveButton:
                return .run { [height = state.heightText] send in
                    try await requestEditMyProfile(height: Int(height)!)
                    await send.callAsFunction(.dismiss)
                } catch: { error, send in
                    print(error)
                }
                
            case .dismiss:
                return .run { send in
                    await dismiss()
                }
                
            default:
                return .none
            }
        }
    }
    
    func requestEditMyProfile(height: Int) async throws {
        let endPoint = APIEndpoints.editMyHeight(body: .init(height: height))
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
}
