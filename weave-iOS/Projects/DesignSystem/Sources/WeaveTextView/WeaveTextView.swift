//
//  WeaveTextView.swift
//  DesignSystem
//
//  Created by 김지수 on 4/23/24.
//

import SwiftUI

public struct WeaveTextView: View {
    @Binding var text: String
    @FocusState var isFocused: Bool
    
    let placeholder: String
    let height: CGFloat
    
    public init(
        text: Binding<String>,
        placeholder: String = "",
        height: CGFloat = 200,
        isFocused: FocusState<Bool> = .init()
    ) {
        self._text = text
        self.height = height
        self._isFocused = isFocused
        self.placeholder = placeholder
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            DesignSystem.Colors.darkGray
            TextEditor(text: $text)
                .focused($isFocused)
                .padding(.all, 18)
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.white)
                .background(.clear)
            
            if text.isEmpty {
                Text(placeholder)
                    .padding(.top, 5)
                    .padding(.all, 22)
                    .foregroundStyle(DesignSystem.Colors.lightGray)
                    .onTapGesture {
                        isFocused = true
                    }
            }
        }
        .font(.pretendard(._500, size: 14))
        .lineSpacing(10)
        .frame(height: height)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 10
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 10
            )
            .inset(by: 1)
            .stroke(DesignSystem.Colors.lightGray, lineWidth: 1.0)
            .foregroundStyle(.clear)
        }
    }
}
