//
//  SettingView.swift
//  weave-ios
//
//  Created by 강동영 on 3/11/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

struct SettingView: View {
    let store: StoreOf<SettingFeautre>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // 1. 카테고리 순회
                
                ForEach(SettingCategoryTypes.allCases, id: \.self) { category in
                    // 2. 카테고리 헤더 뷰 생성
                    SettingSubViewHeaderView(headerTitle: category.headerTitle)
                    // 3. 카테고리 내부 SubView 순회
                    ForEach(0 ..< category.getSubViewTypes.count, id: \.self) { index in
                        // 4. SubView 생성
                        let viewType = category.getSubViewTypes[index]
                        SettingSubSectionView(
                            index: index,
                            viewType: viewType
                        )
                        .onTapGesture {
                            viewStore.send(.didTappedSubViews(view: viewType))
                        }
                    }
                    Spacer()
                        .frame(height: 12)
                }
                Spacer(minLength: 200)
                HStack {
                    // TODO: 레이아웃 조정
                    Text("Version \(appVersion())")
                    Text("최신버젼")
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .weaveAlert(
                isPresented: viewStore.$isShowLogoutAlert,
                title: "로그아웃 하시겠어요?",
                message: nil,
                primaryButtonTitle: "네, 할래요",
                secondaryButtonTitle: "아니요",
                primaryAction: {
                    viewStore.send(.showLogoutAlert)
                }
            )
            .weaveAlert(
                isPresented: viewStore.$isShowUnregisterAlert,
                title: "정말 떠나시는 건가요..🥲",
                message: "조금만 있으면 새로운 기능들이 추가돼요!\n 한번 더 생각해보시는 건 어떠세요?",
                primaryButtonTitle: "탈퇴할래요",
                secondaryButtonTitle: "아니요",
                primaryAction: {
                    viewStore.send(.showUnregisterAlert)
                }
            )
            .weaveToast(
                isShowing: viewStore.$isShowPasteSuccessAlert, 
                message: "✅ ID가 복사되었어요."
            )
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
    
    private func appVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}

struct SettingSubViewHeaderView: View {
    
    let headerTitle: String
    
    var body: some View {
        HStack {
            Text(headerTitle)
                .font(.pretendard(._600, size: 14))
                .foregroundStyle(DesignSystem.Colors.textGray)
            Spacer()
        }
        .frame(height: 54)
    }
}

struct SettingSubSectionView: View {
    let index: Int
    let viewType: SettingCategoryTypes.SettingSubViewTypes
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(DesignSystem.Colors.darkGray)
                Spacer()
            }
            
            HStack {
                Text(viewType.title)
                    .font(.pretendard(._500, size: 16))
                Spacer()
                
                if viewType == .myID {
                    Text(getClippedID())
                        .font(.pretendard(._500, size: 14))
                        .foregroundStyle(DesignSystem.Colors.textGray)
                    DesignSystem.Icons.copyID
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Colors.textGray)
                } else {
                    Image(systemName: "chevron.right")
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Colors.textGray)
                }
            }
            
        }
        .frame(height: 54)
    }
    
    func getClippedID() -> String {
        let uuid = UserInfo.myInfo?.id ?? ""
        if let range = uuid.range(of: "-") {
            let shortUUID = uuid[..<range.lowerBound] + "..."
            return String(shortUUID)
        } else {
            return String(uuid.prefix(8)) + "..."
        }
    }
}

#Preview {
    SettingView(
        store: Store(
            initialState: SettingFeautre.State()
        ) {
                SettingFeautre()
            }
    )
}
