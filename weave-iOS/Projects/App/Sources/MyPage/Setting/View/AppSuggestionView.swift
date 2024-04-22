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
                        .padding(.top, 38)
                        .padding(.bottom, 58)
                        
                        Rectangle()
                            .frame(height: 188)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                }
                WeaveButton(
                    title: "제출하기",
                    size: .large
                )
                .padding(.horizontal, 16)
            }
            .navigationTitle("위브 개선 제안")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
//                        viewStore.send(.didTappedDismiss)
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
