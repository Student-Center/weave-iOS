//
//  SignUpGenderView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

struct SignUpGenderView: View {
    let store: StoreOf<SignUpFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .center) {
                VStack {
                    
                    Spacer()
                    
                    WeaveButton(
                        title: "다음으로",
                        size: .large,
                        isEnabled: viewStore.selectedGender != nil
                    ) {
                        viewStore.send(
                            .didTappedNextButton,
                            animation: .easeInOut(duration: 0.2)
                        )
                    }
                    .padding(.bottom, 20)
                }
                
                HStack(spacing: 56) {
                    genderSelectionView(.boy)
                    genderSelectionView(.girl)
                }
                .offset(y: -65)
            }
        }
    }
    
    @ViewBuilder
    func genderSelectionView(_ gender: SignUpFeature.GenderTypes) -> some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            let foregroundColor = viewStore.selectedGender == gender ? DesignSystem.Colors.defaultBlue : DesignSystem.Colors.lightGray
            
            VStack {
                gender.getIconImage(isSelected: viewStore.selectedGender == gender)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 108)
                
                Text(gender.title)
                    .font(.pretendard(._500, size: 20))
                    .foregroundStyle(foregroundColor)
            }
            .onTapGesture {
                viewStore.send(.didTappedGender(gender: gender))
            }
        }
    }
}
