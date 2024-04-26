//
//  MeetingRoomListModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/29/24.
//

import Foundation
import DesignSystem
import CoreKit

struct MeetingTeamListModel: Equatable {
    let items: [MeetingTeamModel]
    let next: String?
    let total: Int
}

// MARK: - Item
struct MeetingTeamModel: Equatable, Hashable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let gender: String?
    let location: String
    var memberInfos: [MeetingMemberModel]
}

// MARK: - MemberInfo
struct MeetingMemberModel: Equatable, Hashable {
    let id: String
    let UserId: String?
    let universityName: String
    let majorName: String?
    let mbti: String
    let birthYear: Int
    let animalType: String?
    let height: Int?
    let isUnivVerified: Bool?
    let avatar: String?
    var kakaoId: String?
    
    var mbtiType: MBTIType? {
        return MBTIType(rawValue: mbti.uppercased())
    }
    
    var userInfoString: String {
        // ToDo - 알맞게 패턴 처리
        return "\(universityName.toShortUnivName())・\(birthYear.toShortBirthYear())\n\(mbti)"
    }
}
