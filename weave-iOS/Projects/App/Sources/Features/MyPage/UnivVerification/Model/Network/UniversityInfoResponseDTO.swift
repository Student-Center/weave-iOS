//
//  UnversityInfoResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/19/24.
//

import Foundation
import Services
import CoreKit

struct UniversityInfoResponseDTO: Decodable {
    let id: String
    let name: String
    let domainAddress: String
    let logoAddress: String?
    
    var toDomain: UniversityInfoModel {
        UniversityInfoModel(
            id: id,
            name: name,
            domainAddress: domainAddress,
            logoAddress: logoAddress)
    }
}

extension APIEndpoints {
    static func getSingleUniversityInfo(univName: String) -> EndPoint<UniversityInfoResponseDTO> {
        return EndPoint(
            path: "api/univ/name/\(univName)",
            method: .get,
            headers: ["Authorization": "Bearer \(UDManager.accessToken)"]
        )
    }
}
