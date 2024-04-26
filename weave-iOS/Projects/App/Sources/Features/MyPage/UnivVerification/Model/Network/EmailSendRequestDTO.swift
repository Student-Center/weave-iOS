//
//  EmailVerificationRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/20/24.
//

import Foundation
import Services
import CoreKit

struct EmailSendRequestDTO: Encodable {
    let universityEmail: String
}

struct EmptyResponse: Decodable {}

extension APIEndpoints {
    static func sendVerifyEmail(body: EmailSendRequestDTO) -> EndPoint<EmptyResponse> {
        return EndPoint(
            path: "api/users/my/university-verification:send",
            method: .post,
            bodyParameters: body,
            headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
