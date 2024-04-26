//
//  SettingResponseDTO.swift
//  weave-ios
//
//  Created by 강동영 on 3/19/24.
//

import Foundation
import Services
import CoreKit

struct SettingLogoutResponseDTO: Codable {}

extension APIEndpoints {
    static func postLogout() -> EndPoint<SettingLogoutResponseDTO> {
        return EndPoint(
            path: "api/auth/logout",
            method: .post,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
    
    static func deleteUnregister() -> EndPoint<SettingLogoutResponseDTO> {
        return EndPoint(
            path: "api/users",
            method: .delete,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
