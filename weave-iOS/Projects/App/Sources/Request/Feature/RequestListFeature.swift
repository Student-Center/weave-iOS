//
//  RequestListFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/15/24.
//

import Foundation
import ComposableArchitecture
import Services

struct RequestListFeature: Reducer {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
        
        @BindingState var receivedDataSources: [RequestMeetingItemModel] = []
        var receiveDataNextCallId: String?
        var isReceiveDataRequested = false
        @BindingState var sentDataSources: [RequestMeetingItemModel] = []
        var sentDataNextCallId: String?
        var isSentDataRequested = false
    }
    
    enum Action: BindableAction {
        //MARK: UserAction
        case didTappedMeetingView(index: Int, type: RequestListType)
        case onAppear(type: RequestListType)
        
        case requestList(type: RequestListType)
        case requestNextPage(type: RequestListType)
        case processRequestError(type: RequestListType)
        
        case fetchData(dto: RequestMeetingListResponseDTO, type: RequestListType)
        case destination(PresentationAction<Destination.Action>)
        // bind
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .didTappedMeetingView(let index, let type):
                switch type {
                case .receiving:
                    let meeting = state.receivedDataSources[index]
                    let myTeam = meeting.receivingTeam
                    let partnerTeam = meeting.requestingTeam
                    state.destination = .meetingMatch(
                        .init(
                            meetingId: meeting.id,
                            pendingEndAt: meeting.pendingEndAt,
                            meetingType: type,
                            myTeamModel: myTeam,
                            partnerTeamModel: partnerTeam
                        )
                    )
                case .requesting:
                    let meeting = state.sentDataSources[index]
                    let partnerTeam = meeting.receivingTeam
                    let myTeam = meeting.requestingTeam
                    state.destination = .meetingMatch(
                        .init(
                            meetingId: meeting.id,
                            pendingEndAt: meeting.pendingEndAt,
                            meetingType: type,
                            myTeamModel: myTeam,
                            partnerTeamModel: partnerTeam
                        )
                    )
                }
                return .none
                
            case .processRequestError(let type):
                switch type {
                case .receiving:
                    state.isReceiveDataRequested = true
                case .requesting:
                    state.isSentDataRequested = true
                }
                return .none
                
            case .destination(.dismiss):
                state.destination = nil
                return .none

            case .binding(_):
                return .none
                
            case .onAppear(let type):
                return .run { send in
                    await send.callAsFunction(.requestList(type: type))
                }
                
            case .requestList(let type):
                switch type {
                case .receiving:
                    state.receiveDataNextCallId = nil
                    state.isReceiveDataRequested = false
                    state.receivedDataSources = []
                case .requesting:
                    state.sentDataNextCallId = nil
                    state.isSentDataRequested = false
                    state.sentDataSources = []
                }
                return .run { send in
                    let response = try await requestMeetingList(type: type)
                    await send.callAsFunction(.fetchData(dto: response, type: type))
                } catch: { error, send in
                    await send.callAsFunction(.processRequestError(type: type))
                }
                
            case .requestNextPage(let type):
                return .run { [nextReceivedId = state.receiveDataNextCallId, nextSentId = state.sentDataNextCallId] send in
                    let nextId = type == .receiving ? nextReceivedId : nextSentId
                    let response = try await requestMeetingList(type: type, nextId: nextId)
                    await send.callAsFunction(.fetchData(dto: response, type: type))
                } catch: { error, send in
                    print(error)
                }
                
            case .fetchData(let response, let type):
                switch type {
                case .receiving:
                    let data = response.toDomain.items
                    state.isReceiveDataRequested = true
                    state.receivedDataSources.append(contentsOf: data)
                case .requesting:
                    let data = response.toDomain.items
                    state.isSentDataRequested = true
                    state.sentDataSources.append(contentsOf: data)
                }
                return .none
                
            default: return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    func requestMeetingList(type: RequestListType, nextId: String? = nil) async throws -> RequestMeetingListResponseDTO {
        let requestDTO = RequestMeetingListRequestDTO(teamType: type, next: nextId)
        let endPoint = APIEndpoints.getRequestMeetingTeamList(request: requestDTO)
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
}

//MARK: - Destination
extension RequestListFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case meetingMatch(MeetingMatchFeature.State)
        }
        enum Action {
            case meetingMatch(MeetingMatchFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.meetingMatch, action: /Action.meetingMatch) {
                MeetingMatchFeature()
            }
        }
    }
}

