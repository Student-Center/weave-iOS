//
//  KakaoLoginButton.swift
//  weave-ios
//
//  Created by 강동영 on 2/19/24.
//

import SwiftUI
import DesignSystem
import KakaoSDKUser

struct KakaoLoginButton: View {
    var onComplte: ((String) -> Void)
    
    init(onComplte: @escaping ((String) -> Void)) {
        self.onComplte = onComplte
    }
    
    var body: some View {
        Button(action: {
            isAvailableOpenKakao()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(Color(red: 1, green: 0.9, blue: 0))
                HStack(spacing: 0) {
                    DesignSystem.Icons.kakaoLogo
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding(.all, 13)
                    Text("카카오 로그인")
                        .font(.pretendard(._600, size: 15))
                }
            }
            .foregroundStyle(.black)
        })
        .padding(.horizontal, 47)
        .frame(height: 44, alignment: .center)
    }
    
    private func isAvailableOpenKakao() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                if let error = error {
                    print("loginWithKakaoTalk error: \(error)")
                } else {
                    print("loginWithKakaoTalk() success.")
                    if let idToken = oauthToken?.idToken {
                        print("oauthToken: \(idToken)")
                        onComplte(idToken)
                    }
                }
            } 
        } else {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                if let error = error {
                    print("loginWithKakaoTalk error: \(error)")
                } else {
                    print("loginWithKakaoTalk() success.")
                    if let idToken = oauthToken?.idToken {
                        print("oauthToken: \(idToken)")
                        onComplte(idToken)
                    }
                }
            }
        }
    }
}

#Preview {
    KakaoLoginButton { _ in
        
    }
}
