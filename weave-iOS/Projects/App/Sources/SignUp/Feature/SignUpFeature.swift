//
//  SignUpFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/10/24.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import Services

struct SignUpFeature: Reducer {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    struct State: Equatable {
        let registerToken: String
        // 현단계 상태값
        var currentStep: SignUpStepTypes = .agreement
        // 성별
        var selectedGender: GenderTypes?
        // 나이
        @BindingState var birthYear = String()
        // MBTI
        @BindingState var mbtiDatas = MBTIDataModel()
        // 학교
        @BindingState var universityText = String()
        var universityLists = [UniversityModel]()
        var filteredUniversityLists = [UniversityModel]()
        var selectedUniversity: UniversityModel?
        // 전공
        @BindingState var majorText = String()
        var majorLists = [MajorModel]()
        var filteredMajorLists = [MajorModel]()
        var selectedmajor: MajorModel?
        // 약관 동의
        @BindingState var isAgeCompatibilityEnabled = false
        @BindingState var isServiceAgreementEnabled = false
        @BindingState var isPrivacyAgreementEnabled = false
        // 닫기 Alert
        @BindingState var isDismissAlertShow: Bool = false
    }
    
    enum Action: BindableAction {
        // Navigation
        case didTappedNextButton
        case didTappedPreviousButton
        case didTappedDismissButton
        case dismissSignUp
        // 성별선택
        case didTappedGender(gender: GenderTypes)
        // 학교
        case requestUniversityLists
        case fetchUniversityLists(list: [UniversityResponseDTO])
        case didTappedUniversity(university: UniversityModel)
        // 전공
        case requestMajors
        case fetchMajorLists(list: [MajorResponseDTO])
        case didTappedMajors(major: MajorModel)
        // 회원가입 완료
        case fetchTokens(dto: SNSLoginResponseDTO)
        case didCompleteSignUp
        // 동의
        case didAllAgreeChanged(value: Bool)
        case didAgreeElementChanged
        case didTappedAgreementView(url: URL?)
        // bind
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            
            // 대학교 목록 필터
            if state.currentStep == .university {
                state.filteredUniversityLists = filterUniversityDataSource(
                    dataSource: state.universityLists,
                    text: state.universityText
                )
                
                state.selectedUniversity = state.filteredUniversityLists.first { $0.name == state.universityText }
            }
            
            // 전공 목록 필터
            if state.currentStep == .major {
                state.filteredMajorLists = filterMajorDataSource(
                    dataSource: state.majorLists,
                    text: state.majorText
                )
                
                state.selectedmajor = state.filteredMajorLists.first { $0.name == state.majorText }
            }
            
            switch action {
            case .didTappedGender(let gender):
                state.selectedGender = gender
                return .none
                
            case .didTappedNextButton:
                let nextRawValue = state.currentStep.rawValue + 1
                if let nextStep = SignUpStepTypes(rawValue: nextRawValue) {
                    state.currentStep = nextStep
                } else {
                    // Validation
                    guard let gender = state.selectedGender,
                          let birthYear = Int(state.birthYear),
                          let univ = state.selectedUniversity,
                          let major = state.selectedmajor else { return .none }
                    let requestDTO = RegisterUserRequestDTO(
                        gender: gender.value,
                        birthYear: birthYear,
                        mbti: state.mbtiDatas.requestValue,
                        universityId: univ.id,
                        majorId: major.id
                    )
                    return .run { [token = state.registerToken] send in
                        let response = try await requestRegisterUser(
                            registerToken: token,
                            dto: requestDTO
                        )
                        await send.callAsFunction(.fetchTokens(dto: response))
                    } catch: { error, send in
                        print(error)
                    }
                }
                return .none
                
            case .didTappedDismissButton:
                state.isDismissAlertShow.toggle()
                return .none
                
            case .didTappedPreviousButton:
                let previousRawValue = state.currentStep.rawValue - 1
                if let previousStep = SignUpStepTypes(rawValue: previousRawValue) {
                    state.currentStep = previousStep
                } else {
                    print("없음")
                }
                return .none
                
            case .requestUniversityLists:
                return .run { send in
                    let universityLists = try await requestUniversityLists()
                    await send.callAsFunction(.fetchUniversityLists(list: universityLists))
                } catch: { error, send in
                    print(error)
                }
                
            case .fetchTokens(let tokens):
                return .run { send in
                    UDManager.accessToken = tokens.accessToken
                    UDManager.refreshToken = tokens.refreshToken
                    await send.callAsFunction(.didCompleteSignUp)
                }
                
            case .fetchUniversityLists(let universityLists):
                let dataSource = universityLists.map { $0.toDomain }
                state.universityLists = dataSource
                state.filteredUniversityLists = dataSource
                return .none
                
            case .didTappedUniversity(let university):
                state.selectedUniversity = university
                state.universityText = university.name
                return .none
                
            case .requestMajors:
                // 초기화
                state.majorText = ""
                state.majorLists = []
                state.filteredMajorLists = []
                state.selectedmajor = nil
                return .run { [univId = state.selectedUniversity?.id] send in
                    guard let univId else { return }
                    let majorList = try await requestMajorLists(univId: univId)
                    await send.callAsFunction(.fetchMajorLists(list: majorList))
                } catch: { error, send in
                    print(error)
                }
                
            case .fetchMajorLists(let list):
                let dataSource = list.map { $0.toDomain }
                state.majorLists = dataSource
                state.filteredMajorLists = dataSource
                return .none
                
            case .didTappedMajors(let major):
                state.selectedmajor = major
                state.majorText = major.name
                return .none
                
            case .didAllAgreeChanged(let value):
                withAnimation {
                    state.isAgeCompatibilityEnabled = value
                    state.isServiceAgreementEnabled = value
                    state.isPrivacyAgreementEnabled = value
                }
                return .none
                
            case .didTappedAgreementView(let url):
                guard let url else { return .none }
                UIApplication.shared.open(url)
                return .none
                
            case .didCompleteSignUp:
                coordinator.changeRoot(to: .mainView)
                return .none
                
            case .dismissSignUp:
                coordinator.changeRoot(to: .loginView)
                return .none
                
            default: return .none
            }
        }
    }
    
    // 학교 리스트 불러오기
    private func requestUniversityLists() async throws -> [UniversityResponseDTO] {
        let endPoint = APIEndpoints.getUniversityInfo()
        let provider = APIProvider()
        let response: UniversitiesResponseDTO = try await provider.request(with: endPoint)
        return response.universities
    }
                         
    // 전공 리스트 불러오기
    private func requestMajorLists(univId: String) async throws -> [MajorResponseDTO] {
        let endPoint = APIEndpoints.getMajorInfo(univId: univId)
        let provider = APIProvider()
        let response: MajorsResponseDTO = try await provider.request(with: endPoint)
        return response.majors
    }
    
    // 회원가입 요청
    private func requestRegisterUser(registerToken: String, dto: RegisterUserRequestDTO) async throws -> SNSLoginResponseDTO {
        let endPoint = APIEndpoints.registerUser(registerToken: registerToken, body: dto)
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
    
    // 포함하는 데이터 소스로 정렬해 리턴
    private func filterUniversityDataSource(dataSource: [UniversityModel], text: String) -> [UniversityModel] {
        if text == "" { return dataSource }
        return dataSource.filter { $0.name.contains(text) }
    }
    
    private func filterMajorDataSource(dataSource: [MajorModel], text: String) -> [MajorModel] {
        if text == "" { return dataSource }
        return dataSource.filter { $0.name.contains(text) }
    }
}

extension SignUpFeature {
    
    enum SignUpStepTypes: Int, Equatable {
        case gender = 0
        case year = 1
        case mbti = 2
        case university = 3
        case major = 4
        case agreement = 5
        
        var title: String {
            switch self {
            case .gender:
                return "반가워요✋\n성별이 무엇인가요?"
            case .year:
                return "출생년도를 알려주세요"
            case .mbti:
                return "성격 유형이 무엇인가요?"
            case .university:
                return "어느 대학교에 다니시나요?"
            case .major:
                return "어떤 학과를 전공하고 계시나요?"
            case .agreement:
                return "환영합니다!\n아래 약관에 동의해주세요."
            }
        }
    }
    
    enum GenderTypes {
        case boy
        case girl
        
        var title: String {
            switch self {
            case .boy: return "남성"
            case .girl: return "여성"
            }
        }
        
        var value: String {
            switch self {
            case .boy: return "MAN"
            case .girl: return "WOMAN"
            }
        }
        
        func getIconImage(isSelected: Bool) -> Image {
            switch self {
            case .boy: return isSelected ? DesignSystem.Icons.boySelected : DesignSystem.Icons.boyNormal
            case .girl: return isSelected ? DesignSystem.Icons.girlSelected : DesignSystem.Icons.girlNormal
            }
        }
    }
}
