//
//  MyPageView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/15/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import Kingfisher
import CoreKit

struct MyPageView: View {
    
    let store: StoreOf<MyPageFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack {
                        MyProfileHeaderSectionView(store: store)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        
                        VStack(spacing: 0) {
                            // 1. 카테고리 순회
                            ForEach(MyPageCategoryTypes.allCases, id: \.self) { category in
                                // 2. 카테고리 헤더 뷰 생성
                                MyPageSubViewHeaderView(headerTitle: category.headerTitle)
                                if let userInfo = viewStore.myUserInfo {
                                    // 3. 카테고리 내부 SubView 순회
                                    ForEach(0 ..< category.getSubViewTypes.count, id: \.self) { index in
                                        // 4. SubView 생성
                                        let viewType = category.getSubViewTypes[index]
                                        MyPageSubSectionView(
                                            index: index,
                                            viewType: viewType,
                                            userInfo: userInfo
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            viewStore.send(.didTappedSubViews(view: viewType))
                                        }
                                    }
                                    Spacer()
                                        .frame(height: 12)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .refreshable {
                    viewStore.send(.requestMyUserInfo)
                }
                .navigationDestination(isPresented: viewStore.$isShowCompleteUnivVerifyView, destination: {
                    UnivEmailCompleteView()
                })
                .weaveAlert(
                    isPresented: viewStore.$isShowCompleteUnivVerifyAlert,
                    title: "✅\n대학교 인증 완료!",
                    message: "이제 내 팀을 만들 수 있어요.\n지금 바로 내 팀을 만들러 가볼까요?",
                    primaryButtonTitle: "네, 좋아요",
                    secondaryButtonTitle: "나중에",
                    primaryAction: {
                        viewStore.send(.didTappedGoToGenerateMyTeam)
                    }
                )
                .onLoad {
                    viewStore.send(.requestMyUserInfo)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("마이")
                            .font(.pretendard(._600, size: 20))
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewStore.send(.didTappedPreferenceButton)
                        }, label: {
                            DesignSystem.Icons.setting
                                .resizable()
                                .frame(width: 24, height: 24)
                        })
                        .foregroundStyle(.white)
                    }
                })
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MyPageFeature.Destination.State.presentSetting,
                    action: MyPageFeature.Destination.Action.presentSetting
                ) { store in
                    SettingView(store: store)
                        .environmentObject(AppCoordinator.shared)
                }
                // 카카오 Id 설정
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MyPageFeature.Destination.State.setKakaoId,
                    action: MyPageFeature.Destination.Action.setKakaoId
                ) { store in
                    SetKakaoIdView(store: store)
                }
                // 대학교 인증
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MyPageFeature.Destination.State.univVerify,
                    action: MyPageFeature.Destination.Action.univVerify
                ) { store in
                    UnivEmailInputView(store: store)
                }
            }
            // MBTI
            .sheet(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /MyPageFeature.Destination.State.editMbti,
                action: MyPageFeature.Destination.Action.editMbti
            ) { store in
                MyMbtiEditView(store: store)
                    .presentationDetents([.fraction(0.8)])
                    .presentationDragIndicator(.visible)
            }
            // 닮은 동물 선택
            .sheet(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /MyPageFeature.Destination.State.editAnimal,
                action: MyPageFeature.Destination.Action.editAnimal
            ) { store in
                MyAnimalSelectionView(store: store)
                    .presentationDetents([.fraction(0.8)])
                    .presentationDragIndicator(.visible)
            }
            // 키 변경
            .sheet(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /MyPageFeature.Destination.State.editHeight,
                action: MyPageFeature.Destination.Action.editHeight
            ) { store in
                MyHeightEditView(store: store)
                    .presentationDetents([.fraction(0.8)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

fileprivate struct MyProfileHeaderSectionView: View {
    
    let store: StoreOf<MyPageFeature>
    
    fileprivate var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                HStack {
                    ZStack {
                        if let profileURL = viewStore.myUserInfo?.avatar {
                            KFImage(URL(string: profileURL))
                                .placeholder{
                                    WeaveIndicator(animated: true)
                                }
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 72, height: 72)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding([.trailing, .bottom], 8)
                                .onTapGesture {
                                    viewStore.send(.didTappedProfileView)
                                }
                        } else {
                            DesignSystem.Icons.profileImage
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding([.trailing, .bottom], 8)
                                .onTapGesture {
                                    viewStore.send(.didTappedProfileView)
                                }
                        }
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                // 프로필 변경 버튼, 액션
                                DesignSystem.Icons.profileEdit
                                    .resizable()
                                    .frame(width: 22, height: 22)
                                    .onTapGesture {
                                        viewStore.send(.didTappedProfileEditButton)
                                    }
                                    .confirmationDialog(
                                        "ProfileImage",
                                        isPresented: viewStore.$isShowEditProfileImageAlert,
                                        titleVisibility: .hidden
                                    ) {
                                        Button("사진 찍기", role: .none) {
                                            viewStore.send(.didTappedShowCamera)
                                        }
                                        Button("앨범에서 가져오기", role: .none) {
                                            viewStore.send(.showPhotoPicker)
                                        }
                                        Button("취소", role: .cancel) {}
                                    }
                                    .photoPicker(isPresented: viewStore.$isShowPhotoPicker) { images in
                                        guard let image = images.first else { return }
                                        DispatchQueue.main.async {
                                            viewStore.send(.didPickPhotoCompleted(image: image))
                                        }
                                    }
                                    .camera(isPresented: viewStore.$isShowCamera) { image in
                                        viewStore.send(.didPickPhotoCompleted(image: image))
                                    }
                                    .weaveAlert(
                                        isPresented: viewStore.$isShowCameraPermissionAlert,
                                        title: "카메라 접근 권한이 필요해요",
                                        message: "설정에서 카메라 접근 권한을 허용해주세요",
                                        primaryButtonTitle: "설정",
                                        secondaryButtonTitle: "취소",
                                        primaryAction: {
                                            viewStore.send(.showAppPreference)
                                        }
                                    )
                            }
                        }
                    }
                    .frame(width: 80, height: 80, alignment: .bottomTrailing)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 3) {
                            Text(viewStore.myUserInfo?.universityName ?? "")
                            if let isCertified = viewStore.myUserInfo?.isUniversityEmailVerified {
                                let certificatedIcon: Image = isCertified ? DesignSystem.Icons.certified : DesignSystem.Icons.nonCertified
                                certificatedIcon
                                    .resizable()
                                    .frame(width: 14, height: 14)
                            }
                        }
                        Text(viewStore.myUserInfo?.majorName ?? "")
                        Text(viewStore.myUserInfo?.birthYearShortText ?? "")
                    }
                    .font(.pretendard(._500, size: 14))
                    
                    Spacer()
                    
                    VStack {
                        HStack(spacing: 3) {
                            Text("보유")
                                .font(.pretendard(._700, size: 10))
                            Text("\(viewStore.myUserInfo?.sil ?? 0)실")
                                .font(.pretendard(._700, size: 12))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 10)
                        .frame(height: 28)
                        .background(LinearGradient.weaveGradientReversed)
                        .clipShape(
                            Capsule()
                        )
                        Spacer()
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundStyle(DesignSystem.Colors.darkGray)
                    Text("⚠️ 프로필 사진은 미팅 매칭 후 생성된 채팅방에서만 확인 가능하니 안심하세요!")
                        .font(.pretendard(._400, size: 11))
                        .foregroundStyle(DesignSystem.Colors.textGray)
                }
                .frame(height: 24)
            }
        }
    }
}

fileprivate struct MyPageSubViewHeaderView: View {
    
    let headerTitle: String
    
    fileprivate var body: some View {
        HStack {
            Text(headerTitle)
                .font(.pretendard(._600, size: 14))
                .foregroundStyle(DesignSystem.Colors.textGray)
            Spacer()
        }
        .frame(height: 54)
    }
}

fileprivate struct MyPageSubSectionView: View {
    let index: Int
    let viewType: MyPageCategoryTypes.MyPageSubViewTypes
    let userInfo: MyUserInfoModel
    
    fileprivate var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(DesignSystem.Colors.darkGray)
                Spacer()
            }
            HStack {
                viewType.icon
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(viewType.title)
                    .font(.pretendard(._500, size: 16))
                Spacer()
                Text(viewType.actionTitle(by: userInfo))
                    .font(.pretendard(._500, size: 14))
                    .foregroundStyle(viewType.foregroundColor(by: userInfo))
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Colors.textGray)
            }
        }
        .frame(height: 54)
    }
}

#Preview {
    MyPageView(
        store: Store(
            initialState: MyPageFeature.State()) {
                MyPageFeature()
            }
    )
}
