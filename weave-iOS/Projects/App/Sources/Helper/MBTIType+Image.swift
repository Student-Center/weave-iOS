//
//  MBTI+Image.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/23/24.
//

import Foundation
import DesignSystem
import CoreKit

extension MBTIType {
    public var mbtiProfileImage: String {
        return "\(SecretKey.serverResourcePath)/mbti_profile_image/list/\(self.rawValue).png"
    }
}
