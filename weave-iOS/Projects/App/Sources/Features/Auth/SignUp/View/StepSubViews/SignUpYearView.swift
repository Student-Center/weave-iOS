//
//  SignUpYearView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/4/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import CoreKit

struct SignUpYearView: View {
    let store: StoreOf<SignUpFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack(spacing: 12) {
                    WeaveTextField(
                        text: viewStore.$birthYear,
                        placeholder: "YYYY",
                        font: .pretendard(._600, size: 20),
                        textAlignment: .center,
                        keyboardType: .numberPad
                    )
                    .frame(width: 100)
                    Text("년")
                        .font(.pretendard(._600, size: 20))
                }
                
                Text("프로필에 표시되는 나이를 위한 정보 수집으로,\n회원가입 이후 변경할 수 없어요!")
                    .font(.pretendard(._400, size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(DesignSystem.Colors.white)
                    .padding(.vertical, 11)
                
                Spacer()
                
                WeaveButton(
                    title: "다음으로",
                    size: .large,
                    isEnabled: validateNextButton(year: viewStore.birthYear)
                ) {
                    viewStore.send(
                        .didTappedNextButton,
                        animation: .easeInOut(duration: 0.2)
                    )
                }
                .padding(.bottom, 20)
            }
            .onAppear(perform: {
                UIApplication.shared.hideKeyboard()
            })
        }
    }
    
    func validateNextButton(year: String) -> Bool {
        guard year.count == 4,
              Int(year) != nil else {
            return false
        }
        return true
    }
}
