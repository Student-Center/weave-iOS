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
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        @BindingState var inputText: String = ""
        @BindingState var isShowCompleteAlert: Bool = false
    }
    
    enum Action: BindableAction {
        case didTappedDismiss
        case didTappedSummitButton
        case requestSuggestionText
        case replaceInputText(text: String)
        case didSuccessedSummit
        case didTappedUserCompleteButton
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didTappedDismiss:
                return .run { send in
                    await dismiss()
                }
            case .replaceInputText(let text):
                state.inputText = text
                return .none
            case .didTappedSummitButton:
                return .send(.requestSuggestionText)
            case .requestSuggestionText:
                return .run { [text = state.inputText] send in
                    try await requestSuggestionText(text: text)
                    await send.callAsFunction(.didSuccessedSummit)
                } catch: { error, send in
                    print(error)
                }
            case .didSuccessedSummit:
                state.isShowCompleteAlert = true
                return .none
            case .didTappedUserCompleteButton:
                return .run { send in
                    await dismiss()
                }
            case .binding(_):
                return .none
            }
        }
    }
    
    func requestSuggestionText(text: String) async throws {
        let endPoint = APIEndpoints.appSuggestionRequest(text: text)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint, successCode: 201)
    }
}
