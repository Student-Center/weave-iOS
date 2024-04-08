//
//  Requestable.swift
//  Core
//
//  Created by 강동영 on 1/19/24.
//

import Foundation

public protocol Requestable {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: Encodable? { get }
    var bodyParameters: Encodable? { get }
    var headers: [String: String]? { get set }
}

extension Requestable {
    func getUrlRequest() throws -> URLRequest {
        let url = try url()
        var urlRequest: URLRequest = URLRequest(url: url)
        
        if let bodyParameters = try bodyParameters?.toDictionary() {
            if !bodyParameters.isEmpty {
                urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
            }
        }
        
        // httpMethod
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // header
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }
        
        requestLogger(request: urlRequest)
        
        return urlRequest
    }
    
    func url() throws -> URL {
        let fullPath = "\(baseURL)\(path)"
        guard var urlComponents = URLComponents(string: fullPath) else { throw NetworkError.components }
        
        if let queryParameters = queryParameters,
            let dictionary = try queryParameters.toDictionary() {
            let queryItems = dictionary.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else { throw NetworkError.components }
        return url
    }
}

extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
}

fileprivate extension Data {
  var toPrettyPrintedString: String? {
    guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
      let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
      let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    else {
      return nil
    }
    return prettyPrintedString as String
  }
}

//MARK: - Network Logger
extension Requestable {
    internal func requestLogger(request: URLRequest) {
        print("")
        debugPrint("======================== 👉 Network Request Log 👈 ==========================")
        debugPrint("✅ [URL] : \(request.url?.absoluteString ?? "")")
        debugPrint("✅ [Method] : \(request.httpMethod ?? "")")
        debugPrint("✅ [Headers] : \(request.allHTTPHeaderFields ?? [:])")
        
        if let body = request.httpBody?.toPrettyPrintedString {
            debugPrint("✅ [Body] : \(body)")
        } else {
            debugPrint("✅ [Body] : body 없음")
        }
        debugPrint("==============================================================================")
        print("")
    }
    
    internal func responseLogger(response: URLResponse, data: Data) {
        print("")
        debugPrint("======================== 👉 Network Response Log 👈 ==========================")
        
        guard let response = response as? HTTPURLResponse else {
            debugPrint("✅ [Response] : HTTPURLResponse 캐스팅 실패")
            return
        }
        
        debugPrint("✅ [StatusCode] : \(response.statusCode)")
        
        switch response.statusCode {
        case 400..<500:
            debugPrint("🚨 클라이언트 오류")
        case 500..<600:
            debugPrint("🚨 서버 오류")
        default:
            break
        }
        
        debugPrint("✅ [ResponseData] : \(data.toPrettyPrintedString ?? "")")
        debugPrint("===============================================================================")
        print("")
    }
}
