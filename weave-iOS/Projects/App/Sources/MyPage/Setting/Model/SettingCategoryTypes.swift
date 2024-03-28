//
//  SettingCategoryTypes.swift
//  weave-ios
//
//  Created by 강동영 on 3/12/24.
//

import Foundation

enum SettingCategoryTypes: CaseIterable {
    case policies
    case account
    
    var headerTitle: String {
        switch self {
        case .policies:
            return "약관 및 정책"
        case .account:
            return "계정"
        }
    }
    
    var getSubViewTypes: [SettingSubViewTypes] {
        switch self {
        case .policies:
            return [
                .termsAndConditions,
                .privacyPolicy
            ]
        case .account:
            return [
                .logout,
                .unregister
            ]
        }
    }
    
    enum SettingSubViewTypes: String {
        case termsAndConditions
        case privacyPolicy
        case logout
        case unregister
        
        var title: String {
            switch self {
            case .termsAndConditions: return "약관 및 이용 동의"
            case .privacyPolicy: return "개인정보처리방침"
            case .logout: return "로그아웃"
            case .unregister: return "회원 탈퇴"
            }
        }
        
        var url: URL? {
            switch self {
            case .termsAndConditions:
                guard let url = URL(string: "https://weave-org.notion.site/WEAVE-a0fa6c2774a94043b9575b4db3a8ea15") else { return nil }
                return url
            case .privacyPolicy:
                guard let url = URL(string: "https://weave-org.notion.site/WEAVE-a65c3e3a483e4ec1bcc94353b21f771b") else { return nil }
                return url
            case .logout, .unregister: return nil
            }
        }
    }
}
