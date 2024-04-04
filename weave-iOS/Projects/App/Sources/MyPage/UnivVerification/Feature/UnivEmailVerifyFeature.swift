//
//  UnivEmailVerifyFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/21/24.
//

import Foundation
import Services
import ComposableArchitecture

struct UnivEmailVerifyFeature: Reducer {
    
    @Dependency(\.mainQueue) var mainQueue
    
    struct State: Equatable {
        let userEmail: String
        @BindingState var verifyCode = String()
        @BindingState var errorMessage: String?
        @BindingState var remainTime: Int = 300
        @BindingState var showRetrySendEmailAlert = false
    }
    
    enum Action: BindableAction {
        case didTappedVerifyButton
        case didTappedRetrySendButton
        case didSuccessedVerifyEmail
        case showRetryEmailSendAlert
        case startTimer
        case timerHandler
        case fetchErrorMessage
        case didVerifyCodeChanged(value: String)
        case binding(BindingAction<State>)
    }
    
    private enum CancelID {
        case timer
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .didTappedVerifyButton:
                return .run { [email = state.userEmail, code = state.verifyCode] send in
                    try await requestVerifyCode(email: email, code: code)
                    await send.callAsFunction(.didSuccessedVerifyEmail)
                } catch: { error, send in
                    await send.callAsFunction(.fetchErrorMessage)
                }
                
            case .didSuccessedVerifyEmail:
                // 기존의 프로필 뷰로 넘어가는 액션 && 넘어가고 Alert
                return .none
                
            case .didTappedRetrySendButton:
                return .run { [email = state.userEmail] send in
                    try await requestSendVerificationEmail(email: email)
                    await send.callAsFunction(.showRetryEmailSendAlert)
                    await send.callAsFunction(.startTimer)
                } catch: { error, send in
                    print(error)
                }
                
            case .showRetryEmailSendAlert:
                state.showRetrySendEmailAlert.toggle()
                return .none
                
            case .didVerifyCodeChanged(_):
                state.errorMessage = nil
                return .none
                
            case .startTimer:
                state.remainTime = 300
                return .run { send in
                    for await _ in self.mainQueue.timer(interval: .seconds(1)) {
                        await send(.timerHandler)
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
                
            case .timerHandler:
                state.remainTime -= 1
                if state.remainTime == 0 {
                    return .cancel(id: CancelID.timer)
                }
                return .none
                
            case .fetchErrorMessage:
                state.errorMessage = "인증번호를 다시 확인해 주세요"
                return .none
                
            default:
                return .none
            }
        }
    }
    
    // 인증하기
    func requestVerifyCode(email: String, code: String) async throws {
        let dto = EmailVerifyRequestDTO(
            universityEmail: email,
            verificationNumber: code
        )
        let endPoint = APIEndpoints.verifyCode(body: dto)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
    
    // 이메일 다시 보내기
    func requestSendVerificationEmail(email: String) async throws {
        let endPoint = APIEndpoints.sendVerifyEmail(body: .init(universityEmail: email))
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
    
    enum VerifyEmailError: Error {
        case verifyError
        case retrySendEmailError
    }
}
