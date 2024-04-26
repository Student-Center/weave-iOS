//
//  UserInfo.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/18/24.
//

import Foundation
import Services

enum UserInfo {
    static var myInfo: MyUserInfoModel?
    
    static func updateUserInfo() async throws {
        let endPoint = APIEndpoints.getMyUserInfo()
        let provider = APIProvider()
        let userInfo = try await provider.request(with: endPoint, showErrorAlert: false)
        UserInfo.myInfo = userInfo.toDomain
    }
}
