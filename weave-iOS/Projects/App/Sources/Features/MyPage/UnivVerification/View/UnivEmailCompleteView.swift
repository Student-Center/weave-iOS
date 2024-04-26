//
//  UnivEmailCompleteView.swift
//  weave-ios
//
//  Created by Jisu Kim on 3/18/24.
//

import SwiftUI
import DesignSystem

struct UnivEmailCompleteView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            DesignSystem.Icons.certified
                .resizable()
                .frame(width: 36, height: 36)
            Text("학교 메일 인증 완료!")
                .font(.pretendard(._500, size: 22))
        }
        .offset(y: -50)
        .navigationTitle("대학교 인증")
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(.white)
            }
        }
    }
}
