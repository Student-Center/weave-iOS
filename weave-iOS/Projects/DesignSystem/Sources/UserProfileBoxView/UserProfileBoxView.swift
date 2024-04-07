//
//  UserProfileBoxView.swift
//  DesignSystem
//
//  Created by Jisu Kim on 3/19/24.
//

import SwiftUI
import Kingfisher
import CoreKit

public struct UserProfileBoxConfig {
    let mbti: MBTIType?
    let animal: String?
    let height: Int?
    let profileImage: String?
    let univName: String
    let majorName: String
    let birthYear: Int
    let isUnivVerified: Bool
    let kakaoId: String?
    
    public init(
        mbti: MBTIType?,
        animal: String?,
        height: Int?,
        profileImage: String?,
        univName: String,
        majorName: String,
        birthYear: Int,
        isUnivVerified: Bool,
        kakaoId: String? = nil
    ) {
        self.mbti = mbti
        self.animal = animal
        self.height = height
        self.profileImage = profileImage
        self.univName = univName
        self.majorName = majorName
        self.birthYear = birthYear
        self.isUnivVerified = isUnivVerified
        self.kakaoId = kakaoId
    }
}

public struct UserProfileBoxView: View {
    
    let config: UserProfileBoxConfig
    
    public init(config: UserProfileBoxConfig) {
        self.config = config
    }
    
    var univVerifiedIcon: Image {
        config.isUnivVerified ? DesignSystem.Icons.certified : DesignSystem.Icons.nonCertified
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                if let mbti = config.mbti {
                    RoundCornerBoxedTextView(mbti.description)
                }
                if let animalType = config.animal {
                    RoundCornerBoxedTextView(animalType)
                }
                if let height = config.height {
                    RoundCornerBoxedTextView("📏 \(height)cm")
                }
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                    HStack(spacing: 3) {
                        Text(config.univName)
                        univVerifiedIcon
                    }
                    Text(config.majorName)
                    Text("\(config.birthYear.toShortBirthYear())년생")
                    
                    if let kakaoId = config.kakaoId {
                        Text("ID : \(kakaoId)")
                            .foregroundStyle(DesignSystem.Colors.defaultBlue)
                    }
                }
                .font(.pretendard(._500, size: 16))
                
                Spacer()
                
                if let profileImage = config.profileImage {
                    KFImage(URL(string: profileImage))
                        .placeholder{
                            ProgressView()
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 112, height: 112)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 112, height: 112)
                        .foregroundStyle(DesignSystem.Colors.lightGray)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(.all, 12)
        .background(DesignSystem.Colors.darkGray)
        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
        .padding(.horizontal, 16)
        .frame(height: 180)
    }
}
