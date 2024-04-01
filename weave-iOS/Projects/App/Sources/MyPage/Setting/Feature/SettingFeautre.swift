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
    
    struct State: Equatable {
        @BindingState var isShowLogoutAlert: Bool = false
        @BindingState var isShowUnregisterAlert: Bool = false
        @BindingState var isShowPasteSuccessAlert: Bool = false
    }
    
    enum Action: BindableAction {
        case inform
        case didTappedSubViews(view: SettingCategoryTypes.SettingSubViewTypes)
        case showLogoutAlert(model: AppCoordinator)
        case showUnregisterAlert(model: AppCoordinator)
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
                case .myID:
                    // TODO: kakaoID 복사
                    UIPasteboard.general.string = "kakaoID"
                    state.isShowPasteSuccessAlert = true
                case .logout:
                    state.isShowLogoutAlert = true
                case .unregister:
                    state.isShowUnregisterAlert = true
                }
                return .none
            case .showLogoutAlert(let coordinator):
                return .run { send in
                    try await requestLogout()
                    resetLoginToken(with: coordinator)
                } catch: { error, send in
                    print(error)
                    resetLoginToken(with: coordinator)
                }
                
            case .showUnregisterAlert(let coordinator):
                return .run { send in
                    try await requestUnregist()
                    resetLoginToken(with: coordinator)
                } catch: { error, send in
                    print(error)
                    resetLoginToken(with: coordinator)
                }
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
    
    private func resetLoginToken(with coordinator: AppCoordinator) {
        UDManager.accessToken = ""
        UDManager.refreshToken = ""
        Task {
            await coordinator.changeRoot(to: .loginView)
        }
    }
}
