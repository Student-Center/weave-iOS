//
//  SNSLoginRequestDTO.swift
//  weave-ios
//
//  Created by 강동영 on 2/18/24.
//

import Foundation
import Services

struct SNSLoginRequestDTO: Encodable {
    let idToken: String
}

enum SNSLoginType {
    case apple
    case kakao
    
    var pathProvider: String {
        switch self {
        case .apple:
            "APPLE"
        case .kakao:
            "KAKAO"
        }
    }
}

extension APIEndpoints {
    static func requestSNSLogin(idToken: String, with type: SNSLoginType) -> EndPoint<SNSLoginResponseDTO> {
        return EndPoint(
            path: "api/auth/login/\(type.pathProvider)",
            method: .post,
            bodyParameters: SNSLoginRequestDTO(idToken: idToken)
        )
    }
}
