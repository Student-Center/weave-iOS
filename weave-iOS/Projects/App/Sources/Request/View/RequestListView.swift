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
                        } else {
                            getMeetingListView(
                                type: .receiving,
                                dataSources: viewStore.receivedDataSources,
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
                                },
                                lookAroundMeetingListHandler: {
                                    viewStore.send(.didTappedLookAroundMeetingList)
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
                                },
                                lookAroundMeetingListHandler: {
                                    viewStore.send(.didTappedLookAroundMeetingList)
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
        scrollRefreshHandler: @escaping (RequestListType) -> Void,
        lookAroundMeetingListHandler: @escaping () -> Void
    ) -> some View {
        VStack {
            ScrollView {
                if dataSources.isEmpty {
                    getEmptyView() {
                        lookAroundMeetingListHandler()
                    }
                } else {
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
        ListEmptyGuideView(
            headerTitle: "미팅을 요청해 보세요!",
            subTitle: "아직 받은 요청이 없어요",
            buttonTitle: "미팅 상대 둘러보기",
            buttonHandler: handler
        )
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
                let dataSource = type == .requesting ? meeting.receivingTeam : meeting.requestingTeam
                ForEach(dataSource.memberInfos, id: \.id) { member in
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
