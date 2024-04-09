//
//  Provider.swift
//  Core
//
//  Created by 강동영 on 1/19/24.
//

import Foundation

struct DummyAPI: Decodable {
    let name: String
}

public class APIProvider {
    static private(set) var serverType: ServerType = {
        if let appEnviroment = Bundle.main.infoDictionary?["App Enviroment"] as? String {
            switch appEnviroment {
            case "dev":
                return .develop
            case "prod":
                return .release
            default:
                break
            }
        }
        assert(false, "App Enviroment가 설정되지 않았습니다")
        return .release
    }()
    
    let session: URLSession
    public init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    public func request<R: Decodable, E: RequestResponsable>(with endPoint: E, showErrorAlert: Bool = true, completion: @escaping (Result<R, Error>) -> Void) where E.Response == R {
        
        do {
            let request = try endPoint.getUrlRequest()
            
            let task: URLSessionTask = session
                .dataTask(with: request) { data, urlResponse, error in
                    guard let response = urlResponse as? HTTPURLResponse,
                          (200...399).contains(response.statusCode) else {
                        completion(.failure(error as? NetworkError ?? NetworkError.unknownError))
                        return
                    }
                    
                    guard let data = data else {
                        completion(.failure(NetworkError.emptyData))
                        return
                    }
                    
                    guard let response = try? JSONDecoder().decode(R.self, from: data) else {
                        completion(.failure(NetworkError.decodeError))
                        Task {
                            try await ServiceErrorManager.shared.handleErrorResponse(
                                data: data,
                                response: response,
                                needShowAlert: showErrorAlert
                            )
                        }
                        return
                    }
                    
                    completion(.success(response))
                }
            
            task.resume()
            
        } catch {
            completion(.failure(NetworkError.urlRequest(error)))
        }
    }
    
    public func request<R: Decodable, E: RequestResponsable>(with endPoint: E, showErrorAlert: Bool = true, retry: RetryHandler? = nil) async throws -> R where E.Response == R {
        var endPointObject = endPoint
        
        if let retry {
            guard retry.count < 5 else { throw NetworkError.unknownError }
            if let newToken = retry.newToken {
                endPointObject.headers?["Authorization"] = "Bearer \(newToken)"
            }
        }
            
        let urlRequest = try endPointObject.getUrlRequest()
        let (data, urlResponse) = try await session.data(for: urlRequest)
        endPointObject.responseLogger(response: urlResponse, data: data)
        
        if let response = urlResponse as? HTTPURLResponse,
           (200...399).contains(response.statusCode) {
            // 200 - 399 에 포함
            let decodedResponse = try JSONDecoder().decode(R.self, from: data)
            return decodedResponse
        } else {
            // 400 이상
            let newToken = try await ServiceErrorManager.shared.handleErrorResponse(
                data: data,
                response: urlResponse,
                needShowAlert: showErrorAlert
            )
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            return try await request(
                with: endPoint,
                showErrorAlert: showErrorAlert,
                retry: .init(count: ((retry?.count ?? 0) + 1), newToken: newToken)
            )
        }
    }
    
    public func requestWithNoResponse<E: RequestResponsable>(with endPoint: E, successCode: Int = 204, showErrorAlert: Bool = true, retry: RetryHandler? = nil) async throws {
        var endPointObject = endPoint
        
        if let retry {
            guard retry.count < 5 else { throw NetworkError.unknownError }
            if let newToken = retry.newToken {
                endPointObject.headers?["Authorization"] = "Bearer \(newToken)"
            }
        }
        
        let urlRequest = try endPoint.getUrlRequest()
        
        let (data, urlResponse) = try await session.data(for: urlRequest)
        endPoint.responseLogger(response: urlResponse, data: data)
        guard let response = urlResponse as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        if response.statusCode == successCode {
            return
        } else {
            // 400 이상
            let newToken = try await ServiceErrorManager.shared.handleErrorResponse(
                data: data,
                response: urlResponse,
                needShowAlert: showErrorAlert
            )
            
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            return try await requestWithNoResponse(
                with: endPoint,
                successCode: successCode,
                showErrorAlert: showErrorAlert,
                retry: .init(count: ((retry?.count ?? 0) + 1), newToken: newToken)
            )
        }
    }
}

extension APIProvider {
    public func requestSNSLogin<R: Decodable, E: RequestResponsable>(with endPoint: E, showErrorAlert: Bool = true) async throws -> R where E.Response == R {
        let urlRequest = try endPoint.getUrlRequest()
        let (data, urlResponse) = try await session.data(for: urlRequest)
        endPoint.responseLogger(response: urlResponse, data: data)
        guard let response = urlResponse as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        guard response.statusCode == 200 else {
            if response.statusCode == 401 {
                let decodedResponse = try JSONDecoder().decode(SignUpRegisterTokenResponse.self, from: data)
                throw LoginNetworkError.needRegist(registerToken: decodedResponse)
            }
            _ = try await ServiceErrorManager.shared.handleErrorResponse(
                data: data,
                response: urlResponse,
                needShowAlert: showErrorAlert
            )
            throw NetworkError.unknownError
        }
        
        let decodedResponse = try JSONDecoder().decode(R.self, from: data)
        return decodedResponse
    }
}

extension APIProvider {
    public func requestUploadData<E: RequestResponsable>(with endPoint: E, data: Data, showErrorAlert: Bool = true) async throws {
        let urlRequest = try endPoint.getUrlRequest()
        let (data, urlResponse) = try await session.upload(for: urlRequest, from: data)
        endPoint.responseLogger(response: urlResponse, data: data)
        guard let response = urlResponse as? HTTPURLResponse,
              (200...399).contains(response.statusCode) else {
            _ = try await ServiceErrorManager.shared.handleErrorResponse(
                data: data,
                response: urlResponse,
                needShowAlert: showErrorAlert
            )
            throw NetworkError.unknownError
        }
        guard 200 <= response.statusCode && response.statusCode <= 299 else {
            throw NetworkError.invalidHttpStatusCode(response.statusCode)
        }
        return
    }
}

public enum LoginNetworkError: Error {
    case needRegist(registerToken: SignUpRegisterTokenResponse)
}

public struct SignUpRegisterTokenResponse: Decodable {
    public let registerToken: String
}

public enum ImageUploadError: Error {
    case convertImageToDataError
}
