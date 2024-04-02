//
//  AppView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/9/24.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    @State private var coordinator = AppCoordinator.shared
    
    var body: some View {
        NavigationStack(path: $coordinator.paths) {
            switch coordinator.currentRoot {
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
        if UDManager.isLogin {
            currentRoot = .mainView
        } else {
            currentRoot = .loginView
        }
    }
}
