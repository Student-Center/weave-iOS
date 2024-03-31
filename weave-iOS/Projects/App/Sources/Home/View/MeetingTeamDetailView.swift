//
//  MeetingTeamDetailView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/1/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct MeetingTeamDetailView: View {
    
    let store: StoreOf<MeetingTeamDetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if let teamModel = viewStore.teamModel {
                    ScrollView {
                        VStack {
                            if viewStore.viewType != .myTeam {
                                // 케이점수
                                TeamChemistryView(score: teamModel.affinityScore)
                            }
                            // 유저
                            ForEach(teamModel.members, id: \.userId) { member in
                                let profileConfig = UserProfileBoxConfig(
                                    mbti: member.mbti,
                                    animal: member.animalType,
                                    height: member.height,
                                    profileImage: member.mbti?.mbtiProfileImage,
                                    univName: member.universityName,
                                    majorName: member.majorName,
                                    birthYear: member.birthYear,
                                    isUnivVerified: member.isUnivVerified
                                )
                                UserProfileBoxView(config: profileConfig)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    switch viewStore.viewType {
                    case .teamDetail:
                        HStack(spacing: 9) {
                            WeaveButton(
                                title: "공유",
                                style: .outline,
                                size: .large,
                                textColor: DesignSystem.Colors.gray500,
                                backgroundColor: DesignSystem.Colors.gray500
                            ) {
                                let message = KakaoShareManager.getMeetingTeamShareMessage(teamId: teamModel.id)
                                KakaoShareManager.shareMessage(with: message)
                            }
                            .frame(width: (UIScreen.main.bounds.size.width - 32) * 0.3)
                            
                            WeaveButton(
                                title: "미팅 요청•0실",
                                size: .large,
                                textColor: .black,
                                isWeaveGraientBackground: true
                            ) {
                                viewStore.send(.didTappedRequestMeetingButton)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .weaveAlert(
                            isPresented: viewStore.$isShowNoTeamAlert,
                            title: "아직 내 팀이 없어요!",
                            message: """
                                공개된 내 팀이 있어야
                                미팅을 요청할 수 있어요.
                                지금 바로 팀을 만들러 가볼까요?
                                """,
                            primaryButtonTitle: "네, 좋아요",
                            secondaryButtonTitle: "아니요",
                            primaryAction: {
                                viewStore.send(.makeTeamAction)
                            }
                        )
                        .weaveAlert(
                            isPresented: viewStore.$isShowNeedUnivVerifyAlert,
                            title: "대학교 인증이 필요해요",
                            message: """
                                학교 메일을 인증한 회원만
                                미팅 요청이 가능해요.
                                바로 인증하러 가볼까요?
                                """,
                            primaryButtonTitle: "네, 좋아요",
                            secondaryButtonTitle: "아니요",
                            primaryAction: {
                                viewStore.send(.univVerifyAction)
                            }
                        )
                        .weaveAlert(
                            isPresented: viewStore.$isShowRequestMeetingConfirmAlert,
                            title: "📤\n미팅 요청하기",
                            message: "\(teamModel.teamIntroduce) 팀에게\n미팅을 요청할까요?",
                            primaryButtonTitle: "요청할래요",
                            secondaryButtonTitle: "아니요",
                            primaryAction: {
                                viewStore.send(.requestMeeting)
                            }
                        )
                        .weaveAlert(
                            isPresented: viewStore.$isShowRequestSuccessAlert,
                            title: "요청 성공",
                            message: "\(teamModel.teamIntroduce) 팀에게\n미팅 요청을 성공했어요.",
                            primaryButtonTitle: "확인",
                            primaryAction: {
                                viewStore.send(.requestMeeting)
                            }
                        )
                        
                    case .matchingPartner:
                        HStack(spacing: 9) {
                            WeaveButton(
                                title: "패스",
                                style: .outline,
                                size: .large,
                                textColor: DesignSystem.Colors.gray500,
                                backgroundColor: DesignSystem.Colors.gray500
                            ) {
                                viewStore.send(.didTappedPassButton)
                            }
                            .frame(width: (UIScreen.main.bounds.size.width - 32) * 0.3)
                            
                            WeaveButton(
                                title: "미팅 참가•0실",
                                size: .large,
                                textColor: .black,
                                isWeaveGraientBackground: true
                            ) {
                                viewStore.send(.didTappedAttendButton)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .weaveAlert(
                            isPresented: viewStore.$isShowPassAlert,
                            title: "미팅을 패스하면\n매칭방이 사라져요...🥺",
                            message: "\(viewStore.teamModel?.teamIntroduce ?? "상대")팀의\n미팅 요청을 패스할까요?",
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
                    case .myTeam:
                        EmptyView()
                    }
                }
            }
            .onAppear {
                viewStore.send(.requestTeamUserInfo)
            }
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewStore.send(.dismiss)
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("\(viewStore.teamModel?.teamIntroduce ?? "")")
                                .font(.pretendard(._600, size: 16))
                        }
                    })
                    .foregroundStyle(.white)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    LocationIconView(region: "서울", tintColor: .white)
                }
            }
        }
    }
}

struct TeamChemistryView: View {
    let score: Int?
    
    var body: some View {
        VStack(spacing: 10) {
            if let score {
                Text("이런게 환상의 케미?")
                    .font(.pretendard(._700, size: 20))
                    .foregroundStyle(DesignSystem.Colors.defaultBlue)
                
                StarRatingView(rating: Double(score))
                
                Text("우리 팀과의 케미는 \(20 * score)점")
                    .font(.pretendard(._500, size: 12))
                    .foregroundStyle(DesignSystem.Colors.gray500)
            } else {
                Text("케미 정보가 없습니다")
                    .font(.pretendard(._700, size: 20))
            }
        }
    }
}

#Preview {
    MeetingTeamDetailView(store: Store(initialState: MeetingTeamDetailFeature.State(teamId: ""), reducer: {
        MeetingTeamDetailFeature()
    }))
}
