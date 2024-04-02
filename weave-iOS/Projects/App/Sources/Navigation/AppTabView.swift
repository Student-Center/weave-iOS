//
//  AppTabView.swift
//  weave-ios
//
//  Created by 강동영 on 2/21/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import Services

struct AppTabView: View {
    var store: StoreOf<AppTabViewFeature>
    @State var tabViewCoordinator = TabViewCoordinator.shared
    @State private var networkErrorManager = ServiceErrorManager.shared
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            TabView(selection: $tabViewCoordinator.currentTab) {
                
                MatchedMeetingListView(
                    store: store.scope(
                        state: \.matchedMeeting,
                        action: { .matchedMeeting($0) }
                    )
                )
                .tag(AppScreen.chat)
                .tabItem {
                    Label {
                        Text("매칭")
                    } icon: {
                        DesignSystem.Icons.chat
                    }
                }
                
                
                RequestListView(
                    store: store.scope(
                        state: \.requestList,
                        action: { .requestList($0) }
                    )
                )
                .tag(AppScreen.request)
                .tabItem {
                    Label {
                        Text("요청")
                    } icon: {
                        DesignSystem.Icons.request
                    }
                }
                
                MeetingTeamListView(
                    store: store.scope(
                        state: \.meetingTeamList,
                        action: { .meetingTeamList($0) }
                    )
                )
                .tag(AppScreen.home)
                .tabItem {
                    Label {
                        Text("홈")
                    } icon: {
                        DesignSystem.Icons.home
                    }
                }
                
                MyTeamView(
                    store: store.scope(
                        state: \.myTeamList,
                        action: { .myTeamList($0) }
                    )
                )
                .tag(AppScreen.myTeam)
                .tabItem {
                    Label {
                        Text("내 팀")
                    } icon: {
                        DesignSystem.Icons.myTeam
                    }
                }
                
                MyPageView(
                    store: store.scope(
                        state: \.myPage,
                        action: { .myPage($0) }
                    )
                )
                .tag(AppScreen.myPage)
                .tabItem {
                    Label("마이", systemImage: "person.crop.circle")
                }
            }
            .tint(.white)
            .onLoad {
                viewStore.send(.onAppear)
            }
            .onOpenURL { url in
                guard url.host(percentEncoded: true)?.contains("kakaolink") == true else { return }
                
                guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                      let queryItems = components.queryItems else { return }
                
                let type = queryItems.first { $0.name == "type" }?.value
                let code = queryItems.first { $0.name == "code" }?.value
                
                if type == "invitation", 
                    let invitationCode = code {
                    viewStore.send(.didInvitationReceived(invitationCode: invitationCode))
                }
            }
            .weaveAlert(
                isPresented: viewStore.$isShowInvitationConfirmAlert,
                title: "✉️\n팀 초대장 도착!",
                message: "\(viewStore.invitedTeamInfo?.teamIntroduce ?? "") 팀의 초대를 수락할까요?",
                primaryButtonTitle: "수락할께요",
                secondaryButtonTitle: "나중에",
                primaryAction: {
                    viewStore.send(.didTappedAcceptInvitation)
                },
                secondaryAction: {
                    viewStore.send(.didTappedCancelInvitation)
                }
            )
            .weaveErrorMessage(
                isPresented: $networkErrorManager.needShowErrorAlert,
                message: networkErrorManager.errorMessage
            ) {
                networkErrorManager.handleAlertConfirmAction()
            }
        }
    }
}
