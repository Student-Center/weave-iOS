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
    @ObservedObject private var coordinator = AppCoordinator.shared
    @State private var networkErrorManager = ServiceErrorManager.shared
    
    var body: some View {
        NavigationStack(path: $coordinator.paths) {
            switch coordinator.currentRoot {
            case .splash:
                Text("스플래시")
            case .mainView:
                AppTabView(
                    store: Store(
                        initialState: AppTabViewFeature.State(),
                        reducer: {
                            AppTabViewFeature()
                        }
                    )
                )
            case .loginView:
                LoginView()
            case .signUpView(let registToken):
                SignUpView(
                    store: Store(
                        initialState: SignUpFeature.State(
                            registerToken: registToken
                        )
                    ) {
                        SignUpFeature()
                    }
                )
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
            currentRoot = viewType
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
                let userInfo = try await provider.request(with: endPoint)
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
