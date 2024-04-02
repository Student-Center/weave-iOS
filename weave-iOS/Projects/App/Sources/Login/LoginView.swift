//
//  LoginView.swift
//  weave-ios
//
//  Created by 강동영 on 2/18/24.
//

import SwiftUI
import DesignSystem
import Services
import ComposableArchitecture

struct LoginView: View {
    @Dependency(\.coordinator) var coordinator
//    @EnvironmentObject private var coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Spacer()
            
            DesignSystem.Icons.appLogo
            Spacer()
            
            KakaoLoginButton(onComplte: { idToken in
                Task {
                    await requestSNSLogin(idToken: idToken, with: .kakao)
                }
            })
            Spacer()
                .frame(height: 16)
            
            AppleLoginButton(onComplte: { idToken in
                Task {
                    await requestSNSLogin(idToken: idToken, with: .apple)
                }
            })
            
            Spacer()
                .frame(height: 58)
        }
    }
    
    private func requestSNSLogin(idToken: String, with type: SNSLoginType) async {
        let endPoint = APIEndpoints.requestSNSLogin(idToken: idToken, with: type)
        do {
            let provider = try await APIProvider().requestSNSLogin(with: endPoint)
            UDManager.accessToken = provider.accessToken
            UDManager.refreshToken = provider.refreshToken
            landingToHomeView()
        } catch {
            print(error)
            // 에러로 전달 되는 회원가입 DTO 객체 처리
            if let networkError = error as? NetworkError {
                switch networkError {
                case .urlRequest(let innerError):
                    if let loginError = innerError as? LoginNetworkError {
                        switch loginError {
                        case .needRegist(let registerTokenResponse):
                            landingToSignUp(idToken: registerTokenResponse.registerToken)
                            return
                        }
                    }
                default: break
                }
            }
        }
    }
    
    private func landingToSignUp(idToken: String) {
        coordinator.changeRoot(to: .signUpView(registToken: idToken))
    }
    
    private func landingToHomeView() {
        coordinator.changeRoot(to: .mainView)
    }
}
