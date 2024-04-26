//
//  MatchedMeetingTeamList.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/21/24.
//

import Foundation
import CoreKit

struct MatchedMeetingTeamList: Equatable {
    let items: [MatchedMeetingTeamInfo]
    let next: String?
    let total: Int?
}

struct MatchedMeetingTeamInfo: Equatable {
    let id: String
    let memberCount: Int
    let otherTeam: MeetingTeamModel
    let status: String
    let createdAt: String
}
