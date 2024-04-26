//
//  MeetingRocationModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/3/24.
//

import Foundation
import DesignSystem

struct MeetingLocationModel: Equatable {
    let name: String
    let displayName: String
    let isCapitalArea: Bool
}

extension MeetingLocationModel: LeftAlignListFetchable {
    var id: String {
        return self.name
    }
    
    var text: String {
        return self.displayName
    }
}
