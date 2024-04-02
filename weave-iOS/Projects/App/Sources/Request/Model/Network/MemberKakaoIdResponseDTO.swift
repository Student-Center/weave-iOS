//
//  MemberKakaoIdResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/20/24.
//

import Foundation
import Services
import CoreKit

struct MeetingTeamKakaoIdResponseDTO: Decodable {
    let members: [MemberKakaoIdResponseDTO]
}

struct MemberKakaoIdResponseDTO: Decodable {
    let memberId: String
    let kakaoId: String
}

extension APIEndpoints {
    static func getOtherTeamKakaoId(meetingId: String) -> EndPoint<MeetingTeamKakaoIdResponseDTO> {
        return EndPoint(
            path: "api/meetings/\(meetingId)/other-team/kakao-id",
            method: .get,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
