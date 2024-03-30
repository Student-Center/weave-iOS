//
//  ServiceErrorManager.swift
//  Services
//
//  Created by Jisu Kim on 3/29/24.
//

import Foundation

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
    
    internal func handleErrorResponse(data: Data, response: URLResponse, needShowAlert: Bool) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }

        let statusCode = httpResponse.statusCode
        if statusCode >= 400 && statusCode < 500 {
            do {
                let decoder = JSONDecoder()
                guard let errorResponse = try? decoder.decode(ErrorResponseDTO.self, from: data) else { return }
                
                // Alert 을 보여줘야 하는 경우
                if needShowAlert {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.needShowErrorAlert = true
                        self.errorMessage = errorResponse.message
                    }
                }
            }
        }
    }
    
    public func handleAlertConfirmAction() {
        errorMessage = ""
    }
}
