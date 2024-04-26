//
//  MeetingTeamFilterModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/3/24.
//

import Foundation

struct MeetingTeamFilterModel: Equatable {
    var memberCount: Int?
    var youngestMemberBirthYear: Int
    var oldestMemberBirthYear: Int
    var preferredLocations: [String]?
    
    init(
        memberCount: Int? = nil,
        youngestMemberBirthYear: Int = 2006,
        oldestMemberBirthYear: Int = 1996,
        preferredLocations: [String]? = nil
    ) {
        self.memberCount = memberCount
        self.youngestMemberBirthYear = youngestMemberBirthYear
        self.oldestMemberBirthYear = oldestMemberBirthYear
        self.preferredLocations = preferredLocations
    }
}
