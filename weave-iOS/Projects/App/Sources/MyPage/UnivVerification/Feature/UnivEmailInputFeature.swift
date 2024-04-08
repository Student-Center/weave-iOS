//
//  UnivEmailInputFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/19/24.
//

import Foundation
import Services
import ComposableArchitecture

struct UnivEmailInputFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        let universityName: String
        var universityInfo: UniversityInfoModel?
        @BindingState var emailPrefix = String()
        @BindingState var isShowEmailSendAlert = false
        @BindingState var isShowEmailSendErrorAlert = false
        
        var isNetworkRequested = false
        
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: BindableAction {
        case requestUniversityInfo
        case fetchUniversityInfo(dto: UniversityInfoResponseDTO)
        case requestSendVerifyEmail
        case showSendErrorAlert
        case didCompleteSendEmail
        case pushNextView
        case binding(BindingAction<State>)
        
        case changeEmailRequestFlag
        
        case didCompleteVerifyEmail
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .requestSendVerifyEmail:
                // 중복 요청 방지
                guard state.isNetworkRequested == false else {
                    return .none
                }
                return .run { [emailPrefix = state.emailPrefix, univInfo = state.universityInfo] send in
                    await send.callAsFunction(.changeEmailRequestFlag)
                    try await requestSendVerificationEmail(
                        email: emailPrefix + "@" + (univInfo?.domainAddress ?? "")
                    )
                    await send.callAsFunction(.didCompleteSendEmail)
                } catch: { error, send in
                    await send.callAsFunction(.changeEmailRequestFlag)
                }
                
            case .requestUniversityInfo:
                return .run { [univName = state.universityName] send in
                    let univInfo = try await requestUniversityInfo(univName: univName)
                    await send.callAsFunction(.fetchUniversityInfo(dto: univInfo))
                } catch: { error, send in
                    print(error)
                }
                
            case .changeEmailRequestFlag:
                state.isNetworkRequested.toggle()
                return .none
                
            case .fetchUniversityInfo(let dto):
                state.universityInfo = dto.toDomain
                return .none
                
            case .showSendErrorAlert:
                state.isShowEmailSendErrorAlert.toggle()
                return .none
                
            case .didCompleteSendEmail:
                state.isShowEmailSendAlert.toggle()
                return .send(.changeEmailRequestFlag)
                
            case .pushNextView:
                guard let univDomain = state.universityInfo?.domainAddress else { return .none }
                let userEmail = state.emailPrefix + "@" + univDomain
                state.destination = .emailVerify(.init(userEmail: userEmail))
                return .none
                
            case .destination(.presented(.emailVerify(.didSuccessedVerifyEmail))):
                return .run { send in
                    await send.callAsFunction(.didCompleteVerifyEmail)
                }
                
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    func requestUniversityInfo(univName: String) async throws -> UniversityInfoResponseDTO {
        let endPoint = APIEndpoints.getSingleUniversityInfo(univName: univName)
        let provider = APIProvider()
        let response: UniversityInfoResponseDTO = try await provider.request(with: endPoint)
        return response
    }
    
    // 이메일 보내기
    func requestSendVerificationEmail(email: String) async throws {
        print("👉 발송 이메일: \(email)")
        let endPoint = APIEndpoints.sendVerifyEmail(body: .init(universityEmail: email))
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
    
    enum SendEmailError: Error {
        case statusCodeError
    }
}

//MARK: - Destination
extension UnivEmailInputFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case emailVerify(UnivEmailVerifyFeature.State)
        }
        enum Action {
            case emailVerify(UnivEmailVerifyFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.emailVerify, action: /Action.emailVerify) {
                UnivEmailVerifyFeature()
            }
        }
    }
}
