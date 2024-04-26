//
//  MeetingTeamInfoResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/26/24.
//

import Services
import Foundation
import CoreKit

struct MeetingTeamInfoResponseDTO: Decodable {
    let teamId: String
    let teamIntroduce: String
    let status: String
    
    var toDomain: MeetingTeamInfoModel {
        return MeetingTeamInfoModel(
            teamId: teamId,
            teamIntroduce: teamIntroduce,
            status: status
        )
    }
}

extension APIEndpoints {
    static func getMeetingTeamInfo(invitationCode: String) -> EndPoint<MeetingTeamInfoResponseDTO> {
        return EndPoint(
            path: "api/meeting-teams/invitation/\(invitationCode)",
            method: .get,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
    
    static func acceptInvitation(_ invitationCode: String) -> EndPoint<EmptyResponse> {
        return EndPoint(
            path: "api/meeting-teams/invitation/\(invitationCode)",
            method: .post,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
