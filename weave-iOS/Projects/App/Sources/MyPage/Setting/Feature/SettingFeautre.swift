//
//  SettingFeautre.swift
//  weave-ios
//
//  Created by 강동영 on 3/11/24.
//

import SwiftUI
import ComposableArchitecture
import Services

struct SettingFeautre: Reducer {
    @Dependency(\.coordinator) var appCoordinator
    
    struct State: Equatable {
        @BindingState var isShowLogoutAlert: Bool = false
        @BindingState var isShowUnregisterAlert: Bool = false
    }
    
    enum Action: BindableAction {
        case inform
        case didTappedSubViews(view: SettingCategoryTypes.SettingSubViewTypes)
        case showLogoutAlert
        case showUnregisterAlert
        case resignSuccessed
        case binding(BindingAction<State>)
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
                case .logout:
                    state.isShowLogoutAlert = true
                case .unregister:
                    state.isShowUnregisterAlert = true
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
                
            case .binding(_):
                return .none
            }
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
        appCoordinator.changeRoot(to: .loginView)
    }
}
