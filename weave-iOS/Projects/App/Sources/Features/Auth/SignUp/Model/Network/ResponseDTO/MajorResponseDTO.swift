//
//  MajorResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/10/24.
//

import Foundation
import Services

public struct MajorsResponseDTO: Decodable {
    public let majors: [MajorResponseDTO]
}

public struct MajorResponseDTO: Decodable, Equatable {
    public let id: String
    public let name: String
    
    var toDomain: MajorModel {
        return MajorModel(
            id: id,
            name: name,
            iconAssetName: "major"
        )
    }
}

extension APIEndpoints {
    static func getMajorInfo(univId: String) -> EndPoint<MajorsResponseDTO> {
        return EndPoint(
            path: "api/univ/\(univId)/majors",
            method: .get
        )
    }
}
