//
//  MyTeamListResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/6/24.
//

import Foundation
import Services
import CoreKit

struct MyTeamListResponseDTO: Codable {
    let items: [MyTeamResponseDTO]
    let next: String?
    let total: Int
    
    var toDomain: [MyTeamItemModel] {
        items.map {
            MyTeamItemModel(
                id: $0.id,
                teamIntroduce: $0.teamIntroduce,
                memberCount: $0.memberCount,
                location: $0.location,
                memberInfos: $0.memberInfos.map { $0.toDomain }
            )
        }
    }
}

struct MyTeamResponseDTO: Codable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let location: String
    let memberInfos: [MyTeamMemberResponseDTO]
}

struct MyTeamMemberResponseDTO: Codable {
    let id: String
    let universityName: String
    let mbti: String
    let birthYear: Int
    let role: String
    let isMe: Bool
    
    var toDomain: MyTeamMemberModel {
        MyTeamMemberModel(
            id: id,
            universityName: universityName,
            mbti: mbti,
            birthYear: birthYear,
            role: role,
            isMe: isMe
        )
    }
}

struct MyTeamListRequestDTO: Encodable {
    let next: String?
    let limit: Int
}

extension APIEndpoints {
    static func getMyTeamList(nextId: String? = nil) -> EndPoint<MyTeamListResponseDTO> {
        let request = MyTeamListRequestDTO(next: nextId, limit: 10)
        return EndPoint(
            path: "api/meeting-teams/my",
            method: .get,
            queryParameters: request,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
