//
//  MatchedMeetingListView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/21/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import CoreKit

struct MatchedMeetingListView: View {
    let store: StoreOf<MatchedMeetingListFeature>
    let column = GridItem(.fixed(UIScreen.main.bounds.size.width))
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack {
                    if !viewStore.isNetworkRequested {
                        ProgressView()
                    } else {
                        ScrollView {
                            if viewStore.teamList.isEmpty {
                                getEmptyView {
                                    viewStore.send(.didTappedLookAroundMeetingList)
                                }
                            } else {
                                LazyVGrid(columns: [column], spacing: 16, content: {
                                    ForEach(viewStore.teamList, id: \.id) { team in
                                        MeetingListItemView(teamModel: team.otherTeam)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                viewStore.send(.didTappedTeamView(team: team))
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
                .onLoad {
                    viewStore.send(.requestMeetingTeamList)
                }
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /MatchedMeetingListFeature.Destination.State.matchingProfile,
                    action: MatchedMeetingListFeature.Destination.Action.matchingProfile
                ) { store in
                    MeetingMatchProfileView(store: store)
                }
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("매칭")
                            .font(.pretendard(._600, size: 20))
                    }
                })
            }
        }
    }
    
    @ViewBuilder
    func getEmptyView(handler: @escaping () -> Void) -> some View {
        ListEmptyGuideView(
            headerTitle: "🙏\n미팅을 요청해 보세요!",
            subTitle: "미팅을 요청해야 매칭이 시작돼요!",
            buttonTitle: "미팅 상대 둘러보기",
            buttonHandler: handler
        )
    }
}

