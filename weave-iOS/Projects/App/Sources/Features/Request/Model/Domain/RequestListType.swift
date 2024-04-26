//
//  RequestListType.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/15/24.
//

import Foundation

enum RequestListType: Int {
    case requesting = 1
    case receiving = 0
    
    var requestValue: String {
        switch self {
        case .requesting: return "REQUESTING"
        case .receiving: return "RECEIVING"
        }
    }
    
    var timeDiffSuffixValue: String {
        switch self {
        case .requesting: return "뒤에 사라져요!"
        case .receiving: return "뒤에 취소돼요!"
        }
    }
}
