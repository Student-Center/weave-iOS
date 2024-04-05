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
    let animation: Animation
    
    init(
        isShowing: Binding<Bool>,
        message: String,
        messageColor: Color = DesignSystem.Colors.white,
        duration: TimeInterval = WeaveToast.short,
        animation: Animation = .easeOut(duration: 0.2)
    ) {
        self._isShowing = isShowing
        self.message = message
        self.messageColor = messageColor
        self.duration = duration
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
                        .font(.pretendard(._500, size: 14))
                        .padding(.all, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DesignSystem.Colors.darkGray)
                        .clipShape(RoundedRectangle(cornerRadius: 14.0))
                }
                .transition(AnyTransition.opacity.combined(with: .move(edge: .bottom)))
                .animation(animation, value: isShowing)
                .onTapGesture {
                    withAnimation(animation) {
                        isShowing = false
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation(animation) {
                            isShowing = false
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottom)
        .animation(animation, value: isShowing)
    }
}

#Preview {
    WeaveToast(
        isShowing: .constant(true),
        message: "✅ ID가 복사되었어요."
    )
}
