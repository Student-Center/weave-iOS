//
//  KakaoShareManager.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/24/24.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKShare
import KakaoSDKTemplate
import SafariServices

class KakaoShareManager {
    static func getMeetingTeamShareMessage(teamId: String) -> Data {
        return """
                {
                    "object_type": "feed",
                    "content": {
                        "title": "[WEAVE] 친구야 이 팀 어때?",
                        "image_url": "\(SecretKey.serverResourcePath)/share_image.png",
                        "link": {
                            "ios_execution_params": "type=team&teamId=\(teamId)",
                            "androidExecutionParams": "type=team&teamId=\(teamId)"
                        },
                    },
                    "buttons": [
                        {
                            "title": "팀 상세보기",
                            "link": {
                                "ios_execution_params": "type=team&teamId=\(teamId)",
                                "androidExecutionParams": "type=team&teamId=\(teamId)"
                            }
                        }
                    ]
                }
                """
                .data(using: .utf8)!
    }
    
    static func getInviteTeamShareMessage(code: String) -> Data {
        return """
                {
                    "object_type": "feed",
                    "content": {
                        "title": "[WEAVE] 친구야 같이 미팅하자",
                        "image_url": "\(SecretKey.serverResourcePath)/share_image.png",
                        "link": {
                                "androidExecutionParams": "type=invitation&code=\(code)&userId=\(UserInfo.myInfo?.id ?? "")",
                                "ios_execution_params": "type=invitation&code=\(code)&userId=\(UserInfo.myInfo?.id ?? "")"
                        },
                    },
                    "buttons": [
                        {
                            "title": "초대장 확인하기",
                            "link": {
                                "ios_execution_params": "type=invitation&code=\(code)&userId=\(UserInfo.myInfo?.id ?? "")",
                                "androidExecutionParams": "type=invitation&code=\(code)&userId=\(UserInfo.myInfo?.id ?? "")"
                            }
                        }
                    ]
                }
                """
                .data(using: .utf8)!
    }
    
    static func shareMessage(with data: Data) {
        guard let templatable = try? SdkJSONDecoder.custom.decode(FeedTemplate.self, from: data) else {
            return
        }
        // 카카오톡 설치여부 확인
        if ShareApi.isKakaoTalkSharingAvailable() {
            // 카카오톡으로 카카오톡 공유 가능
            // templatable은 메시지 만들기 항목 참고
            ShareApi.shared.shareDefault(templatable: templatable) {(sharingResult, error) in
                if let error = error {
                    print(error)
                } else {
                    print("shareDefault() success.")
                    
                    if let sharingResult = sharingResult {
                        UIApplication.shared.open(
                            sharingResult.url,
                            options: [:], completionHandler: nil
                        )
                    }
                }
            }
        }
    }
}
