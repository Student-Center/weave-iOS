//
//  SettingFeautre.swift
//  weave-ios
//
//  Created by 강동영 on 3/11/24.
//

import SwiftUI
import ComposableArchitecture
import Services
import CoreKit

struct SettingFeautre: Reducer {
    @Dependency(\.coordinator) var appCoordinator
    
    struct State: Equatable {
        @BindingState var isShowLogoutAlert: Bool = false
        @BindingState var isShowUnregisterAlert: Bool = false
        @BindingState var isShowPasteSuccessAlert: Bool = false
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: BindableAction {
        case inform
        case didTappedDismiss
        case didTappedSubViews(view: SettingCategoryTypes.SettingSubViewTypes)
        case showLogoutAlert
        case showUnregisterAlert
        case resignSuccessed
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .inform:
                return .none
            case .didTappedSubViews(let type):
                switch type {
                case .termsAndConditions, .privacyPolicy:
                    if let url = type.url {
                        UIApplication.shared.open(url)
                    }
                case .myID:
                    UIPasteboard.general.string = "kakaoID"
                    state.isShowPasteSuccessAlert = true
                case .logout:
                    state.isShowLogoutAlert = true
                case .unregister:
                    state.isShowUnregisterAlert = true
                case .appSuggestion:
                    state.destination = .appSuggestion(.init())
                }
                return .none
            case .showLogoutAlert:
                return .run { send in
                    try await requestLogout()
                    resetLoginToken()
                    await send.callAsFunction(.resignSuccessed)
                } catch: { error, send in
                    print(error)
                    resetLoginToken()
                    await send.callAsFunction(.resignSuccessed)
                }
                
            case .showUnregisterAlert:
                return .run { send in
                    try await requestUnregist()
                    resetLoginToken()
                    await send.callAsFunction(.resignSuccessed)
                } catch: { error, send in
                    print(error)
                    resetLoginToken()
                    await send.callAsFunction(.resignSuccessed)
                }
                
            case .resignSuccessed:
                return .none
                
            case .didTappedDismiss:
                return .none
                
            case .binding(_):
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
          Destination()
        }
    }
    
    private func requestLogout() async throws {
        let endPoint = APIEndpoints.postLogout()
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint, successCode: 200)
    }
    
    private func requestUnregist() async throws {
        let endPoint = APIEndpoints.deleteUnregister()
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
    
    private func resetLoginToken() {
        UDManager.accessToken = ""
        UDManager.refreshToken = ""
    }
}

//MARK: - Destination
extension SettingFeautre {
    struct Destination: Reducer {
        enum State: Equatable {
            case appSuggestion(AppSuggestionFeature.State)
        }
        enum Action {
            case appSuggestion(AppSuggestionFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.appSuggestion, action: /Action.appSuggestion) {
                AppSuggestionFeature()
            }
        }
    }
}
