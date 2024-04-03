//
//  NotificationManager.swift
//  CoreKit
//
//  Created by Jisu Kim on 4/2/24.
//

import Combine
import Foundation

public enum RootViewType: String {
    case splash
    case main
    case login
    case signUp
    
    var name: Notification.Name {
        return .init(self.rawValue)
    }
}

public enum NotificationManager {
    static let center = NotificationCenter.default
    
    public static func post(_ noti: RootViewType, userInfo: [AnyHashable: Any]? = nil) {
        DispatchQueue.main.async {
            center.post(name: noti.name, object: nil, userInfo: userInfo)
        }
    }
    
    public static func publisher(
        _ noti: RootViewType,
        scheduler: some Scheduler = DispatchQueue.main
    ) -> AnyPublisher<[AnyHashable: Any]?, Never> {
        return center.publisher(for: .init(noti.rawValue))
            .receive(on: scheduler)
            .map(\.userInfo)
            .eraseToAnyPublisher()
    }
}
