//
//  WeaveAlert.swift
//  DesignSystem
//
//  Created by Jisu Kim on 2/10/24.
//

import SwiftUI

public struct WeaveAlert: View {
    
    @Binding var isPresented: Bool
    @State var animation: Bool = false
    
    @State private var backgroundOpacity = 0.0
    @State private var zStackOffset = UIScreen.main.bounds.size.height / 2
    
    let title: String
    var message: String?
    let primaryButtonTitle: String
    let primaryButtonColor: Color
    var secondaryButtonTitle: String?
    var primaryAction: (() -> Void)?
    var secondaryAction: (() -> Void)?
    
    init(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        primaryButtonTitle: String,
        primaryButtonColor: Color = DesignSystem.Colors.defaultBlue,
        secondaryButtonTitle: String? = nil,
        primaryAction: (() -> Void)? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.primaryButtonTitle = primaryButtonTitle
        self.primaryButtonColor = primaryButtonColor
        self.secondaryButtonTitle = secondaryButtonTitle
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
    }
    
    private var viewWidth: CGFloat {
        return UIScreen.main.bounds.size.width - 60
    }
    
    public var body: some View {
        ZStack {
            DesignSystem.Colors.black.opacity(backgroundOpacity).ignoresSafeArea()
            ZStack {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        Text(title)
                            .multilineTextAlignment(.center)
                            .font(.pretendard(._600, size: 16))
                            .lineSpacing(8)
                        
                        if let message {
                            Text(message)
                                .multilineTextAlignment(.center)
                                .font(.pretendard(._400, size: 14))
                                .lineSpacing(2)
                        }
                    }
                    .padding(.top, 22)
                    .padding(.bottom, 16)
                    
                    HStack(spacing: 8) {
                        if let secondaryButtonTitle {
                            WeaveButton(
                                title: secondaryButtonTitle,
                                size: .large,
                                backgroundColor: DesignSystem.Colors.lightGray
                            ) {
                                isPresented.toggle()
                                secondaryAction?()
                            }
                            .frame(width: getButtonWidth(ratio: 0.3))
                        }
                        
                        WeaveButton(
                            title: primaryButtonTitle,
                            size: .large,
                            backgroundColor: primaryButtonColor
                        ) {
                            isPresented.toggle()
                            primaryAction?()
                        }
                        .frame(width: getButtonWidth(ratio: 0.7))
                    }
                    .frame(width: viewWidth - 40)
                    .padding(.vertical, 16)
                }
                .padding(.horizontal, 20)
            }
            .background(DesignSystem.Colors.darkGray)
            .clipShape(
                RoundedRectangle(cornerRadius: 14)
            )
            .frame(width: viewWidth)
            .offset(y: zStackOffset)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.15)) {
                backgroundOpacity = 0.4
            }
            withAnimation(.spring(.bouncy(duration: 0.2))) {
                zStackOffset = 0
            }
        }
    }
    
    private func getButtonWidth(ratio: CGFloat) -> CGFloat {
        let buttonStackWidth = viewWidth - 40 - 8
        return buttonStackWidth * ratio
    }
}

#Preview {
    WeaveAlert(
        isPresented: .constant(true),
        title: "🚀\n학교 메일 인증",
        message: "인증 메일이 발송되었어요.\n메일을 확인해 인증을 완료해 주세요.",
        primaryButtonTitle: "확인",
        secondaryButtonTitle: "취소",
        primaryAction: {
            print("엥")
        }
    )
}
