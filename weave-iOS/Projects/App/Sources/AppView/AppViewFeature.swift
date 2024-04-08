//
//  AppFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 4/2/24.
//

import SwiftUI
import ComposableArchitecture
import CoreKit

struct AppViewFeature: Reducer {
    
    struct State: Equatable {
        var splashState: SplashFeature.State? = .init()
        var mainState: AppTabViewFeature.State?
        var loginState: LoginFeature.State?
        var signUpState: SignUpFeature.State?
    }
    
    enum Action {
        case changeRoot(AppCoordinator.RootViewType)
        
        case splashAction(SplashFeature.Action)
        case mainAction(AppTabViewFeature.Action)
        case loginAction(LoginFeature.Action)
        case signUpAction(SignUpFeature.Action)
        
        case showWelcomeAlert
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .changeRoot(let type):
                switch type {
                case .splash:
                    state.splashState = .init()
                    state.mainState = nil
                    state.loginState = nil
                    state.signUpState = nil
                case .mainView:
                    state.splashState = nil
                    state.mainState = .init()
                    state.loginState = nil
                    state.signUpState = nil
                case .loginView:
                    state.splashState = nil
                    state.mainState = nil
                    state.loginState = .init()
                    state.signUpState = nil
                case .signUpView(let registerToken):
                    state.splashState = nil
                    state.mainState = nil
                    state.loginState = nil
                    state.signUpState = .init(registerToken: registerToken)
                }
                
            case .signUpAction(.didCompleteSignUp):
                return .run { send in
                    await send.callAsFunction(.changeRoot(.mainView), animation: .default)
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await send.callAsFunction(.showWelcomeAlert)
                }
                
            case .showWelcomeAlert:
                state.mainState?.isShowWelcomeAlert = true
                return .none
                
            default:
                break
            }
            
            return .none
        }
        .ifLet(\.splashState, action: /Action.splashAction) {
            SplashFeature()
        }
        .ifLet(\.mainState, action: /Action.mainAction) {
            AppTabViewFeature()
        }
        .ifLet(\.loginState, action: /Action.loginAction) {
            LoginFeature()
        }
        .ifLet(\.signUpState, action: /Action.signUpAction) {
            SignUpFeature()
        }
    }
}
