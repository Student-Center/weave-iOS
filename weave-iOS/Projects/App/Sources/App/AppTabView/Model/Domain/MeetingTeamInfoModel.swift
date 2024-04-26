//
//  MeetingTeamInfoModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/26/24.
//

import Foundation

struct MeetingTeamInfoModel: Equatable {
    let teamId: String
    let teamIntroduce: String
    let status: String
    var invitationCode: String?
}
