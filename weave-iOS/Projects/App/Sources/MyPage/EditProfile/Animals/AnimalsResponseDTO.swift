//
//  AnimalsResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/25/24.
//

import Foundation
import Services
import CoreKit

struct AnimalsResponseDTO: Decodable {
    let items: [AnimalResponseDTO]
    
    var toDomain: [AnimalModel] {
        return items.map { $0.toDomain }
    }
}

struct AnimalResponseDTO: Decodable {
    let name: String
    let description: String
    
    var toDomain: AnimalModel {
        return AnimalModel(name: name, description: description)
    }
}

extension APIEndpoints {
    static func getAllAvailableAnimal() -> EndPoint<AnimalsResponseDTO> {
        return EndPoint(
            path: "api/users/animal-types",
            method: .get,
            headers: ["Authorization": "Bearer \(UDManager.accessToken)"]
        )
    }
}
