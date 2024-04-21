//
//  MyTeamView.swift
//  weave-ios
//
//  Created by 강동영 on 2/21/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Kingfisher
import CoreKit

struct MyTeamView: View {
    
    let store: StoreOf<MyTeamFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    if !viewStore.didDataFetched {
                        ProgressView()
                    }  else {
                        GeometryReader { geometry in
                            ScrollView {
                                if viewStore.myTeamList.isEmpty {
                                    getEmptyView(viewSize: geometry.size) {
                                        viewStore.send(.didTappedGenerateMyTeam)
                                    }
                                } else {
                                    LazyVStack(spacing: 20) {
                                        ForEach(viewStore.myTeamList, id: \.id) { team in
                                            MyTeamItemView(store: store, teamModel: team)
                                        }
                                        
                                        if !viewStore.myTeamList.isEmpty && viewStore.nextCallId != nil {
                                            ProgressView()
                                                .onAppear {
                                                    viewStore.send(.requestMyTeamListNextPage)
                                                }
                                        }
                                        
                                        if !viewStore.myTeamList.isEmpty {
                                            Text(
                                        """
                                        팀원이 다 들어오면 자동으로 팀이 공개되고,
                                        미팅 요청을 받을 수 있어요!
                                        """
                                            )
                                            .font(.pretendard(._500, size: 14))
                                            .foregroundStyle(DesignSystem.Colors.lightGray)
                                            .multilineTextAlignment(.center)
                                            .padding(.vertical, 11)
                                        }
                                    }
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 16)
                                }
                            }
                            .refreshable {
                                viewStore.send(.requestMyTeamList)
                            }
                        }
                    }
                }
                .weaveAlert(
                    isPresented: viewStore.$isShowNeedKakaoIdAlert,
                    title: "카카오톡 ID가 필요해요!",
                    message: "카카오톡 ID를 입력한 회원만\n내 팀 생성이 가능해요.\n지금 바로 입력하러 가볼까요?",
                    primaryButtonTitle: "네, 좋아요",
                    secondaryButtonTitle: "나중에",
                    primaryAction: {
                        viewStore.send(.didTappedGoToKakaoIdInputView)
                    }
                )
                .onLoad {
                    viewStore.send(.requestMyTeamList)
                }
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MyTeamFeature.Destination.State.generateMyTeam,
                    action: MyTeamFeature.Destination.Action.generateMyTeam
                ) { store in
                    GenerateMyTeamView(store: store)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("내 팀")
                            .font(.pretendard(._600, size: 20))
                    }
                })
            }
        }
    }
    
    @ViewBuilder
    func getEmptyView(viewSize: CGSize, handler: @escaping () -> Void) -> some View {
        ListEmptyGuideView(
            headerTitle: "내 팀을 만들어 보세요!",
            subTitle: "내 팀이 있어야 미팅 요청을 할 수 있어요.",
            buttonTitle: "내 팀 만들기",
            viewSize: viewSize,
            buttonHandler: handler
        )
    }
}

fileprivate struct MyTeamItemView: View {
    let store: StoreOf<MyTeamFeature>
    let teamModel: MyTeamItemModel
    @State var isShowTeamEditSheet = false
    @State var isShowDeleteConfirmAlert = false
    
    var sortedTeamMember: [MyTeamMemberModel] {
        return teamModel.memberInfos.sorted { $0.role.sortValue < $1.role.sortValue }
    }
    
    var isTeamCompleted: Bool {
        return teamModel.memberCount?.countValue == teamModel.memberInfos.count
    }
    
    var isMyHostTeam: Bool {
        for member in teamModel.memberInfos {
            if member.role == .leader && member.isMe {
                return true
            }
        }
        return false
    }
    
    fileprivate var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                HStack {
                    RoundCornerBoxedTextView(
                        teamModel.memberCount?.text ?? "",
                        tintColor: DesignSystem.Colors.lightGray
                    )
                    RoundCornerBoxedTextView(
                        teamModel.teamIntroduce,
                        tintColor: DesignSystem.Colors.lightGray
                    )
                    locationView(location: teamModel.location)
                    Spacer()
                    if isMyHostTeam {
                        DesignSystem.Icons.menu
                            .onTapGesture {
                                isShowTeamEditSheet.toggle()
                            }
                    }
                }
                
                HStack(alignment: .top) {
                    Spacer()
                    if let memberCount = teamModel.memberCount {
                        ForEach(0 ..< memberCount.countValue, id: \.self) { index in
                            if index <= teamModel.memberInfos.count - 1 {
                                // 리얼유저
                                MyTeamMemberView(member: sortedTeamMember[index])
                            } else {
                                // 더미
                                MyTeamEmptyMemberView(isMyHostTeam: isMyHostTeam) {
                                    // 친구 초대 눌렸을 때
                                    viewStore.send(.didTappedInviteButton(team: teamModel))
                                }
                                .background {
                                    if let inviteLink = viewStore.teamInviteLink {
                                        ActivityView(
                                            isPresented: viewStore.$isShowActivityView,
                                            activityItmes: [URL(string: inviteLink)!]
                                        )
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
            }
            .confirmationDialog("", isPresented: $isShowTeamEditSheet) {
                Button("내 팀 수정하기") {
                    viewStore.send(.didTappedModifyMyTeam(team: teamModel))
                }
                Button("삭제하기", role: .destructive) {
                    isShowDeleteConfirmAlert.toggle()
                }
                Button("닫기", role: .cancel) {}
            }
            .weaveAlert(
                isPresented: $isShowDeleteConfirmAlert,
                title: "\(teamModel.teamIntroduce)팀을\n삭제하시겠어요?",
                message: isTeamCompleted ? "팀을 삭제하시면 진행중인 미팅 요청과 매칭이 자동 취소돼요!" : nil,
                primaryButtonTitle: "삭제할래요",
                primaryButtonColor: DesignSystem.Colors.notificationRed,
                secondaryButtonTitle: "아니요",
                primaryAction: {
                    viewStore.send(.requestDeleteTeam(teamId: teamModel.id))
                }
            )
            .padding(.bottom, 19)
            .padding([.top, .leading, .trailing], 12)
            .background(DesignSystem.Colors.darkGray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    func locationView(location: String) -> some View {
        HStack(spacing: 5) {
            DesignSystem.Icons.mapWhite
            Text(location)
                .font(.pretendard(._600, size: 12))
        }
    }
}

fileprivate struct MyTeamMemberView: View {
    
    let member: MyTeamMemberModel
    
    var isLeader: Bool {
        return member.role == .leader
    }
    
    fileprivate var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let mbtiType = MBTIType(rawValue: member.mbti.uppercased()) {
                    KFImage(URL(string: mbtiType.mbtiProfileImage))
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: 1)
                                .stroke(.white, lineWidth: isLeader ? 1 : 0)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 1)
                        .stroke(.white, lineWidth: isLeader ? 1 : 0)
                        .background(DesignSystem.Colors.lightGray)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                if isLeader {
                    HStack {
                        VStack {
                            DesignSystem.Icons.crown
                                .resizable()
                                .frame(width: 20, height: 20)
                            Spacer()
                        }
                        Spacer()
                    }
                    .offset(x: -6.5, y: -7.5)
                }
            }
            .frame(width: 48, height: 48)
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 4) {
                Text(member.displayUnivBirthText)
                Text(member.mbti)
            }
            .font(.pretendard(._600, size: 12))
        }
    }
}

fileprivate struct MyTeamEmptyMemberView: View {
    
    let isMyHostTeam: Bool
    var handler: () -> Void
    
    fileprivate var body: some View {
        GeometryReader(content: { geometry in
            VStack(spacing: 12) {
                ZStack {
                    DesignSystem.Icons.dotLineRect
                        .resizable()
                    if isMyHostTeam {
                        DesignSystem.Icons.plus
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(width: 48, height: 48)
                .frame(maxWidth: .infinity)
                
                if isMyHostTeam {
                    WeaveButton(title: "친구 초대", size: .tiny) {
                        handler()
                    }
                    .frame(width: 73)
                } else {
                    Text("곧 들어와요")
                        .font(.pretendard(._600, size: 12))
                        .foregroundStyle(DesignSystem.Colors.gray600)
                }
            }
        })
    }
}

#Preview {
    AppTabView(
        store: Store(
            initialState: AppTabViewFeature.State(),
            reducer: {
                AppTabViewFeature()
            }
        )
    )
}
