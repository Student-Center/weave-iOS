//
//  AttendanceStatusResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/17/24.
//

import Foundation
import Services
import CoreKit

struct MeetingAttendanceResponseDTO: Decodable {
    let meetingAttendances: [AttendanceStatusResponseDTO]
}

struct AttendanceStatusResponseDTO: Decodable {
    let memberId: String
    let attendance: Bool
}

extension APIEndpoints {
    static func getAttendanceStatus(teamId: String) -> EndPoint<MeetingAttendanceResponseDTO> {
        return EndPoint(
            path: "api/meetings/\(teamId)/attendance",
            method: .get,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
