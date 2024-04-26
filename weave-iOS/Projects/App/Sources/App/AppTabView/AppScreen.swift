//
//  AppScreen.swift
//  weave-ios
//
//  Created by 강동영 on 2/21/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case chat
    case request
    case home
    case myTeam
    case myPage
    
    var id: AppScreen { self }
}
