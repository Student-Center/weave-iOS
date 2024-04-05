//
//  MeetingTeamListFilterView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/3/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct MeetingTeamListFilterView: View {
    let store: StoreOf<MeetingTeamListFilterFeature>
    
    @State var locationFilterType: (any LeftAlignListFetchable)?
    @State var selectedLocation: (any LeftAlignListFetchable)?
    @State var selectedMeetingCount: (any LeftAlignListFetchable)?
    
    var listViewWidth: CGFloat {
        return UIScreen.main.bounds.width - 36
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                CenterTitleView(title: "필터 설정") {
                    viewStore.send(.dismiss)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("내가 찾는 미팅")
                            .font(.pretendard(._500, size: 16))
                            .padding(.vertical, 16)
                        
                        HStack {
                            LeftAlignTextCapsuleListView(
                                selectedItem: $selectedMeetingCount,
                                dataSources: MeetingMemberCountType.allCases,
                                viewWidth: listViewWidth
                            )
                            Spacer()
                        }
                        
                        getSectionDivider()
                            .padding(.vertical, 16)
                        
                        HStack {
                            Text("미팅 상대 나이대")
                                .font(.pretendard(._500, size: 16))
                            Spacer()
                            Text(
                                "\(String(String(viewStore.selectedLowYear).suffix(2)))년생 ~ \(String(String(viewStore.selectedHighYear).suffix(2)))년생"
                            )
                                .font(.pretendard(._500, size: 16))
                                .foregroundStyle(DesignSystem.Colors.defaultBlue)
                        }
                        .padding(.vertical, 16)
                        
                        RangeSlider(
                            lowValue: viewStore.$lowValue,
                            highValue: viewStore.$highValue,
                            in: 0...1,
                            showDifferenceOnEditing: false)
                        { state in }
                        .padding(.horizontal, 5)
                        .onChange(of: viewStore.lowValue) { oldValue, newValue in
                            viewStore.send(.sliderLowValueChanged(value: newValue))
                        }
                        .onChange(of: viewStore.highValue) { oldValue, newValue in
                            viewStore.send(.sliderHighValueChanged(value: newValue))
                        }
                        
                        getSectionDivider()
                            .padding(.vertical, 16)
                        
                        Text("선호 미팅 지역")
                            .font(.pretendard(._500, size: 16))
                            .padding(.vertical, 16)
                        
                        LeftAlignTextCapsuleListView(
                            selectedItem: $locationFilterType,
                            dataSources: MeetingLocationFilterType.allCases,
                            viewWidth: listViewWidth
                        )
                        
                        LeftAlignTextCapsuleListView(
                            selectedItem: $selectedLocation,
                            dataSources: filterData(list: viewStore.locationList, filterType: locationFilterType),
                            viewWidth: listViewWidth
                        )
                        .frame(maxHeight: .infinity)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.vertical, 20)
                    
                }
                .padding(.horizontal, 16)
                .scrollIndicators(.hidden)
                
                WeaveButton(
                    title: "저장하기",
                    size: .large
                ) {
                    let countType = selectedMeetingCount as? MeetingMemberCountType
                    let region = selectedLocation as? MeetingLocationModel
                    let input = MeetingTeamListFilterFeature.FilterInputs(
                        count: countType,
                        regions: region
                    )
                    viewStore.send(.didTappedSaveButton(input: input))
                }
                .padding(.horizontal, 16)
            }
            .background(DesignSystem.Colors.darkGray)
            .onAppear {
                viewStore.send(.requestMeetingLocationList)
                // 인원수
                if let selectedCount = viewStore.filterModel.memberCount {
                    selectedMeetingCount = MeetingMemberCountType(rawValue: selectedCount)
                }
            }
            .onChange(of: viewStore.isLocationFetched) { oldValue, newValue in
                // Location 정보를 받았을 때
                // 이미 필터에 가지고 있던 Location 정보가 있을 때
                if let locations = viewStore.filterModel.preferredLocations {
                    if let matchedIndex = viewStore.locationList.firstIndex(where: { $0.name == locations.first }) {
                        let matchedModel = viewStore.locationList[matchedIndex]
                        if matchedModel.isCapitalArea {
                            self.locationFilterType = MeetingLocationFilterType.capital
                        } else {
                            self.locationFilterType = MeetingLocationFilterType.nonCapital
                        }
                        self.selectedLocation = matchedModel
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func getSectionDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(DesignSystem.Colors.lightGray)
    }
    
    func filterData(
        list: [MeetingLocationModel],
        filterType: (any LeftAlignListFetchable)?
    ) -> [any LeftAlignListFetchable] {
        guard let filterType,
              let type = filterType as? MeetingLocationFilterType else { return [] }
        switch type {
        case .capital:
            return list.filter { $0.isCapitalArea == true }
        case .nonCapital:
            return list.filter { $0.isCapitalArea == false }
        }
    }
}

#Preview {
    MeetingTeamListFilterView(store: Store(initialState: MeetingTeamListFilterFeature.State(), reducer: {
        MeetingTeamListFilterFeature()
    }))
}
