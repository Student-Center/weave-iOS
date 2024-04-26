//
//  SetKakaoIdRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/22/24.
//

import Foundation
import Services
import CoreKit

fileprivate struct SetKakaoIdRequestDTO: Encodable {
    let kakaoId: String
}

extension APIEndpoints {
    static func setMyKakaoId(kakaoId: String) -> EndPoint<EmptyResponse> {
        let request = SetKakaoIdRequestDTO(kakaoId: kakaoId)
        return EndPoint(
            path: "api/users/my/kakao-id",
            method: .patch,
            bodyParameters: request,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
