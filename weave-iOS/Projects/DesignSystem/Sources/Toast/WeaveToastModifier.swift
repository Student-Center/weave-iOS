//
//  WeaveToastModifier.swift
//  DesignSystem
//
//  Created by 강동영 on 3/27/24.
//

import SwiftUI

public struct WeaveToastModifier: ViewModifier {
    
    @Binding var isShowing: Bool
    let message: String
    
    let weaveToast: WeaveToast
        
    public func body(content: Content) -> some View {
        ZStack {
            content
            weaveToast
        }
    }
}

public extension View {
    func weaveToast(
        isShowing: Binding<Bool>,
        message: String,
        messageColor: Color = DesignSystem.Colors.white
    ) -> some View {
        let toast = WeaveToast(
            isShowing: isShowing,
            message: message,
            messageColor: messageColor
        )

        return modifier(WeaveToastModifier(isShowing: isShowing, message: message, weaveToast: toast))
    }
}
