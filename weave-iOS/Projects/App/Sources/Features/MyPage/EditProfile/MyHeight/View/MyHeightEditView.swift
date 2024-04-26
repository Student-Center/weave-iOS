//
//  MyHeightEditView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/24/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct MyHeightEditView: View {
    
    let store: StoreOf<MyHeightEditFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                Text("내 키는?")
                    .frame(height: 80)
                    .font(.pretendard(._600, size: 20))
                
                HStack {
                    WeaveTextField(
                        text: viewStore.$heightText,
                        placeholder: "YYY",
                        textAlignment: .center,
                        keyboardType: .numberPad
                    )
                    .frame(width: 81)
                    
                    Text("cm")
                        .font(.pretendard(._600, size: 20))
                }
                
                Spacer()
                
                WeaveButton(
                    title: "저장하기",
                    size: .large,
                    isEnabled: validateHeight(height: viewStore.heightText)
                ) {
                    viewStore.send(.didTappedSaveButton)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    func validateHeight(height: String) -> Bool {
        guard let height = Int(height),
              height > 100 && 250 > height else {
            return false
        }
        return true
    }
}

#Preview {
    MyHeightEditView(
        store: Store(
            initialState: MyHeightEditFeature.State()) {
                MyHeightEditFeature()
            }
    )
}
