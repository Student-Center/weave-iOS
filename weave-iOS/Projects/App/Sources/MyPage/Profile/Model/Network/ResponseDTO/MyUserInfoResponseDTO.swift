//
//  MyUserInfoResponseDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/16/24.
//

import Foundation
import Services
import CoreKit

struct MyUserInfoResponseDTO: Decodable {
    let id: String
    let nickname: String
    let birthYear: Int
    let universityName: String
    let majorName: String
    let avatar: String?
    let mbti: String
    let animalType: String?
    let height: Int?
    let kakaoId: String?
    let isUniversityEmailVerified: Bool
    let sil: Int
    
    var toDomain: MyUserInfoModel {
        return MyUserInfoModel(
            id: id,
            nickname: nickname,
            birthYear: birthYear,
            universityName: universityName,
            majorName: majorName,
            avatar: avatar,
            mbti: mbti,
            animalType: animalType,
            height: height,
            kakaoId: kakaoId,
            isUniversityEmailVerified: isUniversityEmailVerified,
            sil: `sil`
        )
    }
}

extension APIEndpoints {
    static func getMyUserInfo() -> EndPoint<MyUserInfoResponseDTO> {
        return EndPoint(
            path: "api/users/my",
            method: .get,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
