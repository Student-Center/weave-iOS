//
//  MeetingTeamListFilterFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/3/24.
//

import Foundation
import Services
import ComposableArchitecture

struct MeetingTeamListFilterFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct FilterInputs {
        let count: MeetingMemberCountType?
        let regions: MeetingLocationModel?
    }
    
    struct State: Equatable {
        @BindingState var locationList: [MeetingLocationModel]
        
        // 나이대 슬라이더
        let lowYear = 1996
        let highYear = 2006
        @BindingState var lowValue = 0.0
        @BindingState var highValue = 1.0
        @BindingState var selectedLowYear: Int
        @BindingState var selectedHighYear: Int
        
        @BindingState var filterModel: MeetingTeamFilterModel
        
        @BindingState var isLocationFetched = false
        
        init(
            filterModel: MeetingTeamFilterModel = MeetingTeamFilterModel()
        ) {
            self.locationList = []
            self.filterModel = filterModel
            self.selectedLowYear = filterModel.oldestMemberBirthYear
            self.selectedHighYear = filterModel.youngestMemberBirthYear
        }
    }
    
    enum Action: BindableAction {
        //MARK: UserAction
        case requestMeetingLocationList
        case fetchMeetingLocationList(list: MeetingLocationListResponseDTO)
        case didTappedSaveButton(input: FilterInputs)
        
        // range
        case setRangeData
        case sliderLowValueChanged(value: Double)
        case sliderHighValueChanged(value: Double)
        
        case dismissSaveFilter
        //MARK: Alert Effect
        
        case dismiss
        // bind
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .requestMeetingLocationList:
                return .run { send in
                    let locationList = try await requestDetailTeamInfo()
                    await send.callAsFunction(.fetchMeetingLocationList(list: locationList))
                    await send.callAsFunction(.setRangeData)
                }
                
            case .fetchMeetingLocationList(let list):
                state.locationList = list.toDomain
                state.isLocationFetched = true
                return .none
                
            case .didTappedSaveButton(let input):
                var filter = state.filterModel
                filter.memberCount = input.count?.countValue
                if let region = input.regions {
                    filter.preferredLocations = [region.name]
                }
                filter.oldestMemberBirthYear = state.selectedLowYear
                filter.youngestMemberBirthYear = state.selectedHighYear
                state.filterModel = filter
                return .send(.dismissSaveFilter)
                
            case .dismissSaveFilter:
                return .run { send in
                    await dismiss()
                }
                
            case .setRangeData:
                if let lowYearValue = yearToRangeValue(
                    lowYear: state.lowYear,
                    highYear: state.highYear,
                    year: state.filterModel.oldestMemberBirthYear
                ) {
                    state.lowValue = lowYearValue
                }
                
                if let highYearValue = yearToRangeValue(
                    lowYear: state.lowYear,
                    highYear: state.highYear,
                    year: state.filterModel.youngestMemberBirthYear
                ) {
                    state.highValue = highYearValue
                }
                return .none
                
            case .sliderLowValueChanged(let value):
                let lowYear = rangeValueToYear(
                    lowYear: state.lowYear,
                    highYear: state.highYear,
                    input: value
                )
                state.selectedLowYear = lowYear
                return .none
                
            case .sliderHighValueChanged(let value):
                let highYear = rangeValueToYear(
                    lowYear: state.lowYear,
                    highYear: state.highYear,
                    input: value
                )
                state.selectedHighYear = highYear
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
    
    func rangeValueToYear(lowYear: Int, highYear: Int, input: Double) -> Int {
        let minYear = lowYear
        let maxYear = highYear
        let range = maxYear - minYear
        let transformed = (input * Double(range)) + Double(minYear)
        let year = Int(round(transformed))
        return year
    }
    
    func yearToRangeValue(lowYear: Int, highYear: Int, year: Int) -> Double? {
        let minYear = lowYear
        let maxYear = highYear
        let range = maxYear - minYear
        
        guard year >= minYear && year <= maxYear else {
            return nil
        }
        
        let normalizedYear = Double(year - minYear) / Double(range)
        return normalizedYear
    }

    func requestDetailTeamInfo() async throws -> MeetingLocationListResponseDTO {
        let endPoint = APIEndpoints.getMeetingLocationList()
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
}
