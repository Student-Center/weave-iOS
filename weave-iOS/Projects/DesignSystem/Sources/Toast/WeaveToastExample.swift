//
//  WeaveToastExample.swift
//  DesignSystem
//
//  Created by 강동영 on 3/27/24.
//

import SwiftUI

struct WeaveToastExample: View {
    
    @State var isToastShowed = false
    
    var body: some View {
        VStack {
            Text("Toast 테스트 뷰")
                .font(.pretendard(._800, size: 35))
            Spacer()
            
            WeaveButton(
                title: "토스트",
                style: .filled,
                size: .medium) {
                    isToastShowed.toggle()
                }
                .frame(width: 150)
                .weaveToast(
                    isShowing: $isToastShowed,
                    message: "✅ ID가 복사되었어요."
                )
            
            WeaveButton(
                title: "토스트",
                style: .filled,
                size: .medium) {
                    isToastShowed.toggle()
                }
                .frame(width: 150)
                .weaveToast(
                    isShowing: $isToastShowed,
                    message: "✅ ID가 복사되었어요."
                )
            Spacer()
                .frame(height: 250)
        }
    }
}

#Preview {
    WeaveToastExample()
}
