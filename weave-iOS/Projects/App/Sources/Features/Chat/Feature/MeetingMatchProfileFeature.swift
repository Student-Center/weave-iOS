//
//  MeetingMatchProfileFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/19/24.
//

import Foundation
import ComposableArchitecture
import Services

struct MeetingMatchProfileFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        let meetingId: String
        @BindingState var partnerTeamModel: MeetingTeamModel
        @BindingState var isProfileOpen = false
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: BindableAction {
        //MARK: UserAction
        case didTappedBackButton
        case didTappedGoToMatchingView

        case onAppear
        case didProfileTapped
        case setProfileOpen
        case requestKakaoId
        case fetchKakaoId(dto: MeetingTeamKakaoIdResponseDTO)
        case destination(PresentationAction<Destination.Action>)
        
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
                
            case .didTappedGoToMatchingView:
                return .run { send in
                    await dismiss()
                }
                
            case .destination(.dismiss):
                state.destination = nil
                return .none
                
            case .binding(_):
                return .none
                
            case .onAppear:
                return .none
                
            case .didProfileTapped:
                if state.isProfileOpen == false {
                    state.isProfileOpen.toggle()
                    return .run { send in
                        await send.callAsFunction(.requestKakaoId)
                        await send.callAsFunction(.setProfileOpen)
                    } catch: { error, send in
                        print(error)
                    }
                } else {
                    state.isProfileOpen.toggle()
                }
                return .none
                
            case .setProfileOpen:
                state.isProfileOpen = true
                return .none
                
            case .requestKakaoId:
                return .run { [meetingId = state.meetingId] send in
                    let response = try await requestKakaoId(meetingId: meetingId)
                    await send.callAsFunction(.fetchKakaoId(dto: response), animation: .easeInOut)
                }
                
            case .fetchKakaoId(let dto):
                dto.members.forEach { member in
                    if let index = state.partnerTeamModel.memberInfos.firstIndex(where: { $0.id == member.memberId }) {
                        state.partnerTeamModel.memberInfos[index].kakaoId = member.kakaoId
                    }
                }
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    func requestKakaoId(meetingId: String) async throws -> MeetingTeamKakaoIdResponseDTO {
        let endPoint = APIEndpoints.getOtherTeamKakaoId(meetingId: meetingId)
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
}

//MARK: - Destination
extension MeetingMatchProfileFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case generateMyTeam(GenerateMyTeamFeature.State)
        }
        enum Action {
            case generateMyTeam(GenerateMyTeamFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.generateMyTeam, action: /Action.generateMyTeam) {
                GenerateMyTeamFeature()
            }
        }
    }
}
