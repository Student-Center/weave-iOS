//
//  SignUpView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/4/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct SignUpView: View {
    
    let store: StoreOf<SignUpFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                WeaveStepper(
                    maxStepCount: 5,
                    currentStep: viewStore.currentStep.rawValue
                )
                Spacer()
                    .frame(height: 30)
                
                Text(viewStore.currentStep.title)
                    .multilineTextAlignment(.center)
                    .font(.pretendard(._500, size: 22))
                    .frame(height: 100)
                
                switch viewStore.currentStep {
                case .gender:
                    SignUpGenderView(store: store)
                case .year:
                    SignUpYearView(store: store)
                case .mbti:
                    SignUpMBTIView(store: store)
                case .university:
                    SignUpUniversityView(store: store)
                case .major:
                    SignUpMajorView(store: store)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 1)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewStore.send(.didTappedPreviousButton)
                    }, label: {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        viewStore.send(.didTappedDismissButton)
                    }, label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.white)
                    })
                    .weaveAlert(
                        isPresented: viewStore.$isDismissAlertShow,
                        title: "잠깐만요!",
                        message: "회원가입은 잠깐이면 끝나요!\n다시 진행해 보시겠어요?",
                        primaryButtonTitle: "네, 좋아요",
                        secondaryButtonTitle: "아니요",
                        secondaryAction: {
                            viewStore.send(.dismissSignUp)
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    SignUpView(
        store: Store(
            initialState: SignUpFeature.State(
                registerToken: ""
            )
        ) {
            SignUpFeature()
        }
    )
}
