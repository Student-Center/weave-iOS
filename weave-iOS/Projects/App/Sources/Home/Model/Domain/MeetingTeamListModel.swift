//
//  MeetingRoomListModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/29/24.
//

import Foundation

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
    let gender: String
    let memberInfos: [MeetingMemberModel]
}

// MARK: - MemberInfo
struct MeetingMemberModel: Equatable, Hashable {
    let id: String
    let userId: String
    let universityName: String
    let mbti: String
    let birthYear: Int
    let animalType: String?
    
    var userInfoString: String {
        // ToDo - 알맞게 패턴 처리
//        return "\(universityName)・\(birthYear)\n\(mbti)"
        return "위브대・05\nENTP"
    }
}