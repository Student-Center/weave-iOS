//
//  LoginFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 4/2/24.
//

import Foundation
import Services
import CoreKit
import ComposableArchitecture

struct LoginFeature: Reducer {
    @Dependency(\.coordinator) var appCoordinator
    
    struct State: Equatable {
        @BindingState var needShowErrorAlert = false
        var registerToken: String?
    }
    
    enum Action: BindableAction {
        case didTappedLoginButton(idToken: String, type: SNSLoginType)
        
        case didSuccessedLogin
        case fetchRegisterToken(registerToken: String)
        case needRegistUser
        
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didTappedLoginButton(let idToken, let type):
                return .run { send in
                    try await requestSNSLogin(idToken: idToken, with: type)
                    try await UserInfo.updateUserInfo()
                    await send.callAsFunction(.didSuccessedLogin)
                } catch: { error, send in
                    switch error as? LoginNetworkError {
                    case .needRegist(let registerTokenResponse):
                        await send.callAsFunction(.fetchRegisterToken(registerToken: registerTokenResponse.registerToken))
                    case .none:
                        return
                    }
                }
                
            case .didSuccessedLogin:
                return .none
                
            case .fetchRegisterToken(let registerToken):
                state.registerToken = registerToken
                return .send(.needRegistUser)
                
            default:
                return .none
            }
        }
    }
    
    private func requestSNSLogin(idToken: String, with type: SNSLoginType) async throws {
        let endPoint = APIEndpoints.requestSNSLogin(idToken: idToken, with: type)
        let provider = try await APIProvider().requestSNSLogin(with: endPoint)
        UDManager.accessToken = provider.accessToken
        UDManager.refreshToken = provider.refreshToken
        appCoordinator.changeRoot(to: .mainView)
    }
}
