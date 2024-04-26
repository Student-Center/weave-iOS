//
//  MyAnimalRequestDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/26/24.
//

import Foundation
import Services
import CoreKit

struct MyAnimalEditRequestDTO: Encodable {
    let animalType: String
}

extension APIEndpoints {
    static func editMyAnimal(body: MyAnimalEditRequestDTO) -> EndPoint<EmptyResponse> {
        return EndPoint(
            path: "api/users/my/animal-type",
            method: .patch,
            bodyParameters: body,
            headers: ["Authorization": "Bearer \(UDManager.accessToken)"]
        )
    }
}
