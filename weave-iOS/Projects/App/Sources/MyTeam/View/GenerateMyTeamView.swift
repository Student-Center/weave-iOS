//
//  GenerateMyTeamView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/6/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

struct GenerateMyTeamView: View {
    
    let store: StoreOf<GenerateMyTeamFeature>
    
    var capsuleViewWidth: CGFloat {
        UIScreen.main.bounds.width - 32
    }
    
    var locationValidation: Bool {
        return [
            selectedMeetingCount, 
            locationFilterType,
            selectedLocation
        ].allSatisfy { $0 != nil }
    }
    
    // User Selected
    @State var selectedMeetingCount: (any LeftAlignListFetchable)?
    @State var locationFilterType: (any LeftAlignListFetchable)?
    @State var selectedLocation: (any LeftAlignListFetchable)?
    
    @State var isTapEnable = true
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                ScrollView {
                    VStack {
                        SectionHeaderView(title: "내가 하고 싶은 미팅은?")
                        HStack {
                            LeftAlignTextCapsuleListView(
                                selectedItem: $selectedMeetingCount,
                                dataSources: MeetingMemberCountType.allCases,
                                viewWidth: capsuleViewWidth,
                                backgroundColor: DesignSystem.Colors.darkGray,
                                isTapEnable: isTapEnable
                            )
                            .padding(.horizontal, -5)
                            Spacer()
                        }
                        
                        if !isTapEnable {
                            HStack {
                                Text("팀이 다 찼을 때는 수정할 수 없어요!")
                                    .font(.pretendard(._500, size: 12))
                                    .foregroundStyle(DesignSystem.Colors.notificationRed)
                                Spacer()
                            }
                        }
                        
                        Divider()
                        
                        if selectedMeetingCount != nil {
                            MeetingLocationSelectionView(
                                store: store,
                                capsuleViewWidth: capsuleViewWidth,
                                locationFilterType: $locationFilterType,
                                selectedLocation: $selectedLocation
                            )
                        }
                        
                        if selectedLocation != nil {
                            TeamNameInputView(store: store)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .scrollDismissesKeyboard(.interactively)
              
                WeaveButton(
                    title: "내 팀 만들기",
                    size: .large,
                    isEnabled: locationValidation && !viewStore.isTeamNameError
                ) {
                    let countType = selectedMeetingCount as? MeetingMemberCountType
                    let region = selectedLocation as? MeetingLocationModel
                    let input = GenerateMyTeamFeature.InputModel(
                        count: countType,
                        regions: region
                    )
                    viewStore.send(.didTappedGenerateButton(input: input))
                }
                .padding(.horizontal, 16)
            }
            .onChange(of: viewStore.locationList, { oldValue, newValue in
                // Network Request가 되었을 때, 수정으로 넘어온 데이터가 있다면 자동 선택되도록 함
                if let editModel = viewStore.myTeamModelFromEdit {
                    viewStore.send(.fetchTeamName(name: editModel.teamIntroduce))
                    self.selectedMeetingCount = editModel.memberCount
                    if let matchedLocation = viewStore.locationList.first(where: { model in
                        return model.displayName == editModel.location
                    }) {
                        self.locationFilterType = matchedLocation.isCapitalArea ? MeetingLocationFilterType.capital : MeetingLocationFilterType.nonCapital
                        self.selectedLocation = matchedLocation
                        if editModel.memberInfos.count > 1 {
                            self.isTapEnable = false
                        }
                    }
                }
            })
            .onAppear {
                viewStore.send(.onAppear)
            }
            .weaveNetworkErrorAlert(isPresented: viewStore.$isShowNetworkErrorAlert)
            .navigationBarBackButtonHidden()
            .navigationTitle("내 팀 만들기")
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

fileprivate struct SectionHeaderView: View {
    let title: String
    
    fileprivate var body: some View {
        HStack {
            Text(title)
                .font(.pretendard(._500, size: 16))
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

fileprivate struct MeetingLocationSelectionView: View {
    let store: StoreOf<GenerateMyTeamFeature>
    let capsuleViewWidth: CGFloat
    
    @Binding var locationFilterType: (any LeftAlignListFetchable)?
    @Binding var selectedLocation: (any LeftAlignListFetchable)?
    
    fileprivate var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                SectionHeaderView(title: "내가 선호하는 미팅 지역은?")
                HStack {
                    LeftAlignTextCapsuleListView(
                        selectedItem: $locationFilterType,
                        dataSources: MeetingLocationFilterType.allCases,
                        viewWidth: capsuleViewWidth,
                        backgroundColor: DesignSystem.Colors.darkGray
                    )
                    .padding(.horizontal, -5)
                    Spacer()
                }
                
                let dataSources = filterData(
                    list: viewStore.locationList,
                    filterType: locationFilterType
                )
                
                LeftAlignTextCapsuleListView(
                    selectedItem: $selectedLocation,
                    dataSources: dataSources,
                    viewWidth: capsuleViewWidth,
                    backgroundColor: DesignSystem.Colors.darkGray
                )
                .padding(.horizontal, -5)
                
                if !dataSources.isEmpty {
                    Text("지역은 1개만 선택할 수 있어요!")
                        .font(.pretendard(._500, size: 12))
                        .foregroundStyle(DesignSystem.Colors.gray400)
                }
                
                Divider()
            }
        }
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

fileprivate struct TeamNameInputView: View {
    let store: StoreOf<GenerateMyTeamFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                SectionHeaderView(title: "내 팀을 한 줄로 소개한다면?")
                WeaveTextField(
                    text: viewStore.$teamName,
                    placeholder: "ex. 위브 멋쨍이들",
                    showClearButton: true
                )
                .onChange(of: viewStore.teamName) { oldValue, newValue in
                    viewStore.send(.teamNameOnChanged(name: newValue))
                }
                
                Text("10글자 이내로 작성해 주세요!")
                    .font(.pretendard(._500, size: 12))
                    .foregroundStyle(viewStore.isTeamNameError ? DesignSystem.Colors.notificationRed : DesignSystem.Colors.gray600)
                    .padding(.vertical, 5)
            }
        }
    }
}

#Preview {
    AppTabView(
        store: Store(
            initialState: AppTabViewFeature.State(),
            reducer: {
                AppTabViewFeature()
            }
        )
    )
}
