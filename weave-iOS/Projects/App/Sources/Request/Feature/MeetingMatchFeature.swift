//
//  MeetingMatchFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/17/24.
//

import Foundation
import ComposableArchitecture
import Services

struct MeetingMatchFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.mainQueue) var mainQueue
    
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
        let meetingId: String
        let pendingEndAt: String
        let meetingType: RequestListType
        @BindingState var myTeamModel: RequestMeetingTeamInfoModel
        @BindingState var partnerTeamModel: RequestMeetingTeamInfoModel
        @BindingState var partnerAttendanceMemberCount: Int = 0
        @BindingState var remainSecond: Int = 0
        @BindingState var isMeetingValidated: Bool = false
        
        @BindingState var isShowAttendAlert = false
        @BindingState var isShowPassAlert = false
        @BindingState var isShowCompleteAttendAlert = false
        @BindingState var isShowCompletePassAlert = false
        @BindingState var isShowAlreadyResponseAlert = false
    }
    
    enum Action: BindableAction {
        //MARK: UserAction
        case didTappedBackButton
        case didTappedAttendButton
        case didTappedPassButton
        case didTappedPartnerTeam
        case didTappedMyTeam
        
        case requestAttend
        case requestPass
        case completeRequest(type: MatchActionType)
        
        case onAppear
        case fetchData(dto: MeetingAttendanceResponseDTO)
        case destination(PresentationAction<Destination.Action>)
        case alreadyResponsed
        
        case startTimer
        case timerHandler
        
        // bind
        case binding(BindingAction<State>)
    }
    
    private enum CancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                
            case .didTappedBackButton:
                return .run { send in
                    await dismiss()
                }
                
            case .didTappedAttendButton:
                state.isShowAttendAlert.toggle()
                return .none
                
            case .didTappedPassButton:
                state.isShowPassAlert.toggle()
                return .none
                
            case .didTappedPartnerTeam:
                state.destination = .teamDetail(
                    .init(
                        viewType: .matchingPartner,
                        teamId: state.partnerTeamModel.id
                    )
                )
                return .none
                
            case .didTappedMyTeam:
                state.destination = .teamDetail(
                    .init(
                        viewType: .myTeam,
                        teamId: state.myTeamModel.id,
                        meetingId: state.meetingId
                    )
                )
                return .none
                
            case .requestAttend:
                return .run { [meetingId = state.meetingId] send in
                    try await requestMatchAction(teamId: meetingId, actionType: .attend)
                    await send.callAsFunction(.completeRequest(type: .attend))
                    let response = try await requestAttendanceStatus(meetingId: meetingId)
                    await send.callAsFunction(.fetchData(dto: response))
                } catch: { error, send in
                    await send.callAsFunction(.alreadyResponsed)
                }
                
            case .requestPass:
                return .run { [meetingId = state.meetingId] send in
                    try await requestMatchAction(teamId: meetingId, actionType: .pass)
                    await send.callAsFunction(.completeRequest(type: .pass))
                    let response = try await requestAttendanceStatus(meetingId: meetingId)
                    await send.callAsFunction(.fetchData(dto: response))
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
                return .run { [id = state.meetingId] send in
                    let response = try await requestAttendanceStatus(meetingId: id)
                    await send.callAsFunction(.fetchData(dto: response))
                }
                
            case .alreadyResponsed:
                state.isShowAlreadyResponseAlert.toggle()
                return .none
                
            case .destination(.dismiss):
                state.destination = nil
                return .none
                
            case .destination(.presented(.teamDetail(.completeRequest(_)))):
                state.destination = nil
                return .none
                
            case .binding(_):
                return .none
                
            case .onAppear:
                return .run { [id = state.meetingId] send in
                    await send.callAsFunction(.startTimer)
                    let response = try await requestAttendanceStatus(meetingId: id)
                    await send.callAsFunction(.fetchData(dto: response))
                } catch: { error, send in
                    print(error)
                }
                
            case .startTimer:
                guard let remainSecond = getRemainSecond(targetTime: state.pendingEndAt) else {
                    // 에러처리 필요
                    return .none
                }
                if remainSecond > 0 {
                    state.isMeetingValidated = true
                } else {
                    state.isMeetingValidated = false
                    return .none
                }
                state.remainSecond = remainSecond
                return .run { send in
                    for await _ in self.mainQueue.timer(interval: .seconds(1)) {
                        await send(.timerHandler)
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
                
            case .timerHandler:
                state.remainSecond -= 1
                
                if state.remainSecond == 0 {
                    state.isMeetingValidated = false
                    return .cancel(id: CancelID.timer)
                }
                return .none
                
            case .fetchData(let response):
                var attendancedMyTeamMemberCount = 0
                response.meetingAttendances.forEach { attendanceStatus in
                    if let index = state.myTeamModel.memberInfos.firstIndex(where: { $0.id == attendanceStatus.memberId }) {
                        state.myTeamModel.memberInfos[index].isAttendance = true
                        attendancedMyTeamMemberCount += 1
                    }
                }
                state.partnerAttendanceMemberCount = response.meetingAttendances.count - attendancedMyTeamMemberCount
                return .none
                
            default: return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    func requestAttendanceStatus(meetingId: String) async throws -> MeetingAttendanceResponseDTO {
        let endPoint = APIEndpoints.getAttendanceStatus(teamId: meetingId)
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
    
    func requestMatchAction(teamId: String, actionType: MatchActionType) async throws {
        let endPoint = APIEndpoints.getMeetingMatchAction(teamId: teamId, actionType: actionType)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint, successCode: 201)
    }
    
    func getRemainSecond(targetTime: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone.current

        guard let targetTime = dateFormatter.date(from: targetTime) else {
            print("DateFormatter 변환 실패.")
            return nil
        }

        let currentTime = Date()
        let differenceInSeconds = Calendar.current.dateComponents([.second], from: currentTime, to: targetTime).second
        
        return differenceInSeconds
    }
}

//MARK: - Destination
extension MeetingMatchFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case teamDetail(MeetingTeamDetailFeature.State)
        }
        enum Action {
            case teamDetail(MeetingTeamDetailFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.teamDetail, action: /Action.teamDetail) {
                MeetingTeamDetailFeature()
            }
        }
    }
}

enum MatchActionType {
    case attend
    case pass
    
    var requestValue: String {
        switch self {
        case .attend: return "attend"
        case .pass: return "pass"
        }
    }
}
