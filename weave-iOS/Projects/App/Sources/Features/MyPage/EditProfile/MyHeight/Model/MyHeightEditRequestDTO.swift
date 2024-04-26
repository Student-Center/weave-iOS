//
//  MyHeightEditRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/24/24.
//

import Foundation
import Services
import CoreKit

struct MyHeightEditRequestDTO: Encodable {
    let height: Int
}

extension APIEndpoints {
    static func editMyHeight(body: MyHeightEditRequestDTO) -> EndPoint<EmptyResponse> {
        return EndPoint(
            path: "api/users/my/height",
            method: .patch,
            bodyParameters: body,
            headers: ["Authorization": "Bearer \(UDManager.accessToken)"]
        )
    }
}
