//
//  ServerType.swift
//  Core
//
//  Created by 강동영 on 1/19/24.
//

import Foundation
import CoreKit

enum ServerType: String {
    case dev // db 개발, api 개발
    case prod // db 상용, api 상용
    
    var baseURL: String {
        switch self {
        case .dev:
            return SecretKey.developURL
        case .prod:
            return SecretKey.releaseURL
        }
    }
}
