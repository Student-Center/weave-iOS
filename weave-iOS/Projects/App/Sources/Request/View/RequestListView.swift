//
//  RequestListView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/11/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import CoreKit
import Kingfisher

struct RequestListView: View {
    @State var selection: Int = 0
    private let items: [String] = ["받은 요청", "보낸 요청"]
    let store: StoreOf<RequestListFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                SegmentedPicker(items: self.items, selection: self.$selection)
                    .frame(width: 210)
                TabView(selection: $selection) {
                    VStack {
                        if !viewStore.isReceiveDataRequested {
                            ProgressView()
                        } else if viewStore.isReceiveDataRequested && viewStore.sentDataSources.isEmpty {
                            getEmptyView() {
                                viewStore.send(.didTappedLookAroundMeetingList)
                            }
                        } else {
                            getMeetingListView(
                                type: .receiving,
                                dataSources: viewStore.sentDataSources,
                                needShowNextPage: viewStore.receiveDataNextCallId != nil,
                                tapHandler: { index in
                                    guard let type = RequestListType(rawValue: selection) else { return }
                                    viewStore.send(.didTappedMeetingView(index: index, type: type))
                                },
                                nextPageHandler: { type in
                                    viewStore.send(.requestNextPage(type: type))
                                },
                                scrollRefreshHandler: { type in
                                    viewStore.send(.requestList(type: type))
                                }
                            )
                        }
                    }
                    .tag(0)
                    .onLoad {
                        viewStore.send(.onAppear(type: .receiving))
                    }
                    
                    VStack {
                        if !viewStore.isSentDataRequested {
                            ProgressView()
                        } else if viewStore.isSentDataRequested && viewStore.sentDataSources.isEmpty {
                            getEmptyView() {
                                viewStore.send(.didTappedLookAroundMeetingList)
                            }
                        } else {
                            getMeetingListView(
                                type: .requesting,
                                dataSources: viewStore.sentDataSources,
                                needShowNextPage: viewStore.sentDataNextCallId != nil,
                                tapHandler: { index in
                                    guard let type = RequestListType(rawValue: selection) else { return }
                                    viewStore.send(.didTappedMeetingView(index: index, type: type))
                                },
                                nextPageHandler: { type in
                                    viewStore.send(.requestNextPage(type: type))
                                }, 
                                scrollRefreshHandler: { type in
                                    viewStore.send(.requestList(type: type))
                                }
                            )
                        }
                    }
                    .tag(1)
                    .onLoad {
                        viewStore.send(.onAppear(type: .requesting))
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationDestination(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /RequestListFeature.Destination.State.meetingMatch,
                action: RequestListFeature.Destination.Action.meetingMatch
            ) { store in
                MeetingMatchView(store: store)
            }
        }
    }
    
    @ViewBuilder
    func getMeetingListView(
        type: RequestListType,
        dataSources: [RequestMeetingItemModel],
        needShowNextPage: Bool,
        tapHandler: @escaping (Int) -> Void,
        nextPageHandler: @escaping (RequestListType) -> Void,
        scrollRefreshHandler: @escaping (RequestListType) -> Void
    ) -> some View {
        VStack {
            ScrollView {
                ForEach(0 ..< dataSources.count, id: \.self) { index in
                    let meeting = dataSources[index]
                    MeetingItemView(meeting: meeting, type: type)
                        .onTapGesture {
                            tapHandler(index)
                        }
                }
                if !dataSources.isEmpty && needShowNextPage {
                    ProgressView()
                        .onAppear {
                            nextPageHandler(type)
                        }
                }
            }
            .refreshable {
                scrollRefreshHandler(type)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    func getEmptyView(handler: @escaping () -> Void) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text("미팅을 요청해 보세요!")
                .font(.pretendard(._600, size: 22))
            Text("아직 받은 요청이 없어요")
                .font(.pretendard(._500, size: 14))
                .foregroundStyle(DesignSystem.Colors.gray600)
            Spacer()
                .frame(height: 20)
            WeaveButton(title: "미팅 상대 둘러보기", size: .large) {
                handler()
            }
            .padding(.horizontal, 80)
        }
    }
}

fileprivate struct MeetingItemView: View {
    let meeting: RequestMeetingItemModel
    let type: RequestListType
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                RoundCornerBoxedTextView(
                    meeting.receivingTeam.teamIntroduce,
                    tintColor: DesignSystem.Colors.lightGray
                )
                Spacer()
                Text(meeting.getTimeDiffString(suffix: type.timeDiffSuffixValue))
                    .font(.pretendard(._500, size: 12))
                    .foregroundStyle(DesignSystem.Colors.defaultBlue)
            }
            
            HStack(alignment: .top) {
                Spacer()
                
                ForEach(meeting.receivingTeam.memberInfos, id: \.id) { member in
                    let mbtiType = MBTIType(rawValue: member.mbti.uppercased())
                    MemberIconView(
                        title: member.memberInfoValue,
                        subTitle: member.mbti,
                        imageURL: mbtiType?.mbtiProfileImage
                    ) {}
                }
                Spacer()
            }
        }
        .weaveBoxStyle()
    }
}

struct MemberIconView<Content: View>: View {
    let title: String
    let subTitle: String
    let isStroke: Bool
    let strokeColor: Color
    let imageURL: String?
    let overlay: () -> Content
    
    init(
        title: String,
        subTitle: String,
        isStroke: Bool = false,
        strokeColor: Color = .clear,
        imageURL: String?,
        @ViewBuilder overlay: @escaping () -> Content
    ) {
        self.title = title
        self.subTitle = subTitle
        self.isStroke = isStroke
        self.strokeColor = strokeColor
        self.imageURL = imageURL
        self.overlay = overlay
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let imageURL {
                    KFImage(URL(string: imageURL))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay(content: {
                            ZStack {
                                overlay()
                            }
                            .overlay(content: {
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 1)
                                    .stroke(strokeColor, lineWidth: isStroke ? 1 : 0)
                                    .foregroundStyle(DesignSystem.Colors.lightGray)
                            })
                        })
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                        .frame(width: 48, height: 48)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .inset(by: 1)
                        .stroke(.white, lineWidth: isStroke ? 1 : 0)
                        .foregroundStyle(DesignSystem.Colors.lightGray)
                        .background(DesignSystem.Colors.lightGray)
                        .overlay(content: {
                            overlay()
                        })
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .frame(width: 48, height: 48)
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 4) {
                Text(title)
                Text(subTitle)
            }
            .font(.pretendard(._600, size: 12))
        }
    }
}
