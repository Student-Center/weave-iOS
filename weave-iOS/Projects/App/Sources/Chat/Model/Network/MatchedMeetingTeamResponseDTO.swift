//
//  MatchedMeetingTeamResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/21/24.
//

import Foundation
import Services
import CoreKit

struct MatchedMeetingTeamListResponseDTO: Codable {
    let items: [MatchedMeetingTeamInfoResponseDTO]
    let next: String?
    let total: Int?
    
    var toDomain: MatchedMeetingTeamList {
        return MatchedMeetingTeamList(
            items: items.map { $0.toDomain },
            next: next,
            total: total
        )
    }
}

struct MatchedMeetingTeamInfoResponseDTO: Codable {
    let id: String
    let memberCount: Int
    let otherTeam: MatchedMeetingTeamResponseDTO
    let status: String
    let createdAt: String
    
    var toDomain: MatchedMeetingTeamInfo {
        return MatchedMeetingTeamInfo(
            id: id,
            memberCount: memberCount,
            otherTeam: otherTeam.toDomain,
            status: status,
            createdAt: createdAt
        )
    }
}

struct MatchedMeetingTeamResponseDTO: Codable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let gender: String
    let location: String
    let memberInfos: [MatchedMeetingTeamMemberResponseDTO]
    
    var toDomain: MeetingTeamModel {
        return MeetingTeamModel(
            id: id,
            teamIntroduce: teamIntroduce,
            memberCount: memberCount,
            gender: gender,
            location: location,
            memberInfos: memberInfos.map { $0.toDomain }
        )
    }
}

struct MatchedMeetingTeamMemberResponseDTO: Codable {
    let id: String
    let userId: String
    let universityName: String
    let majorName: String
    let mbti: String
    let birthYear: Int
    let animalType: String
    let height: Int
    let isUnivVerified: Bool
    let avatar: String?
    
    var toDomain: MeetingMemberModel {
        return MeetingMemberModel(
            id: id,
            UserId: userId,
            universityName: universityName,
            majorName: majorName,
            mbti: mbti,
            birthYear: birthYear,
            animalType: animalType,
            height: height,
            isUnivVerified: isUnivVerified,
            avatar: avatar
        )
    }
}

struct MatchedMeetingTeamRequestDTO: Codable {
    let next: String?
    let limit: Int
     
    init(next: String?, limit: Int = 10) {
        self.next = next
        self.limit = limit
    }
}

extension APIEndpoints {
    static func getMatchedMeetingTeam(next: String?) -> EndPoint<MatchedMeetingTeamListResponseDTO> {
        let requestDTO = MatchedMeetingTeamRequestDTO(
            next: next
        )
        return EndPoint(
            path: "api/meetings/status/prepared",
            method: .get,
            queryParameters: requestDTO,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
