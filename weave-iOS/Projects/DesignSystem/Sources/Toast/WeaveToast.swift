//
//  WeaveToast.swift
//  DesignSystem
//
//  Created by 강동영 on 3/27/24.
//

import SwiftUI

public struct WeaveToast: View {
    static let short: TimeInterval = 2
    static let long: TimeInterval = 3.5
    
    @Binding var isShowing: Bool
    var message: String
    let messageColor: Color
    let duration: TimeInterval
    let transition: AnyTransition
    let animation: Animation
    
    init(
        isShowing: Binding<Bool>,
        message: String,
        messageColor: Color = DesignSystem.Colors.white,
        duration: TimeInterval = WeaveToast.short,
        transition: AnyTransition = .opacity,
        animation: Animation = .linear(duration: 0.3)
    ) {
        self._isShowing = isShowing
        self.message = message
        self.messageColor = messageColor
        self.duration = duration
        self.transition = transition
        self.animation = animation
    }
    
    public var body: some View {
        VStack {
            Spacer()
            if isShowing {
                Group {
                    Text(message)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(messageColor)
                        .font(.pretendard(._500, size: 22))
                        .padding(.all, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(DesignSystem.Colors.darkGray)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 14.0
                    )
                )
                .onTapGesture {
                    isShowing = false
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isShowing = false
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(animation, value: isShowing)
        .transition(transition)
    }
}

#Preview {
    WeaveToast(
        isShowing: .constant(true),
        message: "✅ ID가 복사되었어요."
    )
}
