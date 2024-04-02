//
//  WeaveCheckBox.swift
//  DesignSystem
//
//  Created by Jisu Kim on 3/27/24.
//

import SwiftUI

public struct WeaveCheckBox: View {
    //MARK: - Style
    @Binding public var isSelect: Bool
    let size: CGFloat
    
    public init(
        isSelect: Binding<Bool> = .constant(false),
        size: CGFloat = 24
    ) {
        self.size = size
        self._isSelect = isSelect
    }
    
    var checkboxIcon: Image {
        return isSelect ? DesignSystem.Icons.checkboxEnabled : DesignSystem.Icons.checkboxDiabled
    }
    
    public var body: some View {
        checkboxIcon
            .resizable()
            .frame(width: size, height: size)
            .onTapGesture {
                withAnimation {
                    isSelect.toggle()
                }
            }
    }
}

#Preview {
    WeaveCheckBox(isSelect: .constant(true), size: 16)
}
