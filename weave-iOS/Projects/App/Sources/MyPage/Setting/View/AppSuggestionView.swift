//
//  AppSuggestionView.swift
//  Weave-ios
//
//  Created by 김지수 on 4/22/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct AppSuggestionView: View {
    let store: StoreOf<AppSuggestionFeature>
    let textLimit = 2000
    @State var isShowTextLimitAlert: Bool = false
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                ScrollView {
                    VStack {
                        VStack(spacing: 12) {
                            Text("개선할 점을 알려주세요")
                                .font(.pretendard(._600, size: 24))
                            Text("여러분의 의견은 위브에 아주 큰 도움이 돼요!")
                                .font(.pretendard(._500, size: 16))
                        }
                        .multilineTextAlignment(.center)
                        .padding(.top, 38)
                        .padding(.bottom, 58)
                        
                        WeaveTextView(
                            text: viewStore.$inputText,
                            placeholder: "의견을 작성해 주세요.",
                            height: 188
                        )
                        .onChange(of: viewStore.inputText) { oldValue, newValue in
                            if newValue.count > textLimit {
                                isShowTextLimitAlert = true
                                let newText = viewStore.inputText.prefix(textLimit)
                                viewStore.send(.replaceInputText(text: String(newText)))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                WeaveButton(
                    title: "제출하기",
                    size: .large,
                    isEnabled: !viewStore.inputText.isEmpty
                ) {
                    viewStore.send(.didTappedSummitButton)
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                UIApplication.shared.hideKeyboard()
            }
            .weaveAlert(
                isPresented: $isShowTextLimitAlert,
                title: "🙇‍♂️\n최대 2000자까지 작성 가능해요.",
                primaryButtonTitle: "확인했어요",
                primaryAction: {
                    viewStore.send(.didTappedUserCompleteButton)
                }
            )
            .weaveAlert(
                isPresented: viewStore.$isShowCompleteAlert,
                title: "🙇‍♂️\n의견이 정상적으로 제출됐어요.",
                message: "소중한 의견 감사합니다!",
                primaryButtonTitle: "확인했어요",
                primaryAction: {
                    viewStore.send(.didTappedUserCompleteButton)
                }
            )
            .navigationTitle("위브 개선 제안")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewStore.send(.didTappedDismiss)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    AppSuggestionView(store: .init(initialState: AppSuggestionFeature.State(), reducer: {
        AppSuggestionFeature()
    }))
}
