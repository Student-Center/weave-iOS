//
//  MyUserInfoModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/16/24.
//

import Foundation

struct MyUserInfoModel: Equatable {
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
    
    var birthYearShortText: String {
        let yearString = String(birthYear)
        
        // 연도 문자 길이 4자리 Validation
        guard yearString.count == 4 else {
            return "잘못된 연도 정보"
        }
        
        return String(yearString.suffix(2)) + "년생"
    }
}
