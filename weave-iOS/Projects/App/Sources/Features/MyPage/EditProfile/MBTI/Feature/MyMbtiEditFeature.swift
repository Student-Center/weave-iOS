//
//  MyMbtiEditFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/26/24.
//

import Foundation
import ComposableArchitecture
import Services
import DesignSystem

struct MyMbtiEditFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        @BindingState var mbtiDataModel: MBTIDataModel
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
                return .run { [mbti = state.mbtiDataModel] send in
                    try await requestMyMBTIData(mbti: mbti)
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
    
    func requestMyMBTIData(mbti: MBTIDataModel) async throws {
        let endPoint = APIEndpoints.editMyMbti(body: .init(mbti: mbti.requestValue))
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
}
