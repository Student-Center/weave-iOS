//
//  AppTabViewFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/9/24.
//

import SwiftUI
import Services
import ComposableArchitecture

struct AppTabViewFeature: Reducer {
    @Dependency(\.tabViewCoordinator) var tabViewCoordinator
    
    struct State: Equatable {
        @BindingState var isShowInvitationConfirmAlert = false
        @BindingState var isShowWelcomeAlert = false
        var invitedTeamInfo: MeetingTeamInfoModel?
        
        // Tap SubView States
        var matchedMeeting = MatchedMeetingListFeature.State()
        var requestList = RequestListFeature.State()
        var meetingTeamList = MeetingTeamListFeature.State()
        var myTeamList = MyTeamFeature.State()
        var myPage = MyPageFeature.State()
        
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        
        case fetchMyUserInfo(userInfo: MyUserInfoResponseDTO)
        
        // App Scheme Action
        case didInvitationReceived(invitationCode: String)
        case processWithInvitedTeamInfo(team: MeetingTeamInfoModel)
        case didTappedAcceptInvitation
        case didTappedCancelInvitation
        case didSuccessEnterTeam
        
        // Tap SubView Actions
        case matchedMeeting(MatchedMeetingListFeature.Action)
        case requestList(RequestListFeature.Action)
        case meetingTeamList(MeetingTeamListFeature.Action)
        case myTeamList(MyTeamFeature.Action)
        case myPage(MyPageFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                if UserInfo.myInfo == nil {
                    return .send(.myPage(.didTappedSubViews(view: .emailVerification)))
                }
                return .none
                
            case .fetchMyUserInfo(let userInfo):
                UserInfo.myInfo = userInfo.toDomain
                return .none
                
            case .didInvitationReceived(let invitationCode):
                return .run { send in
                    let response = try await requestInvitedTeamInfo(invitationCode: invitationCode)
                    var teamInfo = response.toDomain
                    teamInfo.invitationCode = invitationCode
                    await send.callAsFunction(.processWithInvitedTeamInfo(team: teamInfo))
                } catch: { error, send in
                    print(error)
                    // 에러처리 필요
                }
                
            case .processWithInvitedTeamInfo(let invitedTeam):
                state.invitedTeamInfo = invitedTeam
                state.isShowInvitationConfirmAlert = true
                return .none
                
            case .didTappedAcceptInvitation:
                guard let invitationCode = state.invitedTeamInfo?.invitationCode else { return .none }
                state.invitedTeamInfo = nil
                return .run { send in
                    try await requestAcceptInvitation(invitationCode: invitationCode)
                    await send.callAsFunction(.didSuccessEnterTeam)
                } catch: { error, send in
                    // ToDo -
                    // 팀원 초과 에러
                    // 만료된 초대장 에러 처리
                }
                
            case .didSuccessEnterTeam:
                tabViewCoordinator.changeTab(to: .myTeam)
                return .none
                
            case .didTappedCancelInvitation:
                state.invitedTeamInfo = nil
                return .none
                
            case .meetingTeamList(.pushToUnivVerifyView):
                if let userInfo = UserInfo.myInfo {
                    state.myPage.myUserInfo = userInfo
                    return .send(.myPage(.didTappedSubViews(view: .emailVerification)))
                }
                return .none
                
            case .myPage(.didTappedGoToGenerateMyTeam):
                tabViewCoordinator.changeTab(to: .myTeam)
                return .send(.myTeamList(.didTappedGenerateMyTeam))
                
            case .myTeamList(.didTappedGoToKakaoIdInputView):
                tabViewCoordinator.changeTab(to: .myPage)
                return .send(.myPage(.didTappedSubViews(view: .kakaoTalkId)))
            
            case .binding:
                return .none
                
            default:
                return .none
            }
        }
        Scope(state: \.matchedMeeting, action: /Action.matchedMeeting) {
            MatchedMeetingListFeature()
        }
        Scope(state: \State.requestList, action: /Action.requestList) {
            RequestListFeature()
        }
        Scope(state: \State.meetingTeamList, action: /Action.meetingTeamList) {
            MeetingTeamListFeature()
        }
        Scope(state: \State.myTeamList, action: /Action.myTeamList) {
            MyTeamFeature()
        }
        Scope(state: \State.myPage, action: /Action.myPage) {
            MyPageFeature()
        }

    }

    func requestInvitedTeamInfo(invitationCode: String) async throws -> MeetingTeamInfoResponseDTO {
        let endPoint = APIEndpoints.getMeetingTeamInfo(invitationCode: invitationCode)
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
    
    func requestAcceptInvitation(invitationCode: String) async throws {
        let endPoint = APIEndpoints.acceptInvitation(invitationCode)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
}
