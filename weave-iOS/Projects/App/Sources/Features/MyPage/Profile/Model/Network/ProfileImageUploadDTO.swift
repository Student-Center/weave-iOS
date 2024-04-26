//
//  ProfileImageUploadDTO.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/25/24.
//

import Foundation
import Services
import CoreKit

struct ProfileImageUploadPresignedURLResponseDTO: Decodable {
    let uploadUrl: String
    let imageId: String
    let `extension`: String
}

struct ProfileImageUploadCallbackRequest: Encodable {
    let imageId: String
    let `extension`: String
    
    init(imageId: String, extension: String = "JPG") {
        self.imageId = imageId
        self.extension = `extension`
    }
}

extension APIEndpoints {
    static func getProfileImageUploadPresignedURL() -> EndPoint<ProfileImageUploadPresignedURLResponseDTO> {
        return EndPoint(
            path: "api/users/my/profile-image/upload-url?extension=JPG",
            method: .get,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
    
    static func getProfileImageUpload(presignedURL: String) -> EndPoint<EmptyResponse> {
        return EndPoint(
            baseURL: presignedURL,
            path: "",
            method: .put,
            headers: [
                "Content-Type": "image/jpeg"
            ]
        )
    }
    
    static func getProfileImageUploadCallback(imageId: String) -> EndPoint<EmptyResponse> {
        let requestDTO = ProfileImageUploadCallbackRequest(imageId: imageId)
        return EndPoint(
            path: "api/users/my/profile-image/upload-callback",
            method: .post,
            bodyParameters: requestDTO,
            headers: [
                "Authorization": "Bearer \(UDManager.accessToken)"
            ]
        )
    }
}
