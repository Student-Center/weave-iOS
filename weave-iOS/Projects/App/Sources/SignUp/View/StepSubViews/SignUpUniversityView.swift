//
//  SignUpSchoolView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import CoreKit

struct SignUpUniversityView: View {
    
    let store: StoreOf<SignUpFeature>
    
    @FocusState var showDropDown: Bool
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                WeaveDropDownPicker(
                    dataSources: viewStore.filteredUniversityLists,
                    showDropDown: _showDropDown
                ) {
                    WeaveTextField(
                        text: viewStore.$universityText,
                        placeholder: "위브대학교",
                        showClearButton: true,
                        focusState: _showDropDown
                    )
                } tapHandler: { index in
                    let university = viewStore.filteredUniversityLists[index]
                    viewStore.send(.didTappedUniversity(university: university))
                }
                
                Spacer()
                
                WeaveButton(
                    title: "다음으로",
                    size: .large,
                    isEnabled: viewStore.selectedUniversity != nil
                ) {
                    viewStore.send(
                        .didTappedNextButton,
                        animation: .easeInOut(duration: 0.2)
                    )
                }
                .padding(.bottom, 20)
            }
            .onAppear {
                viewStore.send(.requestUniversityLists)
                UIApplication.shared.hideKeyboard()
            }
        }
    }
}
