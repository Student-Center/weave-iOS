//
//  MeetingLocationFilterTypes.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/3/24.
//

import DesignSystem
import Foundation

enum MeetingLocationFilterType: String, CaseIterable, LeftAlignListFetchable {
    case capital
    case nonCapital
    
    var id: String {
        return self.rawValue
    }
    
    var text: String {
        switch self {
        case .capital: return "수도권"
        case .nonCapital: return "비수도권"
        }
    }
}

enum MeetingMemberCountType: Int, CaseIterable, LeftAlignListFetchable {
    case two = 2
    case three = 3
    case four = 4
    
    var id: String {
        return String(self.rawValue)
    }
    
    var countValue: Int {
        return self.rawValue
    }
    
    var text: String {
        return "\(countValue) : \(countValue)"
    }
}
