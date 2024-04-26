//
//  SetKakaoIdFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/22/24.
//

import Foundation
import ComposableArchitecture
import Services

struct SetKakaoIdFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        @BindingState var kakaoIdText: String
        
        @BindingState var isShowConfirmAlert = false
        @BindingState var isShowCompleteAlert = false
        
        init() {
            self.kakaoIdText = String()
        }
    }
    
    enum Action: BindableAction {
        case didTappedSaveButton
        case requestSetId
        case didCompleteSetId
        
        case dismiss
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .didTappedSaveButton:
                state.isShowConfirmAlert.toggle()
                return .none
                
            case .requestSetId:
                return .run { [id = state.kakaoIdText] send in
                    try await requestSetKakaoId(id: id)
                    await send.callAsFunction(.didCompleteSetId)
                } catch: { error, send in
                    print(error)
                }
                
            case .didCompleteSetId:
                state.isShowCompleteAlert.toggle()
                return .none
                
            case .dismiss:
                return .run { send in
                    await dismiss()
                }
                
            default:
                return .none
            }
        }
    }
    
    func requestSetKakaoId(id: String) async throws {
        let endPoint = APIEndpoints.setMyKakaoId(kakaoId: id)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
}

