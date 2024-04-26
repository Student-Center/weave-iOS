//
//  UniversityResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/10/24.
//

import Foundation
import Services

struct UniversitiesResponseDTO: Decodable {
    let universities: [UniversityResponseDTO]
}

struct UniversityResponseDTO: Decodable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let domainAddress: String
    let logoAddress: String?
    
    var toDomain: UniversityModel {
        return UniversityModel(
            id: id,
            name: name,
            displayName: displayName,
            domainAddress: domainAddress,
            logoAddress: logoAddress,
            iconAssetName: "Univ"
        )
    }
}

extension APIEndpoints {
    static func getUniversityInfo() -> EndPoint<UniversitiesResponseDTO> {
        return EndPoint(
            path: "api/univ",
            method: .get
        )
    }
}
