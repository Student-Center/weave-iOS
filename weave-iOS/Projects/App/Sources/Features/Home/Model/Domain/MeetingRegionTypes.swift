//
//  MeetingRegionTypes.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/1/24.
//

import Foundation

enum MeetingRegionTypes {
    case 수도권
    case 비수도권
    case 건대성수
    case 홍대신촌
    case 강남잠실
    case 노원공릉
    case 대학로회화
    case 인천
    case 수원
    case 용인
    case 시흥
    case 부천
    
    var title: String {
        switch self {
        case .수도권: return "수도권"
        case .비수도권: return "비수도권"
        case .건대성수: return "건대•성수"
        case .홍대신촌: return "홍대•신촌"
        case .강남잠실: return "강남•잠실"
        case .노원공릉: return "노원•공릉"
        case .대학로회화: return "대학로•회화"
        case .인천: return "인천"
        case .수원: return "수원"
        case .용인: return "용인"
        case .시흥: return "시흥"
        case .부천: return "부천"
        }
    }
    
    var requestValue: String {
        // ToDo - 명세 필요
        return ""
    }
}
