//
//  AppCoordinator.swift
//  weave-ios
//
//  Created by Jisu Kim on 4/3/24.
//

import SwiftUI
import CoreKit
import Services

@Observable final class AppCoordinator: ObservableObject {
    
    static let shared: AppCoordinator = AppCoordinator()
    
    enum RootViewType: Hashable {
        case splash
        case mainView
        case loginView
        case signUpView(registToken: String)
    }
    
    public func changeRoot(to viewType: RootViewType) {
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

    private init() {
        // 첫 화면은 스플래시
        requestAuthValidateWithProfile()
        bindRootViewState()
    }
    
    func requestAuthValidateWithProfile() {
        // 토큰들이 없다면 로그인페이지로
        guard UDManager.isLogin else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.changeRoot(to: .loginView)
            }
            return
        }
        
        // 내 프로필 정보를 부르면서 토큰검증 & 유저데이터 저장
        Task {
            do {
                let endPoint = APIEndpoints.getMyUserInfo()
                let provider = APIProvider(session: URLSession.shared)
                let userInfo = try await provider.request(with: endPoint, showErrorAlert: false)
                UserInfo.myInfo = userInfo.toDomain
                try await Task.sleep(nanoseconds: 1_000_000_000)
                self.changeRoot(to: .mainView)
            } catch {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                self.changeRoot(to: .loginView)
            }
        }
    }
    
    // RootView 가 변경되어 강제로 로그인 뷰로 전환될 때 액션 바인딩
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
