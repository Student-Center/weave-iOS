//
//  SplashView.swift
//  weave-ios
//
//  Created by Jisu Kim on 4/2/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct SplashView: View {
    let store: StoreOf<SplashFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            DesignSystem.Icons.splashLogo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 80)
        }
    }
}

#Preview {
    SplashView(store: .init(initialState: SplashFeature.State(), reducer: {
        SplashFeature()
    }))
}
