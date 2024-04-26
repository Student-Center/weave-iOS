//
//  MyAnimalSelectionFeature.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/25/24.
//

import Foundation
import ComposableArchitecture
import Services
import DesignSystem

struct MyAnimalSelectionFeature: Reducer {
    @Dependency(\.dismiss) var dismiss
    
    struct State: Equatable {
        @BindingState var selectedAnimal: AnimalModel?
        @BindingState var allAvailableAnimals: [AnimalModel]
        init(selectedAnimal: AnimalModel? = nil) {
            self.selectedAnimal = selectedAnimal
            self.allAvailableAnimals = []
        }
    }
    
    enum Action: BindableAction {
        case didTappedSaveButton(animal: AnimalModel)
        case onAppear
        case fetchAnimals(dto: AnimalsResponseDTO)
        case dismiss
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .didTappedSaveButton(let animal):
                return .run { send in
                    try await requestEditMyAnimal(animal: animal)
                    await send.callAsFunction(.dismiss)
                } catch: { error, send in
                    print(error)
                }
                
            case .onAppear:
                return .run { send in
                    let response = try await requestAllAnimals()
                    await send.callAsFunction(.fetchAnimals(dto: response))
                } catch: { error, send in
                    print(error)
                }
                
            case .fetchAnimals(let dto):
                state.allAvailableAnimals = dto.toDomain
                // 이미 선택된 데이터 Fetch
                if let selectedAnimal = state.selectedAnimal {
                    if let index = state.allAvailableAnimals.firstIndex(where: { $0.description == selectedAnimal.description }) {
                        let result = state.allAvailableAnimals[index]
                        state.selectedAnimal = result
                    }
                }
                return .none
                
            case .dismiss:
                return .run { send in
                    await dismiss()
                }
                
            default:
                return .none
            }
        }
    }
    
    func requestAllAnimals() async throws -> AnimalsResponseDTO {
        let endPoint = APIEndpoints.getAllAvailableAnimal()
        let provider = APIProvider()
        return try await provider.request(with: endPoint)
    }
    
    func requestEditMyAnimal(animal: AnimalModel) async throws {
        let endPoint = APIEndpoints.editMyAnimal(body: .init(animalType: animal.name))
        let provider = APIProvider()
        try await provider.requestWithNoResponse(with: endPoint)
    }
}
