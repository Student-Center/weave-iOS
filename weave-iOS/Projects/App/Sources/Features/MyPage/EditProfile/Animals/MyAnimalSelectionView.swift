//
//  MyAnimalSelectionView.swift
//  weave-ios
//
//  Created by Jisu Kim on 2/25/24.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

struct MyAnimalSelectionView: View {
    
    @State var selectedAnimal: (any LeftAlignListFetchable)?
    let store: StoreOf<MyAnimalSelectionFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                CenterTitleView(title: "내가 닮은 동물상은 ?") {
                    viewStore.send(.dismiss)
                }
                
                AnimalSelectionList(
                    allAvailableAnimal: viewStore.allAvailableAnimals,
                    selectedItem: $selectedAnimal
                )
                .onChange(of: viewStore.selectedAnimal) { oldValue, newValue in
                    self.selectedAnimal = newValue
                }
                
                Spacer()
                
                WeaveButton(
                    title: "저장하기",
                    size: .large,
                    isEnabled: selectedAnimal != nil
                ) {
                    guard let selectedAnimal,
                          let animal = selectedAnimal as? AnimalModel else {
                        return
                    }
                    viewStore.send(.didTappedSaveButton(animal: animal))
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                self.selectedAnimal = viewStore.selectedAnimal
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AnimalSelectionList: View {
    
    let allAvailableAnimal: [AnimalModel]
    @Binding var selectedItem: (any LeftAlignListFetchable)?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    LeftAlignTextCapsuleListView(
                        selectedItem: $selectedItem,
                        dataSources: allAvailableAnimal,
                        viewWidth: UIScreen.main.bounds.width - 36
                    )
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    MyAnimalSelectionView(
        store: Store(initialState: MyAnimalSelectionFeature.State(), reducer: {
            MyAnimalSelectionFeature()
        })
    )
}
