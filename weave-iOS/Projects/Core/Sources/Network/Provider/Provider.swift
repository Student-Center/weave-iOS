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
    static private(set) var serverType: ServerType = .develop
    
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
                        ServiceErrorManager.shared.handleErrorResponse(
                            data: data,
                            response: response,
                            needShowAlert: showErrorAlert
                        )
                        return
                    }
                    
                    completion(.success(response))
                }
            
            task.resume()
            
        } catch {
            completion(.failure(NetworkError.urlRequest(error)))
        }
    }
    
    public func request<R: Decodable, E: RequestResponsable>(with endPoint: E, showErrorAlert: Bool = true) async throws -> R where E.Response == R {
        do {
            let urlRequest = try endPoint.getUrlRequest()
            let (data, urlResponse) = try await session.data(for: urlRequest)
            endPoint.responseLogger(response: urlResponse, data: data)
            guard let response = urlResponse as? HTTPURLResponse,
                  (200...399).contains(response.statusCode) else {
                ServiceErrorManager.shared.handleErrorResponse(
                    data: data,
                    response: urlResponse,
                    needShowAlert: showErrorAlert
                )
                throw NetworkError.unknownError // 또는 적절한 오류 처리
            }

            let decodedResponse = try JSONDecoder().decode(R.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.urlRequest(error)
        }
    }
    
    public func requestWithNoResponse<E: RequestResponsable>(with endPoint: E, successCode: Int = 204, showErrorAlert: Bool = true) async throws {
        do {
            let urlRequest = try endPoint.getUrlRequest()
            
            let (data, urlResponse) = try await session.data(for: urlRequest)
            endPoint.responseLogger(response: urlResponse, data: data)
            guard let response = urlResponse as? HTTPURLResponse else {
                throw NetworkError.unknownError
            }
            
            if response.statusCode == successCode {
                return
            } else {
                ServiceErrorManager.shared.handleErrorResponse(
                    data: data,
                    response: urlResponse,
                    needShowAlert: showErrorAlert
                )
                throw NetworkError.invalidHttpStatusCode(response.statusCode)
            }
        } catch {
            throw NetworkError.urlRequest(error)
        }
    }
}

extension APIProvider {
    public func requestSNSLogin<R: Decodable, E: RequestResponsable>(with endPoint: E, showErrorAlert: Bool = true) async throws -> R where E.Response == R {
        do {
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
                ServiceErrorManager.shared.handleErrorResponse(
                    data: data,
                    response: urlResponse,
                    needShowAlert: showErrorAlert
                )
                throw NetworkError.unknownError
            }

            let decodedResponse = try JSONDecoder().decode(R.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.urlRequest(error)
        }
    }
}

extension APIProvider {
    public func requestUploadData<E: RequestResponsable>(with endPoint: E, data: Data, showErrorAlert: Bool = true) async throws {
        do {
            let urlRequest = try endPoint.getUrlRequest()
            let (data, urlResponse) = try await session.upload(for: urlRequest, from: data)
            endPoint.responseLogger(response: urlResponse, data: data)
            guard let response = urlResponse as? HTTPURLResponse,
                  (200...399).contains(response.statusCode) else {
                ServiceErrorManager.shared.handleErrorResponse(
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
        } catch {
            throw error
        }
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
