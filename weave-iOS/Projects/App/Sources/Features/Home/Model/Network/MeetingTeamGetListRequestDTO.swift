//
//  MeetingTeamRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/29/24.
//

import Foundation

struct MeetingTeamGetListRequestDTO: Codable {
    let memberCount: Int?
    let youngestMemberBirthYear: Int
    let oldestMemberBirthYear: Int
    let preferredLocations: [String]?
    let next: String?
    let limit: Int
    
    init(
        memberCount: Int? = nil,
        youngestMemberBirthYear: Int = 2006,
        oldestMemberBirthYear: Int = 1996,
        preferredLocations: [String]? = nil,
        next: String?,
        limit: Int = 10
    ) {
        self.memberCount = memberCount
        self.youngestMemberBirthYear = youngestMemberBirthYear
        self.oldestMemberBirthYear = oldestMemberBirthYear
        self.preferredLocations = preferredLocations
        self.next = next
        self.limit = limit
    }
}
