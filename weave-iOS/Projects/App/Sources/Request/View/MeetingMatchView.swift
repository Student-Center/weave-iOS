//
//  MeetingMatchView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/17/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct MeetingMatchView: View {
    
    let store: StoreOf<MeetingMatchFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                VStack {
                    ScrollView {
                        VStack {
                            getTimeRemainView(second: viewStore.remainSecond)
                            MeetingMatchTeamView(
                                title: "상대 팀",
                                teamInfo: viewStore.partnerTeamModel,
                                meetingAttendanceMemberCount: viewStore.partnerAttendanceMemberCount
                                
                            )
                            .containerShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.didTappedPartnerTeam)
                            }
                            MeetingMatchTeamView(
                                title: "내 팀",
                                teamInfo: viewStore.myTeamModel
                            )
                            .containerShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.didTappedMyTeam)
                            }
                            
                            Text("""
                                모든 멤버가 참가 상태면
                                채팅방 시작과 함께 프로필이 공개돼요!
                                """
                            )
                            .multilineTextAlignment(.center)
                            .font(.pretendard(._500, size: 14))
                            .lineSpacing(3)
                            .foregroundStyle(DesignSystem.Colors.gray600)
                            .padding(.vertical, 20)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    HStack(spacing: 9) {
                        WeaveButton(
                            title: "패스",
                            style: .outline, 
                            size: .large,
                            textColor: DesignSystem.Colors.gray500,
                            backgroundColor: DesignSystem.Colors.gray500,
                            isEnabled: viewStore.isMeetingValidated
                        ) {
                            viewStore.send(.didTappedPassButton)
                        }
                        .frame(width: geometry.size.width * 0.3)
                        
                        WeaveButton(
                            title: "미팅 참가•0실",
                            size: .large,
                            textColor: .black,
                            isWeaveGraientBackground: true,
                            isEnabled: viewStore.isMeetingValidated
                        ) {
                            viewStore.send(.didTappedAttendButton)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .weaveAlert(
                    isPresented: viewStore.$isShowPassAlert,
                    title: "미팅을 패스하면\n매칭방이 사라져요...🥺",
                    message: "\(viewStore.partnerTeamModel.teamIntroduce)팀의\n미팅 요청을 패스할까요?",
                    primaryButtonTitle: "패스할래요",
                    secondaryButtonTitle: "아니요",
                    primaryAction: {
                        viewStore.send(.requestPass)
                    }
                )
                .weaveAlert(
                    isPresented: viewStore.$isShowAttendAlert,
                    title: "모튼 팀원이 참가 상태면\n채팅방이 시작돼요!",
                    message: "채팅방 시작과 함께\n모든 멤버의 프로필이 공개돼요.\n미팅에 참가할까요?",
                    primaryButtonTitle: "참가할래요",
                    secondaryButtonTitle: "아니요",
                    primaryAction: {
                        viewStore.send(.requestAttend)
                    }
                )
                .weaveAlert(
                    isPresented: viewStore.$isShowAlreadyResponseAlert,
                    title: "앗, 이미 미팅 참여 의사를 결정했어요",
                    message: "다른 인원들이 의사를 결정할 때 까지 조금만 기다려주세요!",
                    primaryButtonTitle: "네 알겠어요!"
                )
                .weaveAlert(
                    isPresented: viewStore.$isShowCompleteAttendAlert,
                    title: "미팅 참가 신청을 완료했어요",
                    message: "다른 인원들이 의사를 결정할 때 까지 조금만 기다려주세요!",
                    primaryButtonTitle: "네 알겠어요!"
                )
                .weaveAlert(
                    isPresented: viewStore.$isShowCompletePassAlert,
                    title: "미팅 요청 패스를 완료했어요",
                    message: "다른 인원들이 의사를 결정할 때 까지 조금만 기다려주세요!",
                    primaryButtonTitle: "네 알겠어요!"
                )
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MeetingMatchFeature.Destination.State.teamDetail,
                    action: MeetingMatchFeature.Destination.Action.teamDetail
                ) { store in
                    MeetingTeamDetailView(store: store)
                }
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .navigationTitle("미팅 매치")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewStore.send(.didTappedBackButton)
                        }, label: {
                            Image(systemName: "chevron.left")
                        })
                        .foregroundStyle(.white)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func getTimeRemainView(second: Int) -> some View {
        VStack(spacing: 8) {
            HStack {
                DesignSystem.Icons.stopwatch
                Text("미팅 패스까지 남은 시간")
                    .font(.pretendard(._600, size: 14))
            }
            Text(secondToTimeString(seconds: second))
                .foregroundStyle(DesignSystem.Colors.defaultBlue)
                .font(.pretendard(._700, size: 24))
            Text("시간이 다 되면 미팅이 자동으로 패스돼요!")
                .font(.pretendard(._500, size: 12))
                .foregroundStyle(DesignSystem.Colors.gray600)
        }
        .padding(.vertical, 20)
    }
    
    func secondToTimeString(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        
        // 시, 분, 초를 hh:mm:ss 형식으로 포맷팅
        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }
}

fileprivate struct MeetingMatchTeamView: View {
    let title: String
    let teamInfo: RequestMeetingTeamInfoModel
    var meetingAttendanceMemberCount: Int?
    
    var attendancedMemberCount: Int {
        if let meetingAttendanceMemberCount {
            return meetingAttendanceMemberCount
        }
        return teamInfo.memberInfos
            .filter { $0.isAttendance == true }
            .count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.pretendard(._600, size: 16))
                    .padding(.vertical, 16)
                Spacer()
            }
            
            VStack(spacing: 20) {
                HStack {
                    RoundCornerBoxedTextView(
                        teamInfo.teamIntroduce,
                        tintColor: DesignSystem.Colors.lightGray
                    )
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle")
                        Text("\(attendancedMemberCount)명")
                            .font(.pretendard(._500, size: 12))
                    }
                    .foregroundStyle(DesignSystem.Colors.subGreen)
                }
                
                HStack(alignment: .top) {
                    Spacer()
                    ForEach(teamInfo.memberInfos, id: \.id) { member in
                        let mbtiType = MBTIType(rawValue: member.mbti.uppercased())
                        let isSelf = member.userId == UserInfo.myInfo?.id
                        MemberIconView(
                            title: member.memberInfoValue,
                            subTitle: member.mbti,
                            isStroke: isSelf || member.isAttendance == true,
                            strokeColor: isSelf ? .white : DesignSystem.Colors.lightGray,
                            imageURL: mbtiType?.mbtiProfileImage,
                            overlay: {
                                if member.isAttendance == true {
                                    ZStack {
                                        Rectangle()
                                            .foregroundStyle(.black.opacity(0.4))
                                        isSelf ? DesignSystem.Icons.whiteCheck : DesignSystem.Icons.greenCheck
                                    }
                                }
                            }
                        )
                    }
                    Spacer()
                }
            }
            .weaveBoxStyle()
        }
    }
}

#Preview {
//    AppTabView(store: .init(initialState: AppTabViewFeature.State(), reducer: {
//        AppTabViewFeature(rootview: .constant(.mainView))
//    }))
    MeetingMatchView(store: Store(initialState: MeetingMatchFeature.State(meetingId: "", pendingEndAt: "2024-03-20T22:14:45.409555", meetingType: .receiving, myTeamModel: .init(id: "", teamIntroduce: "", memberCount: 2, gender: "", memberInfos: []), partnerTeamModel: .init(id: "", teamIntroduce: "", memberCount: 0, gender: "", memberInfos: [])), reducer: {
        MeetingMatchFeature()
    }))
}
