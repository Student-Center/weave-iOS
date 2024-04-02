//
//  MyTeamDeleteRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/8/24.
//

import Foundation
import Services
import CoreKit

extension APIEndpoints {
    static func deleteMyTeam(teamId: String) -> EndPoint<MyTeamListResponseDTO> {
        return EndPoint(
            path: "api/meeting-teams/\(teamId)",
            method: .delete,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
