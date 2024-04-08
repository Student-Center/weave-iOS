//
//  ServiceErrorManager.swift
//  Services
//
//  Created by Jisu Kim on 3/29/24.
//

import Foundation
import CoreKit

struct ErrorResponseDTO: Decodable {
    let message: String
    let timeStamp: String
    let exceptionCode: String
}

@Observable 
public class ServiceErrorManager {
    public static var shared = ServiceErrorManager()
    private init() {}
    
    public var needShowErrorAlert: Bool = false
    public private(set) var errorMessage = "에러입니다"
    
    func handleErrorResponse(data: Data, response: URLResponse, needShowAlert: Bool) async throws -> String? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return nil
        }

        let statusCode = httpResponse.statusCode
        if statusCode >= 400 && statusCode < 500 {
            let decoder = JSONDecoder()
            guard let errorResponse = try? decoder.decode(ErrorResponseDTO.self, from: data) else { return nil }
            // 토큰 만료인 경우 - 토큰 재발급 시도
            if errorResponse.exceptionCode == CommonKey.tokenExpireCode {
                // 리프레시 토큰이 없는 경우 - 로그인 페이지로 이동
                guard UDManager.refreshToken != "" else {
                    AuthStateManager.changeState(to: .forceToLogin)
                    throw NetworkError.unknownError
                }
                // 토큰 재발급 성공한 경우 - 엑세스 토큰을 리턴
                let endpoint = APIEndpoints.getRefreshToken(UDManager.refreshToken)
                let provider = APIProvider()
                let response = try await provider.request(with: endpoint)
                // 기기에 저장
                UDManager.accessToken = response.accessToken
                UDManager.refreshToken = response.refreshToken
                return response.accessToken
            }
            
            // 토큰 정보 없는 경우 - 로그인 페이지로 이동
            if errorResponse.exceptionCode == CommonKey.tokenUnavailableCode {
                AuthStateManager.changeState(to: .forceToLogin)
                throw NetworkError.unknownError
            }
            
            // Alert 을 보여줘야 하는 경우
            if needShowAlert {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.needShowErrorAlert = true
                    self.errorMessage = errorResponse.message
                }
            }
        }
        // 그대로 진행된다면 에러 리턴
        throw NetworkError.unknownError
    }
    
    public func handleAlertConfirmAction() {
        errorMessage = ""
    }
}

private struct AuthRefreshRequestDTO: Encodable {
    let refreshToken: String
}

extension APIEndpoints {
    static func getRefreshToken(_ refreshToken: String) -> EndPoint<SNSLoginResponseDTO> {
        let dto = AuthRefreshRequestDTO(refreshToken: refreshToken)
        return EndPoint(
            path: "api/auth/refresh",
            method: .post,
            bodyParameters: dto
        )
    }
}


public struct SNSLoginResponseDTO: Decodable {
    public let accessToken: String
    public let refreshToken: String
}

enum ErrorManagerResponseType {
    case needRetry
}

public enum AuthStateManager {
    public static var stateHandler: ((AuthStateType) -> Void)?
    
    public static func changeState(to state: AuthStateType) {
        stateHandler?(state)
    }
}

public enum AuthStateType {
    case normal
    case forceToLogin
}

public struct RetryHandler {
    let count: Int
    let newToken: String?
    
    init(count: Int, newToken: String? = nil) {
        self.count = count
        self.newToken = newToken
    }
}
