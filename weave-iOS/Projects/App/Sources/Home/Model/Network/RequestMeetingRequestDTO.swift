//
//  RequestMeetingRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/2/24.
//

import Foundation
import Services
import CoreKit

struct RequestMeetingRequestDTO: Encodable {
    let receivingMeetingTeamId: String
}

extension APIEndpoints {
    static func getRequestMeeting(requestDTO: RequestMeetingRequestDTO) -> EndPoint<MeetingTeamDetailResponseDTO> {
        return EndPoint(
            path: "api/meetings",
            method: .post,
            bodyParameters: requestDTO,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
