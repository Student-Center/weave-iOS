//
//  MyMbtiEditView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/26/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

struct MyMbtiEditView: View {
    
    let store: StoreOf<MyMbtiEditFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                CenterTitleView(title: "내 MBTI는 ?") {
                    viewStore.send(.dismiss)
                }

                ScrollView {
                    VStack {
                        MBTIPickerView(model: viewStore.$mbtiDataModel)
                    }
                    .padding(.horizontal, 16)
                }
                WeaveButton(title: "저장하기", size: .large) {
                    viewStore.send(.didTappedSaveButton)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview(body: {
    MyMbtiEditView(
        store: Store(
            initialState: MyMbtiEditFeature.State(
                mbtiDataModel: MBTIDataModel(mbti: "ESTJ")),
            reducer: {
        MyMbtiEditFeature()
    }))
})
