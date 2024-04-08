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
    }
    
    enum Action: BindableAction {
        case didTappedLoginButton(idToken: String, type: SNSLoginType)
        
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didTappedLoginButton(let idToken, let type):
                requestSNSLogin(idToken: idToken, with: type)
                return .none
                
            default:
                return .none
            }
        }
    }
    
    private func requestSNSLogin(idToken: String, with type: SNSLoginType) {
        let endPoint = APIEndpoints.requestSNSLogin(idToken: idToken, with: type)
        Task {
            do {
                let provider = try await APIProvider().requestSNSLogin(with: endPoint)
                UDManager.accessToken = provider.accessToken
                UDManager.refreshToken = provider.refreshToken
                appCoordinator.changeRoot(to: .mainView)
            } catch {
                switch error as? LoginNetworkError {
                case .needRegist(let registerTokenResponse):
                    appCoordinator.changeRoot(to: .signUpView(registToken: registerTokenResponse.registerToken))
                case .none:
                    return
                }
            }
        }
    }
}
