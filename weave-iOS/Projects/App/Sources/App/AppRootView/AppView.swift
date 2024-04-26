//
//  AppView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/9/24.
//

import SwiftUI
import DesignSystem
import Services
import ComposableArchitecture
import CoreKit

struct AppView: View {

    let store: StoreOf<AppViewFeature>
    
    @ObservedObject private var coordinator = AppCoordinator.shared
    @State private var networkErrorManager = ServiceErrorManager.shared
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                IfLetStore(
                    store.scope(
                        state: \.splashState,
                        action: { .splashAction( $0 ) }
                    )
                ) { subStore in
                    SplashView(store: subStore)
                }
                
                IfLetStore(
                    store.scope(
                        state: \.mainState,
                        action: { .mainAction( $0 ) }
                    )
                ) { subStore in
                    AppTabView(store: subStore)
                }
                
                IfLetStore(
                    store.scope(
                        state: \.loginState,
                        action: { .loginAction( $0 ) }
                    )
                ) { subStore in
                    LoginView(store: subStore)
                }
                
                IfLetStore(
                    store.scope(
                        state: \.signUpState,
                        action: { .signUpAction( $0 ) }
                    )
                ) { subStore in
                    SignUpView(store: subStore)
                }
                .onReceive(NotificationManager.publisher(.splash)) { _ in
                    store.send(.changeRoot(.splash), animation: .default)
                }
                .onReceive(NotificationManager.publisher(.main)) { _ in
                    store.send(.changeRoot(.mainView), animation: .default)
                }
                .onReceive(NotificationManager.publisher(.login)) { _ in
                    store.send(.changeRoot(.loginView), animation: .default)
                }
                .onReceive(NotificationManager.publisher(.signUp)) { hashable in
                    if let registToken = hashable?["registToken"] as? String {
                        store.send(.changeRoot(.signUpView(registToken: registToken)), animation: .default)
                    }
                }
            }
        }
    }
}
