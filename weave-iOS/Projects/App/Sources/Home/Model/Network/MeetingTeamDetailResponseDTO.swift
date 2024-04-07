//
//  MeetingTeamDetailResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/2/24.
//

import Foundation
import Services
import DesignSystem
import CoreKit

struct MeetingTeamDetailResponseDTO: Codable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let location: String
    let gender: String
    let members: [MeetingTeamDetailMemberDTO]
    let status: String
    let affinityScore: Int?
    
    var toDomain: MeetingTeamDetailModel {
        return MeetingTeamDetailModel(
            id: id,
            teamIntroduce: teamIntroduce,
            memberCount: memberCount,
            location: location,
            gender: gender,
            members: members.map {
                MeetingTeamDetailMemberModel(
                    userId: $0.userId,
                    universityName: $0.universityName,
                    majorName: $0.majorName,
                    mbti: MBTIType(rawValue: $0.mbti.uppercased()),
                    birthYear: $0.birthYear,
                    role: $0.role,
                    animalType: $0.animalType,
                    height: $0.height,
                    isUnivVerified: $0.isUnivVerified
                )
            },
            status: status,
            affinityScore: affinityScore
        )
    }
}

struct MeetingTeamDetailMemberDTO: Codable {
    let userId: String
    let universityName: String
    let majorName: String
    let mbti: String
    let birthYear: Int
    let role: String
    let animalType: String
    let height: Int?
    let isUnivVerified: Bool
}

extension APIEndpoints {
    static func getMeetingTeamDetail(teamId: String) -> EndPoint<MeetingTeamDetailResponseDTO> {
        return EndPoint(
            path: "api/meeting-teams/\(teamId)",
            method: .get,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
