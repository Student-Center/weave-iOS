//
//  SplashView.swift
//  weave-ios
//
//  Created by Jisu Kim on 4/2/24.
//

import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    let store: StoreOf<SplashFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Text("스플래시뷰")
        }
    }
}
