//
//  AppleLoginButton.swift
//  weave-ios
//
//  Created by 강동영 on 2/19/24.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginButton: View {
    var onComplte: ((String) -> Void)
    
    init(onComplte: @escaping ((String) -> Void)) {
        self.onComplte = onComplte
    }
    
    var body: some View {
        SignInWithAppleButton(.signIn) { requset in
            requset.requestedScopes = [.email, .fullName]
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                print("Authorisation successful")
                print("authResults: \(authResults)")
                
                // 비밀번호 및 페이스ID
                if let appleIdCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                    guard let appleIdToken = appleIdCredential.identityToken else {
                        return
                    }
                    
                    guard let idTokenString = String(data: appleIdToken, encoding: .utf8) else {
                        return
                    }
                    onComplte(idTokenString)
                }
                
                // iCloud의 패스워드
                if let passwordCredential = authResults.credential as? ASPasswordCredential {
                }
                
            case .failure(let error):
                print("Authorisation failed: \(error.localizedDescription)")
            }
        }
        .padding(.horizontal, 47)
        .frame(height: 44, alignment: .center)
        .signInWithAppleButtonStyle(.whiteOutline)
    }
    
}

#Preview {
    AppleLoginButton { _ in
        
    }
}
