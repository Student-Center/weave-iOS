//
//  MyTeamInviteResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/9/24.
//

import Foundation
import Services
import CoreKit

struct MyTeamInviteResponseDTO: Decodable {
    let meetingTeamInvitationLink: String
    let meetingTeamInvitationCode: String
}

extension APIEndpoints {
    static func createInviteLink(teamId: String) -> EndPoint<MyTeamInviteResponseDTO> {
        return EndPoint(
            path: "api/meeting-teams/\(teamId)/invitation",
            method: .post,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
