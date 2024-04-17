//
//  WeaveIndicatorModifier.swift
//  DesignSystem
//
//  Created by 강동영 on 4/17/24.
//

import SwiftUI

public struct WeaveIndicatorModifier: ViewModifier {
    
    @Binding var isShowing: Bool
    
    let indicator: WeaveIndicator
        
    public func body(content: Content) -> some View {
        content
            .transparentFullScreenCover(isPresented: $isShowing) {
                indicator
            }
            .transaction({ transaction in
                transaction.disablesAnimations = !isShowing
            })
    }
}

public extension View {
    func weaveIndicator(
        isShowing: Binding<Bool>
    ) -> some View {
        let indicator = WeaveIndicator(animated: isShowing)

        return modifier(WeaveIndicatorModifier(
            isShowing: isShowing,
            indicator: indicator))
    }
}
