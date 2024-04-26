//
//  UniversityModel.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/9/24.
//

import Foundation
import DesignSystem
import Services

struct UniversityModel: WeaveDropDownFetchable, Equatable {
    let id: String
    let name: String
    let displayName: String
    let domainAddress: String
    let logoAddress: String?
    let iconAssetName: String?
}
