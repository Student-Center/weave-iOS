//
//  MeetingTeamDetailModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/2/24.
//

import Foundation
import DesignSystem

struct MeetingTeamDetailModel: Equatable {
    let id: String
    let teamIntroduce: String
    let memberCount: Int
    let location: String
    let gender: String
    let members: [MeetingTeamDetailMemberModel]
    let status: String
    let affinityScore: Int?
}

struct MeetingTeamDetailMemberModel: Equatable {
    let userId: String
    let universityName: String
    let majorName: String
    let mbti: MBTIType?
    let birthYear: Int
    let role: String
    let animalType: String?
    let height: Int?
    let isUnivVerified: Bool
}
