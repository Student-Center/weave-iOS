//
//  MeetingTeamDetailFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/2/24.
//

import Foundation
import Services
import ComposableArchitecture

struct MeetingTeamDetailFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        var viewType: ViewType = .teamDetail
        
        let teamId: String
        @BindingState var teamModel: MeetingTeamDetailModel?
        @BindingState var isShowRequestMeetingConfirmAlert = false
        @BindingState var isShowNoTeamAlert = false
        @BindingState var isShowRequestSuccessAlert = false
        
        var meetingId: String?
        @BindingState var isShowAttendAlert = false
        @BindingState var isShowNeedUnivVerifyAlert = false
        @BindingState var isShowPassAlert = false
        @BindingState var isShowCompleteAttendAlert = false
        @BindingState var isShowCompletePassAlert = false
        @BindingState var isShowAlreadyResponseAlert = false
    }
    
    enum Action: BindableAction {
        //MARK: UserAction
        case didTappedBackButton
        case didTappedShareButton
        case didTappedRequestMeetingButton
        
        // 매치 뷰에서 접근한 경우
        case didTappedAttendButton
        case didTappedPassButton
        case requestAttend
        case requestPass
        case completeRequest(type: MatchActionType)
        case alreadyResponsed
        
        //MARK: Alert Effect
        case makeTeamAction
        case needUnivVerify
        case univVerifyAction
        case requestMeeting
        case successedRequestMeeting
        
        case dismiss
        
        case requestTeamUserInfo
        case fetchTeamUserInfo(response: MeetingTeamDetailResponseDTO)
        
        // bind
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didTappedRequestMeetingButton:
                state.isShowRequestMeetingConfirmAlert.toggle()
                return .none
            case .requestTeamUserInfo:
                return .run { [teamId = state.teamId] send in
                    let response = try await requestDetailTeamInfo(teamId: teamId)
                    await send.callAsFunction(.fetchTeamUserInfo(response: response))
                } catch: { error, send in
                    print(error)
                }
            case .fetchTeamUserInfo(let response):
                state.teamModel = response.toDomain
                return .none
                
            // 미팅 요청
            case .requestMeeting:
                guard UserInfo.myInfo?.isUniversityEmailVerified == true else {
                    return .run { send in
                        await send.callAsFunction(.needUnivVerify)
                    }
                }
                return .run { [teamId = state.teamId] send in
                    try await requestMeeting(targetTeamId: teamId)
                    await send.callAsFunction(.successedRequestMeeting)
                } catch: { error, send in
                    print(error)
                }
                
            case .needUnivVerify:
                state.isShowNeedUnivVerifyAlert.toggle()
                return .none
                
            case .univVerifyAction:
                print("대학교 인증으로")
                return .none
                
            case .successedRequestMeeting:
                state.isShowRequestSuccessAlert.toggle()
                return .none
                
            // 미팅 참가
            case .didTappedAttendButton:
                state.isShowAttendAlert.toggle()
                return .none
                
            case .didTappedPassButton:
                state.isShowPassAlert.toggle()
                return .none
                
            case .requestAttend:
                guard let meetingId = state.meetingId else { return .none }
                return .run { send in
                    try await requestMatchAction(teamId: meetingId, actionType: .attend)
                    await send.callAsFunction(.requestPass)
                } catch: { error, send in
                    await send.callAsFunction(.alreadyResponsed)
                }
                
            case .requestPass:
                guard let meetingId = state.meetingId else { return .none }
                return .run { send in
                    try await requestMatchAction(teamId: meetingId, actionType: .pass)
                    await send.callAsFunction(.requestPass)
                } catch: { error, send in
                    await send.callAsFunction(.alreadyResponsed)
                }
                
            case .completeRequest(let type):
                switch type {
                case .attend:
                    state.isShowCompleteAttendAlert.toggle()
                case .pass:
                    state.isShowCompletePassAlert.toggle()
                }
                return .none
                
            case .dismiss:
                return .run { send in
                    await dismiss()
                }
            default:
                return .none
            }
        }
    }
    
    func requestDetailTeamInfo(teamId: String) async throws -> MeetingTeamDetailResponseDTO {
        let endPoint = APIEndpoints.getMeetingTeamDetail(teamId: teamId)
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
    
    func requestMeeting(targetTeamId: String) async throws {
        let requestDTO = RequestMeetingRequestDTO(receivingMeetingTeamId: targetTeamId)
        let endPoint = APIEndpoints.getRequestMeeting(requestDTO: requestDTO)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint, successCode: 201)
    }
    
    func requestMatchAction(teamId: String, actionType: MatchActionType) async throws {
        let endPoint = APIEndpoints.getMeetingMatchAction(teamId: teamId, actionType: actionType)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint, successCode: 201)
    }
}

extension MeetingTeamDetailFeature {
    enum ViewType {
        case teamDetail
        case matchingPartner
        case myTeam
    }
}
