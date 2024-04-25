//
//  AppSuggestionRequestDTO.swift
//  Weave-ios
//
//  Created by 김지수 on 4/23/24.
//

import Foundation
import Services
import CoreKit

struct AppSuggestionRequestDTO: Codable {
    let contents: String
}

extension APIEndpoints {
    static func appSuggestionRequest(text: String) -> EndPoint<EmptyResponse> {
        let requestDTO = AppSuggestionRequestDTO(contents: text)
        return EndPoint(
            path: "api/suggestions",
            method: .post,
            bodyParameters: requestDTO,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
