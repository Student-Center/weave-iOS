//
//  RequestMeetingListResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/15/24.
//

import Foundation
import Services
import DesignSystem
import CoreKit

struct RequestMeetingListResponseDTO: Codable {
    let items: [RequestMeetingItemResponseDTO]
    let next: String?
    let total: Int?
    
    var toDomain: RequestMeetingListModel {
        return RequestMeetingListModel(
            items: items.map { $0.toDomain },
            next: next,
            total: total
        )
    }
}

struct RequestMeetingItemResponseDTO: Codable {
    let id: String
    let requestingTeam: RequestMeetingTeamInfoResponseDTO
    let receivingTeam: RequestMeetingTeamInfoResponseDTO
    let teamType: String
    let status: String
    let createdAt: String
    let pendingEndAt: String
    
    var toDomain: RequestMeetingItemModel {
        RequestMeetingItemModel(
            id: id,
            requestingTeam: requestingTeam.toDomain,
            receivingTeam: receivingTeam.toDomain,
            teamType: teamType,
            status: status,
            createdAt: createdAt,
            pendingEndAt: pendingEndAt
        )
    }
}

struct RequestMeetingTeamInfoResponseDTO: Codable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let gender: String
    let memberInfos: [RequestMeetingMemberInfoResponseDTO]
    
    var toDomain: RequestMeetingTeamInfoModel {
        return RequestMeetingTeamInfoModel(
            id: id,
            teamIntroduce: teamIntroduce,
            memberCount: memberCount,
            gender: gender,
            memberInfos: memberInfos.map { $0.toDomain }
        )
    }
}

struct RequestMeetingMemberInfoResponseDTO: Codable {
    let id: String
    let userId: String
    let universityName: String
    let mbti: String
    let birthYear: Int
    let animalType: String?
    
    var toDomain: RequestMeetingMemberInfoModel {
        return RequestMeetingMemberInfoModel(
            id: id,
            userId: userId,
            universityName: universityName,
            mbti: mbti,
            birthYear: birthYear,
            animalType: animalType
        )
    }
}

struct RequestMeetingListRequestDTO: Codable {
    let teamType: String
    let next: String?
    let limit: Int
    
    init(
        teamType: RequestListType,
        next: String? = nil,
        limit: Int = 10
    ) {
        self.teamType = teamType.requestValue
        self.next = next
        self.limit = limit
    }
}

//MARK: - Domain
struct RequestMeetingListModel: Equatable {
    let items: [RequestMeetingItemModel]
    let next: String?
    let total: Int?
}

struct RequestMeetingItemModel: Equatable {
    static func == (lhs: RequestMeetingItemModel, rhs: RequestMeetingItemModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let requestingTeam: RequestMeetingTeamInfoModel
    let receivingTeam: RequestMeetingTeamInfoModel
    let teamType: String
    let status: String
    let createdAt: String
    let pendingEndAt: String
    
    func getTimeDiffString(suffix: String) -> String {
        guard let timeLeftString = getTimeDiffValueFromNow(to: pendingEndAt) else {
            return "시간이 초과되었어요!"
        }
        return "\(timeLeftString) \(suffix)"
    }
    
    func getTimeDiffValueFromNow(to targetTimeString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")

        guard let targetTime = dateFormatter.date(from: targetTimeString) else {
            return "잘못된 날짜"
        }
        
        let currentTime = Date()
        let differenceInSeconds = Calendar.current.dateComponents([.second], from: currentTime, to: targetTime).second ?? 0
        
        if differenceInSeconds < 0 {
            return nil
        } else {
            let futureMinutes = differenceInSeconds / 60
            let futureHours = differenceInSeconds / 3600
            
            if futureHours > 0 {
                return "\(futureHours)시간"
            } else {
                return "\(futureMinutes)분"
            }
        }
    }
}

struct RequestMeetingTeamInfoModel: Equatable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let gender: String
    var memberInfos: [RequestMeetingMemberInfoModel]
}

struct RequestMeetingMemberInfoModel: Equatable {
    let id: String
    let userId: String
    let universityName: String
    let mbti: String
    let birthYear: Int
    let animalType: String?
    var isAttendance: Bool?
    var kakaoId: String?
    
    init(id: String, userId: String, universityName: String, mbti: String, birthYear: Int, animalType: String?, isAttendance: Bool? = nil, kakoId: String? = nil) {
        self.id = id
        self.userId = userId
        self.universityName = universityName
        self.mbti = mbti
        self.birthYear = birthYear
        self.animalType = animalType
        self.isAttendance = isAttendance
//        self.kakaoId = kakaoId
    }
    
    var memberInfoValue: String {
        return "\(universityName)•\(birthYear.toShortBirthYear())"
    }
}

extension APIEndpoints {
    static func getRequestMeetingTeamList(
        request: RequestMeetingListRequestDTO,
        nextId: String? = nil
    ) -> EndPoint<RequestMeetingListResponseDTO> {
        return EndPoint(
            path: "api/meetings/status/pending",
            method: .get,
            queryParameters: request,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
