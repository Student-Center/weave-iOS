//
//  HomeView.swift
//  weave-ios
//
//  Created by 강동영 on 2/21/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Kingfisher
import CoreKit

struct MeetingTeamListView: View {
    
    let store: StoreOf<MeetingTeamListFeature>
    
    let column = GridItem(.fixed(UIScreen.main.bounds.size.width))
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    if !viewStore.isNetworkRequested {
                        ProgressView()
                    } else {
                        GeometryReader { geometry in
                            ScrollView {
                                // 미팅팀이 없을 때
                                if viewStore.teamList.isEmpty {
                                    getEmptyView(viewSize: geometry.size) {
                                        viewStore.send(.didTappedFilterIcon)
                                    }
                                } else {
                                    // 미팅팀 존재
                                    LazyVGrid(columns: [column], spacing: 16, content: {
                                        ForEach(viewStore.teamList, id: \.self) { team in
                                            MeetingListItemView(teamModel: team)
                                                .onTapGesture {
                                                    viewStore.send(.didTappedTeamView(id: team.id))
                                                }
                                        }
                                        if !viewStore.teamList.isEmpty && viewStore.nextCallId != nil {
                                            ProgressView()
                                                .onAppear {
                                                    viewStore.send(.requestMeetingTeamListNextPage)
                                                }
                                        }
                                    })
                                    .padding(.top, 20)
                                }
                            }
                            .refreshable {
                                viewStore.send(.requestMeetingTeamList)
                            }
                        }
                    }
                }
                .onLoad {
                    viewStore.send(.requestMeetingTeamList)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        DesignSystem.Icons.appLogo
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 20)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(
                            action: {
                                viewStore.send(.didTappedFilterIcon)
                            },
                            label: {
                                Image(systemName: "slider.horizontal.3")
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        )
                    }
                }
                .toolbar(.visible, for: .tabBar)
                .onOpenURL(perform: { url in
                    guard url.host(percentEncoded: true)?.contains("kakaolink") == true else { return }
                    
                    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                          let queryItems = components.queryItems else { return }
                    
                    let type = queryItems.first { $0.name == "type" }?.value
                    let code = queryItems.first { $0.name == "teamId" }?.value
                    
                    if type == "team",
                        let teamId = code {
                        viewStore.send(.didTappedTeamView(id: teamId))
                    }
                })
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MeetingTeamListFeature.Destination.State.teamDetail,
                    action: MeetingTeamListFeature.Destination.Action.teamDetail
                ) { store in
                    MeetingTeamDetailView(store: store)
                }
                .sheet(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MeetingTeamListFeature.Destination.State.filter,
                    action: MeetingTeamListFeature.Destination.Action.filter
                ) { store in
                    MeetingTeamListFilterView(store: store)
                        .presentationDetents([.fraction(0.8)])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
    @ViewBuilder
    func getEmptyView(viewSize: CGSize, handler: @escaping () -> Void) -> some View {
        ListEmptyGuideView(
            headerTitle: "필터를 수정해 보세요!",
            subTitle: "조건에 맞는 미팅 상대팀이 없어요...",
            buttonTitle: "필터 다시 설정하기",
            viewSize: viewSize,
            buttonHandler: handler
        )
    }
}

struct MeetingListItemView: View {
    
    let teamModel: MeetingTeamModel
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                RoundCornerBoxedTextView("\(teamModel.memberCount) : \(teamModel.memberCount)")
                RoundCornerBoxedTextView(teamModel.teamIntroduce)
                Spacer()
                LocationIconView(region: teamModel.location)
            }
            
            HStack {
                Spacer()
                ForEach(teamModel.memberInfos, id: \.self) { member in
                    userIconView(member)
                        .frame(maxWidth: .infinity)
                }
                Spacer()
            }
        }
        .padding(.all, 12)
        .background(DesignSystem.Colors.darkGray)
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .padding(.horizontal, 16)
        .frame(height: 168)
    }
    
    @ViewBuilder
    func userIconView(_ user: MeetingMemberModel) -> some View {
        VStack(spacing: 5) {
            if let mbtiType = user.mbtiType {
                KFImage(URL(string: mbtiType.mbtiProfileImage))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )
                    .frame(width: 48, height: 48)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .frame(width: 48, height: 48)
                    .foregroundStyle(DesignSystem.Colors.lightGray)
            }
            
            Text(user.userInfoString)
                .multilineTextAlignment(.center)
                .font(.pretendard(._600, size: 12))
                .padding(.vertical, 4)
        }
    }
    
    func getUserInfoString() {
        
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
