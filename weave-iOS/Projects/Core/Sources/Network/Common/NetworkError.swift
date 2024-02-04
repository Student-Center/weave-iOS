//
//  NetworkError.swift
//  Core
//
//  Created by 강동영 on 1/19/24.
//

import Foundation

enum NetworkError: Error {
    case unknownError
    case invalidHttpStatusCode(Int)
    case components
    case urlRequest(Error)
    case parsing(Error)
    case emptyData
    case decodeError
    
    var localizedDescription: String {
        switch self {
        case .unknownError:
            return "알 수 없는 에러"
        case .invalidHttpStatusCode:
            return "status코드가 200~299가 아닙니다."
        case .components:
            return "components를 생성 에러가 발생했습니다."
        case .urlRequest:
            return "URL Request 관련 에러가 발생했습니다."
        case .parsing:
            return "데이터 parsing 중에 에러가 발생했습니다."
        case .emptyData:
            return "data가 비었습니다."
        case .decodeError:
            return "decode 에러가 발생하였습니다."
        }
    }
}
