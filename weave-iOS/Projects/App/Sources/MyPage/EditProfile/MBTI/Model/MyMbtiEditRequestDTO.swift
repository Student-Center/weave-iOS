//
//  MyMbtiEditRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/26/24.
//

import Foundation
import Services
import CoreKit

struct MyMbtiEditRequestDTO: Encodable {
    let mbti: String
}

extension APIEndpoints {
    static func editMyMbti(body: MyMbtiEditRequestDTO) -> EndPoint<EmptyResponse> {
        return EndPoint(
            path: "api/users/my/mbti",
            method: .patch,
            bodyParameters: body,
            headers: ["Authorization": "Bearer \(UDManager.accessToken)"]
        )
    }
}
