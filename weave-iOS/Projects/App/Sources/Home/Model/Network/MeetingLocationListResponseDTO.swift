//
//  MeetingLocationListResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/3/24.
//

import Foundation
import Services
import CoreKit

struct MeetingLocationListResponseDTO: Decodable {
    let locations: [MeetingLocationDTO]
    
    var toDomain: [MeetingLocationModel] {
        return locations.map {
            MeetingLocationModel(
                name: $0.name,
                displayName: $0.displayName,
                isCapitalArea: $0.isCapitalArea
            )
        }
    }
}

struct MeetingLocationDTO: Decodable {
    let name: String
    let displayName: String
    let isCapitalArea: Bool
}

extension APIEndpoints {
    static func getMeetingLocationList() -> EndPoint<MeetingLocationListResponseDTO> {
        return EndPoint(
            path: "api/meeting-teams/locations",
            method: .get,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
