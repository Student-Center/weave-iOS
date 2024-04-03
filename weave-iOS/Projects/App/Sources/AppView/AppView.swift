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
            NavigationStack(path: $coordinator.paths) {
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
                    store.send(.changeRoot(.splash))
                }
                .onReceive(NotificationManager.publisher(.main)) { _ in
                    store.send(.changeRoot(.mainView))
                }
                .onReceive(NotificationManager.publisher(.login)) { _ in
                    store.send(.changeRoot(.loginView))
                }
                .onReceive(NotificationManager.publisher(.signUp)) { hashable in
                    if let registToken = hashable?["registToken"] as? String {
                        store.send(.changeRoot(.signUpView(registToken: registToken)))
                    }
                }
            }
        }
    }
}




@Observable final class AppCoordinator: ObservableObject {
    var paths: [RootViewType] = []
    private(set) var currentRoot: RootViewType
    
    static let shared: AppCoordinator = AppCoordinator()
    
    enum RootViewType: Hashable {
        case splash
        case mainView
        case loginView
        case signUpView(registToken: String)
    }
    
    public func changeRoot(to viewType: RootViewType) {
        withAnimation {
            print(paths.count)
            if paths.count > 1 {
                paths.removeLast()
            }
            currentRoot = viewType
            switch viewType {
            case .splash:
                NotificationManager.post(.splash)
            case .mainView:
                NotificationManager.post(.main)
            case .loginView:
                NotificationManager.post(.login)
            case .signUpView(let registToken):
                NotificationManager.post(.signUp, userInfo: ["registToken": registToken])
            }
        }
    }
    
    public func appendPath(_ path: RootViewType) {
        paths.append(path)
    }
    private init() {
        // 첫 화면은 스플래시
        currentRoot = .splash
        
        requestAuthValidateWithProfile()
        bindRootViewState()
    }
    
    func requestAuthValidateWithProfile() {
        // 토큰들이 없다면 로그인페이지로
        guard UDManager.isLogin else {
            changeRoot(to: .loginView)
            return
        }
        
        // 내 프로필 정보를 부르면서 토큰검증 & 유저데이터 저장
        Task {
            do {
                let endPoint = APIEndpoints.getMyUserInfo()
                let provider = APIProvider(session: URLSession.shared)
                let userInfo = try await provider.request(with: endPoint, showErrorAlert: false)
                UserInfo.myInfo = userInfo.toDomain
                changeRoot(to: .mainView)
            } catch {
                changeRoot(to: .loginView)
            }
        }
    }
    
    func bindRootViewState() {
        AuthStateManager.stateHandler = { [weak self] state in
            if state == .forceToLogin {
                UDManager.accessToken = ""
                UDManager.refreshToken = ""
                self?.changeRoot(to: .loginView)
            }
        }
    }
}

//switch coordinator.currentRoot {
//case .splash:
//    SplashView(
//        store: Store(
//            initialState: SplashFeature.State(),
//            reducer: {
//                SplashFeature()
//            }
//        )
//    )
//case .mainView:
//    AppTabView(
//        store: Store(
//            initialState: AppTabViewFeature.State(),
//            reducer: {
//                AppTabViewFeature()
//            }
//        )
//    )
//case .loginView:
//    LoginView(
//        store: Store(
//            initialState: LoginFeature.State()
//        ) {
//            LoginFeature()
//        }
//    )
//case .signUpView(let registToken):
//    SignUpView(
//        store: Store(
//            initialState: SignUpFeature.State(
//                registerToken: registToken
//            )
//        ) {
//            SignUpFeature()
//        }
//    )
//}
