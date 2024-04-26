//
//  AnimalsDomainModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/25/24.
//

import Foundation
import DesignSystem

struct AnimalModel: LeftAlignListFetchable {
    let name: String
    let description: String
    
    var id: String {
        return name
    }
    var text: String {
        return description
    }
}
