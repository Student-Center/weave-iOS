//
//  MyPageCore.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/16/24.
//

import SwiftUI
import ComposableArchitecture
import Services
import AVFoundation
import DesignSystem
import CoreKit

struct MyPageFeature: Reducer {
    @Dependency(\.tabViewCoordinator) var tabViewCoordinator
    @Dependency(\.coordinator) var appCoordinator
    struct State: Equatable {
        var myUserInfo: MyUserInfoModel?
        @BindingState var isShowEditProfileImageAlert: Bool = false
        @BindingState var isShowPhotoPicker: Bool = false
        @BindingState var isShowCamera: Bool = false
        @BindingState var isShowCameraPermissionAlert: Bool = false
        
        @BindingState var isShowCompleteUnivVerifyAlert: Bool = false
        @BindingState var isShowCompleteUnivVerifyView: Bool = false
        
        @PresentationState var destination: Destination.State?
    }
    
    enum Action: BindableAction {
        case requestMyUserInfo
        case fetchMyUserInfo(userInfo: MyUserInfoResponseDTO)
        case didTappedPreferenceButton
        case didTappedProfileView
        case didTappedProfileEditButton
        case didTappedSubViews(view: MyPageCategoryTypes.MyPageSubViewTypes)
        case showPhotoPicker
        case didTappedShowCamera
        case didCameraPermissionDenied
        case didSuccessedResign
        case didTappedGoToGenerateMyTeam
        case showCamera
        case showAppPreference
        case didPickPhotoCompleted(image: UIImage)
        case destination(PresentationAction<Destination.Action>)
        case pushUnivVerifyView
        // bind
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .requestMyUserInfo:
                return .run { send in
                    let myUserInfo = try await requestMyUserInfo()
                    await send.callAsFunction(.fetchMyUserInfo(userInfo: myUserInfo))
                } catch: { error, send in
                    print(error)
                }
                
            case .fetchMyUserInfo(let userInfo):
                state.myUserInfo = userInfo.toDomain
                // 글로벌 데이터도 갱신
                UserInfo.myInfo = userInfo.toDomain
                return .none
                
            case .didTappedPreferenceButton:
                state.destination = .presentSetting(.init())
                return .none
                
            case .didTappedProfileView:
                return .none
                
            case .didTappedProfileEditButton:
                state.isShowEditProfileImageAlert.toggle()
                return .none
                
            case .didTappedSubViews(let type):
                switch type {
                case .kakaoTalkId:
                    if state.myUserInfo?.kakaoId == "" || state.myUserInfo?.kakaoId == nil {
                        state.destination = .setKakaoId(.init())
                    }
                    return .none
                    
                case .mbti:
                    state.destination = .editMbti(
                        .init(
                            mbtiDataModel: .init(
                                mbti: state.myUserInfo?.mbti ?? ""
                            )
                        )
                    )
                case .physicalHeight:
                    state.destination = .editHeight(
                        .init(
                            height: state.myUserInfo?.height
                        )
                    )
                case .similarAnimal:
                    var animalType: AnimalModel?
                    if let animalName = state.myUserInfo?.animalType {
                        print(animalName)
                        animalType = .init(name: "", description: animalName)
                    }
                    state.destination = .editAnimal(
                        .init(
                            selectedAnimal: animalType
                        )
                    )
                case .emailVerification:
                    if state.myUserInfo?.isUniversityEmailVerified == true {
                        state.isShowCompleteUnivVerifyView.toggle()
                        return .none
                    }
                    return .run { send in
                        try await checkUserInfo()
                        await send.callAsFunction(.pushUnivVerifyView)
                    }
                }
                
                return .none
                
            case .pushUnivVerifyView:
                state.destination = .univVerify(.init(universityName: state.myUserInfo?.universityName ?? ""))
                return .none
                
            case .destination(.dismiss):
                state.destination = nil
                return .run { send in
                    await send.callAsFunction(.requestMyUserInfo)
                }
                
            case .destination(.presented(.univVerify(.didCompleteVerifyEmail))):
                state.destination = nil
                state.isShowCompleteUnivVerifyAlert.toggle()
                return .send(.requestMyUserInfo)
                
            case .destination(.presented(.presentSetting(.resignSuccessed))):
                state.destination = nil
                return .run { send in
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await send.callAsFunction(.didSuccessedResign)
                }
                
            case .didSuccessedResign:
                appCoordinator.changeRoot(to: .loginView)
                return .none
                
            case .destination(.presented(.presentSetting(.didTappedDismiss))):
                state.destination = nil
                return .none
                
            case .showPhotoPicker:
                state.isShowPhotoPicker.toggle()
                return .none
                
            case .didTappedShowCamera:
                return .run { send in
                    // 카메라 권한 상태 가지고 보내기
                    let cameraPermission = await checkCameraAuthorization()
                    if cameraPermission {
                        await send.callAsFunction(.showCamera)
                    } else {
                        await send.callAsFunction(.didCameraPermissionDenied)
                    }
                }
                
            case .showCamera:
                state.isShowCamera.toggle()
                return .none
                
            case .didCameraPermissionDenied:
                state.isShowCameraPermissionAlert.toggle()
                return .none
                
            case .didPickPhotoCompleted(let image):
                // 1. presigned URL 요청
                return .run { send in
                    let response = try await requestGetPresignedURL()
                    try await requestUploadImage(url: response.uploadUrl, image: image)
                    try await requestImageUploadCallback(imageId: response.imageId)
                    let userResponse = try await requestMyUserInfo()
                    await send.callAsFunction(.fetchMyUserInfo(userInfo: userResponse))
                } catch: { error, send in
                    print(error)
                }
                
            case .showAppPreference:
                if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSetting)
                }
                return .none
                
            case .binding(_):
                return .none
                
            default: return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
    
    func checkUserInfo() async throws {
        if UserInfo.myInfo?.universityName == nil {
            try await UserInfo.updateUserInfo()
        }
    }
    
    func requestMyUserInfo() async throws -> MyUserInfoResponseDTO {
        let endPoint = APIEndpoints.getMyUserInfo()
        let provider = APIProvider(session: URLSession.shared)
        let response = try await provider.request(with: endPoint)
        return response
    }
    
    func requestGetPresignedURL() async throws -> ProfileImageUploadPresignedURLResponseDTO {
        let endPoint = APIEndpoints.getProfileImageUploadPresignedURL()
        let provider = APIProvider()
        let response = try await provider.request(with: endPoint)
        return response
    }
    
    func requestUploadImage(url: String, image: UIImage) async throws {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw ImageUploadError.convertImageToDataError
        }
        
        let endPoint = APIEndpoints.getProfileImageUpload(presignedURL: url)
        let provider = APIProvider()
        try await provider.requestUploadData(with: endPoint, data: imageData)
    }
    
    func requestImageUploadCallback(imageId: String) async throws {
        let endPoint = APIEndpoints.getProfileImageUploadCallback(imageId: imageId)
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
    
    func checkCameraAuthorization() async -> Bool {
        //권한 여부 확인
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            return true
        } else if status == .notDetermined {
            return await AVCaptureDevice.requestAccess(for: .video)
        } else {
            return false
        }
    }
}

//MARK: - Destination
extension MyPageFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case presentSetting(SettingFeautre.State)
            case setKakaoId(SetKakaoIdFeature.State)
            case editMbti(MyMbtiEditFeature.State)
            case editAnimal(MyAnimalSelectionFeature.State)
            case editHeight(MyHeightEditFeature.State)
            case univVerify(UnivEmailInputFeature.State)
        }
        enum Action {
            case presentSetting(SettingFeautre.Action)
            case setKakaoId(SetKakaoIdFeature.Action)
            case editMbti(MyMbtiEditFeature.Action)
            case editAnimal(MyAnimalSelectionFeature.Action)
            case editHeight(MyHeightEditFeature.Action)
            case univVerify(UnivEmailInputFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: /State.presentSetting, action: /Action.presentSetting) {
                SettingFeautre()
            }
            Scope(state: /State.setKakaoId, action: /Action.setKakaoId) {
                SetKakaoIdFeature()
            }
            Scope(state: /State.editMbti, action: /Action.editMbti) {
                MyMbtiEditFeature()
            }
            Scope(state: /State.editAnimal, action: /Action.editAnimal) {
                MyAnimalSelectionFeature()
            }
            Scope(state: /State.editHeight, action: /Action.editHeight) {
                MyHeightEditFeature()
            }
            Scope(state: /State.univVerify, action: /Action.univVerify) {
                UnivEmailInputFeature()
            }
        }
    }
}
