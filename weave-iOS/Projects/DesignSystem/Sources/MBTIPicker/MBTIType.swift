//
//  MBTIType.swift
//  DesignSystem
//
//  Created by Jisu Kim on 3/2/24.
//

import Foundation
import CoreKit

public enum MBTIType: String {
    case INFP
    case ISTJ
    case ISFJ
    case INFJ
    case INTJ
    case ISTP
    case ISFP
    case INTP
    case ESTP
    case ESFP
    case ENFP
    case ENTP
    case ESTJ
    case ESFJ
    case ENFJ
    case ENTJ
    
    private var emoji: String {
        switch self {
        case .INFP: return "🫠"
        case .ISTJ: return "🤓"
        case .ISFJ: return "😉"
        case .INFJ: return "🫣"
        case .INTJ: return "🧐"
        case .ISTP: return "😒"
        case .ISFP: return "😃"
        case .INTP: return "🤔"
        case .ESTP: return "🤭"
        case .ESFP: return "🥳"
        case .ENFP: return "🤠"
        case .ENTP: return "😎"
        case .ESTJ: return "🫡"
        case .ESFJ: return "🤗"
        case .ENFJ: return "🥰"
        case .ENTJ: return "😤"
        }
    }
    
    private var feature: String {
        switch self {
        case .INFP: return "몽상가형"
        case .ISTJ: return "꼼꼼한"
        case .ISFJ: return "살림 만렙"
        case .INFJ: return "생각이 많은"
        case .INTJ: return "지적인"
        case .ISTP: return "맥가이버형"
        case .ISFP: return "평화주의자"
        case .INTP: return "호기심 많은"
        case .ESTP: return "다재다능한"
        case .ESFP: return "분위기 메이커"
        case .ENFP: return "자유로운 영혼"
        case .ENTP: return "자아도취형"
        case .ESTJ: return "행동대장"
        case .ESFJ: return "계모임 총무형"
        case .ENFJ: return "사람 좋아"
        case .ENTJ: return "열정 만수르"
        }
    }
    
    public var description: String {
        return "\(emoji) \(self.rawValue)•\(feature)"
    }
}

extension MBTIType {
    public var mbtiProfileImage: String {
        return "\(SecretKey.serverResourcePath)/mbti_profile_image/list/\(self.rawValue).png"
    }
}
