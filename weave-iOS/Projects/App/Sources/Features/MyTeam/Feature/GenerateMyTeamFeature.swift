//
//  GenerateMyTeamFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/6/24.
//

import Foundation
import Services
import ComposableArchitecture

struct GenerateMyTeamFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct InputModel {
        let count: MeetingMemberCountType?
        let regions: MeetingLocationModel?
    }
    
    struct State: Equatable {
        @BindingState var locationList: [MeetingLocationModel]
        
        @BindingState var teamName: String = ""
        @BindingState var isTeamNameError = false
        
        @BindingState var isShowNetworkErrorAlert = false
        
        var myTeamModelFromEdit: MyTeamItemModel?
        var currentTeamMemberCount: Int?
        
        init(
            locationList: [MeetingLocationModel] = [],
            myTeamModelFromEdit: MyTeamItemModel? = nil
        ) {
            self.locationList = locationList
            self.myTeamModelFromEdit = myTeamModelFromEdit
            self.currentTeamMemberCount = myTeamModelFromEdit?.memberInfos.count
        }
    }
    
    enum Action: BindableAction {
        case onAppear
        case requestMeetingLocationList
        case fetchMeetingLocationList(list: MeetingLocationListResponseDTO)
        case fetchTeamName(name: String)
        
        case didTappedGenerateButton(input: InputModel)
        case didTappedBackButton
        
        case didSuccessedGenerateTeam
        
        case teamNameOnChanged(name: String)
        // bind
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let editModel = state.myTeamModelFromEdit {
                    
                }
                return .send(.requestMeetingLocationList)
                
            case .requestMeetingLocationList:
                return .run { send in
                    let locationList = try await requestMeetingLocationList()
                    await send.callAsFunction(.fetchMeetingLocationList(list: locationList))
                }
                
            case .fetchTeamName(let name):
                state.teamName = name
                return .none
                
            case .fetchMeetingLocationList(let list):
                state.locationList = list.toDomain
                return .none
                
            case .teamNameOnChanged(let name):
                state.isTeamNameError = name.count > 10
                return .none
                
            case .didTappedBackButton:
                return .run { send in
                    await dismiss()
                }
                
            case .didTappedGenerateButton(let input):
                guard let count = input.count,
                      let location = input.regions else { return .none }
                let requestDTO = GenerateMeetingTeamRequestDTO(
                    teamIntroduce: state.teamName,
                    memberCount: count.countValue,
                    location: location.name
                )
                let isModify = state.myTeamModelFromEdit != nil
                
                return .run { [model = state.myTeamModelFromEdit] send in
                    try await requestGenerateMeetingTeam(
                        requestDTO: requestDTO, 
                        modifyId: model?.id,
                        isModify: isModify
                    )
                    await send.callAsFunction(.didSuccessedGenerateTeam)
                } catch: { error, send in
                    print(error)
                }
                
            case .didSuccessedGenerateTeam:
                return .run { send in
                    await dismiss()
                }
                
            case .binding(_):
                return .none
                
            }
        }
    }
    
    func requestMeetingLocationList() async throws -> MeetingLocationListResponseDTO {
        let endPoint = APIEndpoints.getMeetingLocationList()
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
    
    func requestGenerateMeetingTeam(
        requestDTO: GenerateMeetingTeamRequestDTO,
        modifyId: String? = nil,
        isModify: Bool
    ) async throws {
        let endPoint = APIEndpoints.getGenerateMeetingTeam(requestDTO: requestDTO, modifyId: modifyId, isModify: isModify)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint, successCode: isModify ? 204 : 201)
    }
}
