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
import CoreKit

struct LoginView: View {
    @Dependency(\.coordinator) var coordinator
    @State private var networkErrorManager = ServiceErrorManager.shared
    
    let store: StoreOf<LoginFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                
                DesignSystem.Icons.appLogo
                Spacer()
                
                KakaoLoginButton(onComplte: { idToken in
                    viewStore.send(.didTappedLoginButton(idToken: idToken, type: .kakao))
                })
                Spacer()
                    .frame(height: 16)
                
                AppleLoginButton(onComplte: { idToken in
                    viewStore.send(.didTappedLoginButton(idToken: idToken, type: .apple))
                })
                
                Spacer()
                    .frame(height: 58)
            }
            .weaveErrorMessage(
                isPresented: $networkErrorManager.needShowErrorAlert,
                message: networkErrorManager.errorMessage
            ) {
                networkErrorManager.handleAlertConfirmAction()
            }
        }
    }
}

#Preview {
    LoginView(store: .init(initialState: LoginFeature.State(), reducer: {
        LoginFeature()
    }))
}
