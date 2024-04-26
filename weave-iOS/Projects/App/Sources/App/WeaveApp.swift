//
//  WeaveApp.swift
//  Weave
//
//  Created by 강동영 on 11/28/23.
//

import SwiftUI
import ComposableArchitecture
import CoreKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

@main
struct WeaveApp: App {
    
    let store: StoreOf<AppViewFeature>
    
    init() {
        self.store = .init(initialState: AppViewFeature.State(), reducer: {
            AppViewFeature()
        })
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: SecretKey.kakaoNativeKey)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .onOpenURL(perform: { url in
                    if (AuthApi.isKakaoTalkLoginUrl(url)) {
                        AuthController.handleOpenUrl(url: url)
                    }
                })
        }
    }
}
