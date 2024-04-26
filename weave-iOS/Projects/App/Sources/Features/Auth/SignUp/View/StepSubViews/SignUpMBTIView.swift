//
//  SignUpMBTIView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

struct SignUpMBTIView: View {
    
    let store: StoreOf<SignUpFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                MBTIPickerView(model: viewStore.$mbtiDatas)
                
                Spacer()
                
                WeaveButton(
                    title: "다음으로",
                    size: .large,
                    isEnabled: viewStore.mbtiDatas.validate()
                ) {
                    viewStore.send(
                        .didTappedNextButton,
                        animation: .easeInOut(duration: 0.2)
                    )
                }
                .padding(.bottom, 20)
            }
        }
    }
}
