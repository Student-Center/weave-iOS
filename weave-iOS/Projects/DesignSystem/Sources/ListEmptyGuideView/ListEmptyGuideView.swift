//
//  ListEmptyGuideView.swift
//  DesignSystem
//
//  Created by Jisu Kim on 4/16/24.
//

import SwiftUI

public struct ListEmptyGuideView: View {
    
    let headerTitle: String
    let subTitle: String?
    let buttonTitle: String?
    var viewSize: CGSize
    var buttonHandler: (() -> Void)?
    
    public init(
        headerTitle: String,
        subTitle: String? = nil,
        buttonTitle: String? = nil,
        viewSize: CGSize,
        buttonHandler: (() -> Void)? = nil
    ) {
        self.headerTitle = headerTitle
        self.subTitle = subTitle
        self.buttonTitle = buttonTitle
        self.viewSize = viewSize
        self.buttonHandler = buttonHandler
    }
    
    
    public var body: some View {
        VStack(spacing: 10) {
            Text(headerTitle)
                .font(.pretendard(._600, size: 22))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
            if let subTitle {
                Text(subTitle)
                    .font(.pretendard(._500, size: 14))
                    .foregroundStyle(DesignSystem.Colors.gray600)
            }
            if let buttonTitle {
                Spacer()
                    .frame(height: 20)
                WeaveButton(title: buttonTitle, size: .large) {
                    buttonHandler?()
                }
                .padding(.horizontal, 80)
            }
        }
        .frame(height: viewSize.height)
    }
}
