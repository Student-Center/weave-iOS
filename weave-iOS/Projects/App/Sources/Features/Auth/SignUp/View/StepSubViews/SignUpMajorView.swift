//
//  SignUpMajorView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/5/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import CoreKit

struct SignUpMajorView: View {
    
    let store: StoreOf<SignUpFeature>
    
    @FocusState var showDropDown: Bool
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                WeaveDropDownPicker(
                    dataSources: viewStore.filteredMajorLists,
                    showDropDown: _showDropDown
                ) {
                    WeaveTextField(
                        text: viewStore.$majorText,
                        placeholder: "위브학과",
                        showClearButton: true,
                        focusState: _showDropDown
                    )
                } tapHandler: { index in
                    let major = viewStore.filteredMajorLists[index]
                    viewStore.send(.didTappedMajors(major: major))
                }
                
                Spacer()
                
                WeaveButton(
                    title: "다음으로",
                    size: .large,
                    isEnabled: viewStore.selectedmajor != nil
                ) {
                    viewStore.send(
                        .didTappedNextButton,
                        animation: .easeInOut(duration: 0.2)
                    )
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                viewStore.send(.requestMajors)
                UIApplication.shared.hideKeyboard()
            }
        }
    }
}
