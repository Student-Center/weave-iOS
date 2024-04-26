//
//  SetKakaoIdView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/22/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct SetKakaoIdView: View {
    
    let store: StoreOf<SetKakaoIdFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 12) {
                Text("카카오톡 ID를 입력해 주세요")
                    .frame(height: 80)
                    .font(.pretendard(._500, size: 24))
                    .padding(.top, 25)
                
                Text("미팅 날짜와 시간을 잡기 위해\n필요해요!")
                    .font(.pretendard(._500, size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                HStack {
                    WeaveTextField(
                        text: viewStore.$kakaoIdText,
                        placeholder: "카카오톡 ID",
                        textAlignment: .leading, 
                        showClearButton: true
                    )
                }
                
                Text("한 번 저장하면 변경하기 어려우니 신중히 작성해 주세요!")
                    .font(.pretendard(._400, size: 14))
                    .foregroundStyle(DesignSystem.Colors.gray600)
                
                Spacer()
                
                WeaveButton(
                    title: "저장하기",
                    size: .large,
                    isEnabled: viewStore.kakaoIdText != ""
                ) {
                    viewStore.send(.didTappedSaveButton)
                }
                .weaveAlert(
                    isPresented: viewStore.$isShowConfirmAlert,
                    title: "✅\n확인해주세요",
                    message: "입력하신 카카오톡 ID는\n\(viewStore.kakaoIdText)입니다.\n정확히 입력하셨나요??",
                    primaryButtonTitle: "네 맞아요",
                    secondaryButtonTitle: "다시 입력",
                    primaryAction: {
                        viewStore.send(.requestSetId)
                    }
                )
                .weaveAlert(
                    isPresented: viewStore.$isShowCompleteAlert,
                    title: "🎉\n카카오 Id 설정이 완료되었어요.",
                    message: "이제 얼른 미팅을 잡아보세요!",
                    primaryButtonTitle: "확인",
                    primaryAction: {
                        viewStore.send(.dismiss)
                    }
                )
            }
            .onAppear {
                UIApplication.shared.hideKeyboard()
            }
            .padding(.horizontal, 16)
            .navigationTitle("연락 수단")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    SetKakaoIdView(
        store: Store(
            initialState: SetKakaoIdFeature.State()) {
                SetKakaoIdFeature()
            }
    )
}
