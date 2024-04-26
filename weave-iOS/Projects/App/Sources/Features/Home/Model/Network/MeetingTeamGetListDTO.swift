//
//  MeetingTeamGetListDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/29/24.
//

import Foundation
import Services
import CoreKit

struct MeetingTeamGetListDTO: Codable {
    let items: [MeetingTeamDTO]
    let next: String?
    let total: Int
    
    var toDomain: MeetingTeamListModel {
        return MeetingTeamListModel(
            items: items.map { $0.toDomain },
            next: next,
            total: total
        )
    }
}

// MARK: - Item
struct MeetingTeamDTO: Codable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let gender: String?
    let location: String
    let memberInfos: [MeetingMemberDTO]
    
    var toDomain: MeetingTeamModel {
        MeetingTeamModel(
            id: id,
            teamIntroduce: teamIntroduce,
            memberCount: memberCount,
            gender: gender,
            location: location,
            memberInfos: memberInfos.map { $0.toDomain }
        )
    }
}

// MARK: - MemberInfo
struct MeetingMemberDTO: Codable {
    let id: String
    let universityName: String
    let mbti: String
    let birthYear: Int
    let animalType: String?
    
    var toDomain: MeetingMemberModel {
        MeetingMemberModel(
            id: id,
            UserId: nil,
            universityName: universityName,
            majorName: nil,
            mbti: mbti,
            birthYear: birthYear,
            animalType: animalType, 
            height: nil,
            isUnivVerified: nil,
            avatar: nil
        )
    }
}

extension APIEndpoints {
    static func getMeetingTeamList(requestDTO: MeetingTeamGetListRequestDTO) -> EndPoint<MeetingTeamGetListDTO> {
        return EndPoint(
            path: "api/meeting-teams",
            method: .get,
            queryParameters: requestDTO,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
