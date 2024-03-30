//
//  SignUpView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/4/24.
//

import SwiftUI
import Services
import DesignSystem
import ComposableArchitecture

struct SignUpView: View {
    
    let store: StoreOf<SignUpFeature>
    @State private var networkErrorManager = ServiceErrorManager.shared
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                if viewStore.currentStep.rawValue < 5 {
                    WeaveStepper(
                        maxStepCount: 5,
                        currentStep: viewStore.currentStep.rawValue
                    )
                    Spacer()
                        .frame(height: 30)
                }

                Text(viewStore.currentStep.title)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
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
                case .agreement:
                    SignUpAgreementView(store: store)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 1)
            .toolbar {
                if viewStore.currentStep.rawValue > 0 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewStore.send(.didTappedPreviousButton)
                        }, label: {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(.white)
                        })
                    }
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
            .weaveErrorMessage(
                isPresented: $networkErrorManager.needShowErrorAlert,
                message: networkErrorManager.errorMessage
            ) {
                networkErrorManager.handleAlertConfirmAction()
            }
        }
    }
}

struct SignUpAgreementView: View {
    
    let store: StoreOf<SignUpFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    let checkBoxState = getAllCheckBoxState([
                        viewStore.isAgeCompatibilityEnabled,
                        viewStore.isServiceAgreementEnabled,
                        viewStore.isPrivacyAgreementEnabled
                    ])
                    allCheckBoxImage(checkBoxState)
                        .resizable()
                        .frame(width: 19, height: 19)
                        .onTapGesture {
                            viewStore.send(.didAllAgreeChanged(value: !checkBoxState))
                        }
                    Text("전체 동의하기")
                        .font(.pretendard(._500, size: 16.8))
                        .onTapGesture {
                            viewStore.send(.didAllAgreeChanged(value: !checkBoxState))
                        }
                    Spacer()
                }
                .frame(height: 38)

                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(DesignSystem.Colors.gray700)
                
                getAgreementHStack(
                    title: "(필수) 만 14세 이상",
                    isEnabled: viewStore.$isAgeCompatibilityEnabled
                )
                getAgreementHStack(
                    title: "(필수) 위브 서비스 이용약관 동의",
                    isEnabled: viewStore.$isServiceAgreementEnabled,
                    link: URLConstant.termsAndConditionsUrl
                ) { url in
                    viewStore.send(.didTappedAgreementView(url: url))
                }
                getAgreementHStack(
                    title: "(필수) 개인정보 수집 및 이용약관 동의",
                    isEnabled: viewStore.$isPrivacyAgreementEnabled,
                    link: URLConstant.privacyPolicy
                ) { url in
                    viewStore.send(.didTappedAgreementView(url: url))
                }
                
                Spacer()
                
                WeaveButton(
                    title: "다음으로",
                    size: .large,
                    isEnabled: validateNextButton([
                        viewStore.isAgeCompatibilityEnabled,
                        viewStore.isServiceAgreementEnabled,
                        viewStore.isPrivacyAgreementEnabled
                    ])
                ) {
                    viewStore.send(
                        .didTappedNextButton,
                        animation: .easeInOut(duration: 0.2)
                    )
                }
                .padding(.bottom, 20)
            }
            .padding(.top, 59)
        }
    }
    
    func getAllCheckBoxState(_ agreeElements: [Bool]) -> Bool {
        return agreeElements.allSatisfy({ $0 == true })
    }
    
    func allCheckBoxImage(_ state: Bool) -> Image {
        if state == true {
            return DesignSystem.Icons.checkboxEnabled
        } else {
            return DesignSystem.Icons.checkboxDiabled
        }
    }
    
    @ViewBuilder
    func getAgreementHStack(
        title: String,
        isEnabled: Binding<Bool>,
        link: URL? = nil,
        linkHandler: ((URL?) -> Void)? = nil
    ) -> some View {
        HStack(spacing: 8) {
            WeaveCheckBox(
                isSelect: isEnabled,
                size: 16
            )
            Text(title)
                .font(.pretendard(._500, size: 14))
                .onTapGesture {
                    withAnimation {
                        isEnabled.wrappedValue.toggle()
                    }
                }
            
            Spacer()
            
            if let link {
                Text("보기")
                    .font(.pretendard(._500, size: 14))
                    .foregroundStyle(DesignSystem.Colors.gray700)
                    .underline()
                    .onTapGesture {
                        linkHandler?(link)
                    }
            }
        }
        .frame(height: 38)
    }
    
    func validateNextButton(
        _ elements: [Bool]
    ) -> Bool {
        elements.allSatisfy { $0 == true }
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
