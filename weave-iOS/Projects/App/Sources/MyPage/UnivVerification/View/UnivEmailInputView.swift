//
//  UnivEmailInputView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/19/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct UnivEmailInputView: View {
    
    let store: StoreOf<UnivEmailInputFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                    .frame(height: 38)
                
                VStack(spacing: 12) {
                    Text("학교 이메일을 입력해주세요")
                        .font(.pretendard(._500, size: 24))
                    
                    Text("대학교 인증을 완료해야\n내 팀을 만들 수 있어요!")
                        .font(.pretendard(._400, size: 16))
                }
                
                if let univInfo = viewStore.universityInfo {
                    HStack(spacing: 12) {
                        WeaveTextField(
                            text: viewStore.$emailPrefix,
                            placeholder: "welcome"
                        )
                        
                        Text("@" + univInfo.domainAddress)
                            .font(.pretendard(._500, size: 18))
                            .foregroundStyle(DesignSystem.Colors.lightGray)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 24)
                }
                
                Spacer()
                
                WeaveButton(
                    title: "인증메일 보내기",
                    size: .large,
                    isEnabled: !viewStore.emailPrefix.isEmpty && viewStore.universityInfo != nil
                ) {
                    viewStore.send(.requestSendVerifyEmail)
                }
                .frame(height: 56)
                .padding(.horizontal, 16)
                .weaveAlert(
                    isPresented: viewStore.$isShowEmailSendAlert,
                    title: "✅\n인증번호 발송 완료!",
                    message: "메일로 인증번호가 발송되었어요.\n메일을 확인해 인증번호를 입력해 주세요.",
                    primaryButtonTitle: "네, 좋아요",
                    primaryAction: {
                        viewStore.send(.pushNextView)
                    }
                )
                .weaveAlert(
                    isPresented: viewStore.$isShowEmailSendErrorAlert,
                    title: "🚨\n잘못된 이메일",
                    message: "이메일 전송에 실패했어요.\n이메일 주소를 다시 확인해주세요",
                    primaryButtonTitle: "다시 시도할께요"
                )
            }
            .onAppear {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    viewStore.send(.requestUniversityInfo)
//                }
                UIApplication.shared.hideKeyboard()
            }
            .navigationBarBackButtonHidden()
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("대학교 인증")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "chevron.left")
                }
            }
            .navigationDestination(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /UnivEmailInputFeature.Destination.State.emailVerify,
                action: UnivEmailInputFeature.Destination.Action.emailVerify
            ) { store in
                UnivEmailVerifyView(store: store)
            }
        }
    }
}

#Preview {
    UnivEmailInputView(
        store: Store(
            initialState: UnivEmailInputFeature.State(universityName: "명지대학교")) {
                UnivEmailInputFeature()
            }
    )
}
